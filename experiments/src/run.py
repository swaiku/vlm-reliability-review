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


def presence(rows, cfg, spec):
    """Metrics per POPE setting (random, popular, adversarial), as in POPE."""
    settings = sorted({r.get("setting", "all") for r in rows})
    if len(settings) > 1:
        return {f"{who}_{s}": m for s in settings
                for who, m in presence([r for r in rows if r.get("setting") == s], cfg, spec).items()}
    tune = [r for r in rows if r["split"] == "tune"]
    test = [r for r in rows if r["split"] == "test"]
    name = f"presence {rows[0].get('setting', '')}".strip()
    thr = ev.tune_threshold([spec.score(r["image"], r["label"]) for r in tqdm(tune, f"{name}, specialist tune")],
                            [r["present"] for r in tune])
    truth = [r["present"] for r in test]
    answers = [vlm.parse_yes_no(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["presence"].format(**r),
                                        think=cfg["vlm"]["think"])) for r in tqdm(test, f"{name}, VLM")]
    return {
        "vlm": {**ev.presence_metrics(truth, [bool(a) for a in answers]),
                "unparsed": sum(a is None for a in answers) / len(answers)},
        "specialist": {**ev.presence_metrics(truth, [spec.score(r["image"], r["label"]) >= thr for r in tqdm(test, f"{name}, specialist test")]),
                       "threshold": thr},
    }


def localization(rows, cfg, spec):
    tune = [r for r in rows if r["split"] == "tune"]
    test = [r for r in rows if r["split"] == "test"]
    boxes = lambda rs: [[tuple(b) for b in r["boxes"]] for r in rs]
    scored = lambda rs, part: [spec.detect(r["image"], r["label"]) for r in tqdm(rs, f"localization, specialist {part}")]
    thr = cfg["iou_threshold"]
    vlm_boxes = [vlm.parse_boxes(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["localization"].format(**r),
                                         think=cfg["vlm"]["think"]),
                                 Image.open(r["image"]).size, cfg["vlm"]["box_format"]) for r in tqdm(test, "localization, VLM")]
    p, r_, f = ev.box_metrics(vlm_boxes, boxes(test), thr)
    # the specialist's score threshold is chosen on the tuning part, then applied to the test part
    _, t = ev.best_f1(scored(tune, "tune"), boxes(tune), thr)
    sp, sr, sf = ev.box_metrics(ev.apply_threshold(scored(test, "test"), t), boxes(test), thr)
    return {"vlm": {"precision": p, "recall": r_, "f1": f, "empty_answers": sum(not b for b in vlm_boxes) / len(test)},
            "specialist": {"precision": sp, "recall": sr, "f1": sf, "threshold": t}}


def counting(rows, cfg, spec):
    test = [r for r in rows if r["split"] == "test"]
    truth = [r["count"] for r in test]
    answers = [vlm.parse_count(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["counting"].format(**r),
                                       think=cfg["vlm"]["think"])) for r in tqdm(test, "counting, VLM")]
    preds = {"vlm": [a or 0 for a in answers],
             "specialist": [spec.count(r["image"], r["label"]) for r in tqdm(test, "counting, specialist")]}
    # per-query counts, to analyse errors without rerunning the specialist
    (Path(cfg["output_dir"]) / "predictions" / "counting.jsonl").write_text(
        "".join(json.dumps({**r, "vlm": v, "specialist": s}) + "\n" for r, v, s in zip(test, *preds.values())))
    # most queries are negatives (count 0): also report by true count
    bins = {"0": (0, 0), "1-3": (1, 3), "4-9": (4, 9), "10+": (10, float("inf"))}
    res = {}
    for who, p in preds.items():
        res[who] = ev.count_metrics(truth, p)
        for b, (lo, hi) in bins.items():
            idx = [i for i, t in enumerate(truth) if lo <= t <= hi]
            res[who] |= {f"{k}_{b}": v for k, v in ev.count_metrics([truth[i] for i in idx], [p[i] for i in idx]).items()}
            res[who][f"n_{b}"] = len(idx)
    res["vlm"]["unparsed"] = sum(a is None for a in answers) / len(answers)
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    cfg = yaml.safe_load(Path(ap.parse_args().config).read_text())
    from .models import specialist as sp

    loc = {"yolo_world": sp.YoloWorld, "grounding_dino": sp.GroundingDino}[cfg["localization_specialist"]]
    makers = {"presence": (presence, sp.SigLIP2), "localization": (localization, loc),
              "counting": (counting, sp.CountGDPlusPlus)}
    out = Path(cfg["output_dir"])
    out.mkdir(parents=True, exist_ok=True)
    lines = []
    for task, path in cfg["data"].items():
        fn, spec_cls = makers[task]
        done = out / f"{task}.json"
        if done.exists():  # finished in an earlier run (only VLM answers are cached); delete it to recompute
            res = json.loads(done.read_text())
            print(f"{task}: reusing {done}")
        else:
            res = fn(load(path), cfg, spec_cls())
            done.write_text(json.dumps(res, indent=2))
        lines += [(task, who, k, v) for who, m in res.items() for k, v in m.items()]
    with open(out / "metrics.csv", "w", newline="") as f:
        csv.writer(f).writerows([("task", "model", "metric", "value"), *lines])


if __name__ == "__main__":
    main()
