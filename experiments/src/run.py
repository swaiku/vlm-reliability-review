"""Run one VLM and one specialist per task on a JSONL benchmark and write metrics.

Each data row: {"image": "data/x.jpg", "task": "presence|localization|counting",
"label": "dog", "present": true, "boxes": [[x1, y1, x2, y2]], "count": 3, "split": "tune|test"}
Usage: python -m src.run --config configs/default.yaml
"""

import argparse
import csv
import json
from pathlib import Path

import yaml
from PIL import Image
from tqdm import tqdm

from . import evaluate as ev
from .models import vlm


def load(path):
    return [json.loads(line) for line in Path(path).read_text().splitlines() if line.strip()]


def ask(cfg, task, r):
    return vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"][task].format(**r), think=cfg["vlm"]["think"])


def split(rows):
    return [r for r in rows if r["split"] == "tune"], [r for r in rows if r["split"] == "test"]


def presence(rows, cfg, spec, det):
    """Metrics per POPE setting (random, popular, adversarial), as in POPE.

    specialist: SigLIP 2 score. detector: presence read from the localization specialist, scored by
    its best box (0 without a box). Both thresholds maximize accuracy on the tuning part."""
    settings = sorted({r.get("setting", "all") for r in rows})
    if len(settings) > 1:
        return {f"{who}_{s}": m for s in settings
                for who, m in presence([r for r in rows if r.get("setting") == s], cfg, spec, det).items()}
    tune, test = split(rows)
    name = f"presence {rows[0].get('setting', '')}".strip()
    truth = [r["present"] for r in test]
    answers = [vlm.parse_yes_no(ask(cfg, "presence", r)) for r in tqdm(test, f"{name}, VLM")]
    res = {"vlm": {**ev.presence_metrics(truth, [bool(a) for a in answers]),
                   "unparsed": sum(a is None for a in answers) / len(answers)}}
    best_box = lambda r: max((s for _, s in det.detect(r["image"], r["label"])), default=0.0)
    for who, score in [("specialist", lambda r: spec.score(r["image"], r["label"])), ("detector", best_box)]:
        thr = ev.tune_threshold([score(r) for r in tqdm(tune, f"{name}, {who} tune")], [r["present"] for r in tune])
        res[who] = {**ev.presence_metrics(truth, [score(r) >= thr for r in tqdm(test, f"{name}, {who} test")]),
                    "threshold": thr}
    return res


def box_split(preds, rows, thr):
    """Precision/recall on queries whose class is in the image, false boxes on the others."""
    pos = [i for i, r in enumerate(rows) if r["present"]]
    neg = [i for i, r in enumerate(rows) if not r["present"]]
    p, r_, f = ev.box_metrics([preds[i] for i in pos], [rows[i]["boxes"] for i in pos], thr)
    return {"precision_pos": p, "recall_pos": r_, "f1_pos": f,
            "neg_with_box": sum(bool(preds[i]) for i in neg) / len(neg),
            "boxes_per_neg": sum(len(preds[i]) for i in neg) / len(neg)}


def localization(rows, cfg, spec):
    tune, test = split(rows)
    boxes = lambda rs: [r["boxes"] for r in rs]
    scored = lambda rs, part: [spec.detect(r["image"], r["label"]) for r in tqdm(rs, f"localization, specialist {part}")]
    thr = cfg["iou_threshold"]
    vlm_boxes = [vlm.parse_boxes(ask(cfg, "localization", r), Image.open(r["image"]).size, cfg["vlm"]["box_format"])
                 for r in tqdm(test, "localization, VLM")]
    p, r_, f = ev.box_metrics(vlm_boxes, boxes(test), thr)
    # the specialist's score threshold is chosen on the tuning part, then applied to the test part
    _, t = ev.best_f1(scored(tune, "tune"), boxes(tune), thr)
    sp_boxes = ev.apply_threshold(scored(test, "test"), t)
    sp, sr, sf = ev.box_metrics(sp_boxes, boxes(test), thr)
    return {"vlm": {"precision": p, "recall": r_, "f1": f, "empty_answers": sum(not b for b in vlm_boxes) / len(test),
                    **box_split(vlm_boxes, test, thr)},
            "specialist": {"precision": sp, "recall": sr, "f1": sf, "threshold": t, **box_split(sp_boxes, test, thr)}}


def counting(rows, cfg, spec):
    """specialist: CountGD++ with its confidence threshold chosen on the tuning part (lowest MAE),
    like the other two specialists. specialist_demo: the authors' default threshold."""
    tune, test = split(rows)
    truth = [r["count"] for r in test]
    answers = [vlm.parse_count(ask(cfg, "counting", r)) for r in tqdm(test, "counting, VLM")]
    at = lambda scores, t: [sum(s > t for s in ss) for ss in scores]
    tune_scores = [spec.scores(r["image"], r["label"]) for r in tqdm(tune, "counting, specialist tune")]
    grid = [k / 100 for k in range(5, 100)]  # from scores() min_score up
    t = min(grid, key=lambda t: ev.count_metrics([r["count"] for r in tune], at(tune_scores, t))["mae"])
    test_scores = [spec.scores(r["image"], r["label"]) for r in tqdm(test, "counting, specialist test")]
    preds = {"vlm": [a or 0 for a in answers], "specialist": at(test_scores, t),
             "specialist_demo": at(test_scores, spec.DEMO_THRESH)}
    # per-query counts, to analyse errors without the models
    (Path(cfg["output_dir"]) / "predictions" / "counting.jsonl").write_text(
        "".join(json.dumps({**r, **{who: p[i] for who, p in preds.items()}}) + "\n" for i, r in enumerate(test)))
    # most queries are negatives (count 0): also report by true count
    bins = {"0": (0, 0), "1-3": (1, 3), "4-9": (4, 9), "10+": (10, float("inf"))}
    res = {}
    for who, p in preds.items():
        res[who] = ev.count_metrics(truth, p)
        for b, (lo, hi) in bins.items():
            idx = [i for i, t_ in enumerate(truth) if lo <= t_ <= hi]
            res[who] |= {f"{k}_{b}": v for k, v in ev.count_metrics([truth[i] for i in idx], [p[i] for i in idx]).items()}
            res[who][f"n_{b}"] = len(idx)
    res["vlm"]["unparsed"] = sum(a is None for a in answers) / len(answers)
    res["specialist"]["threshold"], res["specialist_demo"]["threshold"] = t, spec.DEMO_THRESH
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    cfg = yaml.safe_load(Path(ap.parse_args().config).read_text())
    from .models import specialist as sp

    # models load on the first cache miss, so a rerun on cached outputs needs no GPU
    det = {"yolo_world": sp.YoloWorld, "grounding_dino": sp.GroundingDino}[cfg["localization_specialist"]]()
    jobs = {"presence": lambda rows: presence(rows, cfg, sp.SigLIP2(), det),
            "localization": lambda rows: localization(rows, cfg, det),
            "counting": lambda rows: counting(rows, cfg, sp.CountGDPlusPlus())}
    out = Path(cfg["output_dir"])
    out.mkdir(parents=True, exist_ok=True)
    lines = []
    for task, path in cfg["data"].items():
        res = jobs[task](load(path))
        (out / f"{task}.json").write_text(json.dumps(res, indent=2))
        lines += [(task, who, k, v) for who, m in res.items() for k, v in m.items()]
    with open(out / "metrics.csv", "w", newline="") as f:
        csv.writer(f).writerows([("task", "model", "metric", "value"), *lines])


if __name__ == "__main__":
    main()
