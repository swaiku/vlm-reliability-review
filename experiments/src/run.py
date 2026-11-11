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

from . import evaluate as ev
from .models import vlm


def load(path):
    return [json.loads(line) for line in Path(path).read_text().splitlines() if line.strip()]


def presence(rows, cfg, spec):
    tune = [r for r in rows if r["split"] == "tune"]
    test = [r for r in rows if r["split"] == "test"]
    thr = ev.tune_threshold([spec.score(r["image"], r["label"]) for r in tune], [r["present"] for r in tune])
    truth = [r["present"] for r in test]
    answers = [vlm.parse_yes_no(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["presence"].format(**r),
                                        think=cfg["vlm"]["think"])) for r in test]
    return {
        "vlm": {**ev.presence_metrics(truth, [bool(a) for a in answers]),
                "unparsed": sum(a is None for a in answers) / len(answers)},
        "specialist": {**ev.presence_metrics(truth, [spec.score(r["image"], r["label"]) >= thr for r in test]),
                       "threshold": thr},
    }


def localization(rows, cfg, spec):
    test = [r for r in rows if r["split"] == "test"]
    gts = [[tuple(b) for b in r["boxes"]] for r in test]
    thr = cfg["iou_threshold"]
    vlm_boxes = [vlm.parse_boxes(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["localization"].format(**r),
                                         think=cfg["vlm"]["think"]),
                                 Image.open(r["image"]).size, cfg["vlm"]["box_format"]) for r in test]
    p, r_, f = ev.box_metrics(vlm_boxes, gts, thr)
    best, t = ev.best_f1([spec.detect(r["image"], r["label"]) for r in test], gts, thr)
    return {"vlm": {"precision": p, "recall": r_, "f1": f, "empty_answers": sum(not b for b in vlm_boxes) / len(test)},
            "specialist": {"f1_best_threshold": best, "threshold": t}}


def counting(rows, cfg, spec):
    test = [r for r in rows if r["split"] == "test"]
    truth = [r["count"] for r in test]
    answers = [vlm.parse_count(vlm.ask(cfg["vlm"]["model"], r["image"], cfg["prompts"]["counting"].format(**r),
                                       think=cfg["vlm"]["think"])) for r in test]
    return {"vlm": {**ev.count_metrics(truth, [a or 0 for a in answers]),
                    "unparsed": sum(a is None for a in answers) / len(answers)},
            "specialist": ev.count_metrics(truth, [spec.count(r["image"], r["label"]) for r in test])}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    cfg = yaml.safe_load(Path(ap.parse_args().config).read_text())
    from .models import specialist as sp

    loc = {"yolo_world": sp.YoloWorld, "grounding_dino": sp.GroundingDino}[cfg["localization_specialist"]]
    makers = {"presence": (presence, sp.SigLIP2), "localization": (localization, loc),
              "counting": (counting, sp.CountGD)}
    out = Path(cfg["output_dir"])
    out.mkdir(parents=True, exist_ok=True)
    lines = []
    for task, path in cfg["data"].items():
        fn, spec_cls = makers[task]
        res = fn(load(path), cfg, spec_cls())
        (out / f"{task}.json").write_text(json.dumps(res, indent=2))
        lines += [(task, who, k, v) for who, m in res.items() for k, v in m.items()]
    with open(out / "metrics.csv", "w", newline="") as f:
        csv.writer(f).writerows([("task", "model", "metric", "value"), *lines])


if __name__ == "__main__":
    main()
