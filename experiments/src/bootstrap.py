"""95% confidence intervals by bootstrap over test images, from the cached model outputs (no GPU).

Run after src.run (it reads the thresholds in results/<task>.json). Images are resampled, not
queries, because the queries of one image are correlated. Writes results/bootstrap.json.
Usage: python -m src.bootstrap --config configs/default.yaml
"""

import argparse
import json
from pathlib import Path

import numpy as np
import yaml
from PIL import Image

from . import evaluate as ev
from .models import vlm
from .run import ask, load, split

N, SEED = 1000, 0


def per_image(rows, values):
    """Sum per-query rows of numbers by image: array (n_images, n_columns)."""
    idx = {im: i for i, im in enumerate(sorted({r["image"] for r in rows}))}
    out = np.zeros((len(idx), len(values[0])))
    for r, v in zip(rows, values):
        out[idx[r["image"]]] += v
    return out


def ci(sums, metric, rng):
    """Point value and 95% percentile interval of metric(column sums) over image resamples."""
    draws = rng.integers(0, len(sums), (N, len(sums)))
    vals = np.array([metric(sums[d].sum(0)) for d in draws])
    return [float(metric(sums.sum(0))), *map(float, np.percentile(vals, [2.5, 97.5]))]


def f1(tp, fp, fn):
    return 2 * tp / (2 * tp + fp + fn) if tp else 0.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    cfg = yaml.safe_load(Path(ap.parse_args().config).read_text())
    from .models import specialist as sp

    out, rng, res = Path(cfg["output_dir"]), np.random.default_rng(SEED), {}
    det = {"yolo_world": sp.YoloWorld, "grounding_dino": sp.GroundingDino}[cfg["localization_specialist"]]()
    siglip = sp.SigLIP2()
    thr = json.loads((out / "presence.json").read_text())

    # presence: F1 per POPE setting, and the VLM - specialist difference
    rows = load(cfg["data"]["presence"])
    for s in sorted({r["setting"] for r in rows}):
        _, test = split([r for r in rows if r["setting"] == s])
        preds = {"vlm": [bool(vlm.parse_yes_no(ask(cfg, "presence", r))) for r in test],
                 "specialist": [siglip.score(r["image"], r["label"]) >= thr[f"specialist_{s}"]["threshold"] for r in test],
                 "detector": [max((x for _, x in det.detect(r["image"], r["label"])), default=0.0)
                              >= thr[f"detector_{s}"]["threshold"] for r in test]}
        # columns per model: tp, fp, fn
        cols = [[c for p in preds.values() for c in (p[i] and t["present"], p[i] and not t["present"], t["present"] and not p[i])]
                for i, t in enumerate(test)]
        sums, k = per_image(test, cols), {who: 3 * j for j, who in enumerate(preds)}
        for who in preds:
            res[f"presence_{s}_f1_{who}"] = ci(sums, lambda c, j=k[who]: f1(*c[j:j + 3]), rng)
        for who in ("specialist", "detector"):
            res[f"presence_{s}_f1_vlm_minus_{who}"] = ci(
                sums, lambda c, j=k[who]: f1(*c[0:3]) - f1(*c[j:j + 3]), rng)

    # localization: F1 at the IoU threshold
    _, test = split(load(cfg["data"]["localization"]))
    t = json.loads((out / "localization.json").read_text())["specialist"]["threshold"]
    v = [vlm.parse_boxes(ask(cfg, "localization", r), Image.open(r["image"]).size, cfg["vlm"]["box_format"]) for r in test]
    s_ = ev.apply_threshold([det.detect(r["image"], r["label"]) for r in test], t)
    cols = [[*ev.match(a, r["boxes"], cfg["iou_threshold"]), *ev.match(b, r["boxes"], cfg["iou_threshold"])]
            for a, b, r in zip(v, s_, test)]
    sums = per_image(test, cols)
    res["localization_f1_vlm"] = ci(sums, lambda c: f1(*c[0:3]), rng)
    res["localization_f1_specialist"] = ci(sums, lambda c: f1(*c[3:6]), rng)
    res["localization_f1_vlm_minus_specialist"] = ci(sums, lambda c: f1(*c[0:3]) - f1(*c[3:6]), rng)

    # counting: MAE, from the per-query counts written by src.run
    rows = load(out / "predictions" / "counting.jsonl")
    who = ("vlm", "specialist", "specialist_demo")
    sums = per_image(rows, [[1, *(abs(r[w] - r["count"]) for w in who)] for r in rows])
    for j, w in enumerate(who, 1):
        res[f"counting_mae_{w}"] = ci(sums, lambda c, j=j: c[j] / c[0], rng)
    res["counting_mae_vlm_minus_specialist"] = ci(sums, lambda c: (c[1] - c[2]) / c[0], rng)

    (out / "bootstrap.json").write_text(json.dumps(res, indent=2))
    for k_, (p, lo, hi) in res.items():
        print(f"{k_:45s} {p:7.3f}  [{lo:7.3f}, {hi:7.3f}]")


if __name__ == "__main__":
    main()
