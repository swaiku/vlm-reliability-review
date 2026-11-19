"""Metrics for the three tasks: boxes (IoU, P/R/F1), presence (yes/no) and counting."""

import math


def iou(a, b):
    """IoU of two boxes given as (x1, y1, x2, y2)."""
    iw = min(a[2], b[2]) - max(a[0], b[0])
    ih = min(a[3], b[3]) - max(a[1], b[1])
    inter = max(0.0, iw) * max(0.0, ih)
    union = (a[2] - a[0]) * (a[3] - a[1]) + (b[2] - b[0]) * (b[3] - b[1]) - inter
    return inter / union if union > 0 else 0.0


def match(pred, gt, thr=0.5):
    """One-to-one greedy matching by descending IoU. Returns (tp, fp, fn)."""
    pairs = sorted(
        ((iou(p, g), i, j) for i, p in enumerate(pred) for j, g in enumerate(gt)),
        reverse=True,
    )
    used_p, used_g, tp = set(), set(), 0
    for v, i, j in pairs:
        if v < thr:
            break
        if i not in used_p and j not in used_g:
            used_p.add(i)
            used_g.add(j)
            tp += 1
    return tp, len(pred) - tp, len(gt) - tp


def prf(tp, fp, fn):
    p = tp / (tp + fp) if tp + fp else 0.0
    r = tp / (tp + fn) if tp + fn else 0.0
    f = 2 * p * r / (p + r) if p + r else 0.0
    return p, r, f


def box_metrics(preds, gts, thr=0.5):
    """Dataset-level P/R/F1 at one IoU threshold. preds/gts: lists (one per image) of box lists."""
    tp = fp = fn = 0
    for p, g in zip(preds, gts):
        a, b, c = match(p, g, thr)
        tp, fp, fn = tp + a, fp + b, fn + c
    return prf(tp, fp, fn)


def best_f1(scored_preds, gts, iou_thr=0.5, step=0.01):
    """Best F1 over score thresholds (the protocol used for detectors in the Rex-Omni paper).

    scored_preds: per image, a list of (box, score). Returns (best_f1, threshold).
    VLM boxes have no score: call box_metrics directly for them.
    """
    best = (0.0, 0.0)
    for k in range(int(round(1 / step)) + 1):
        t = k * step
        f = box_metrics(apply_threshold(scored_preds, t), gts, iou_thr)[2]
        if f > best[0]:
            best = (f, t)
    return best


def apply_threshold(scored_preds, t):
    """Keep the boxes whose score is at least t. Returns one box list per image."""
    return [[b for b, s in img if s >= t] for img in scored_preds]


def presence_metrics(y_true, y_pred):
    """Accuracy, precision, recall, F1 for booleans (True = object present), plus the yes ratio."""
    tp = sum(t and p for t, p in zip(y_true, y_pred))
    fp = sum(p and not t for t, p in zip(y_true, y_pred))
    fn = sum(t and not p for t, p in zip(y_true, y_pred))
    acc = sum(t == p for t, p in zip(y_true, y_pred)) / len(y_true)
    p, r, f = prf(tp, fp, fn)
    return {"acc": acc, "precision": p, "recall": r, "f1": f, "yes_ratio": sum(y_pred) / len(y_pred)}


def count_metrics(y_true, y_pred):
    """Exact-match accuracy, MAE and RMSE for integer counts."""
    n = len(y_true)
    err = [abs(p - t) for t, p in zip(y_true, y_pred)]
    return {
        "exact": sum(e == 0 for e in err) / n,
        "mae": sum(err) / n,
        "rmse": math.sqrt(sum(e * e for e in err) / n),
    }


def tune_threshold(scores, y_true):
    """Score threshold that maximizes accuracy on a tuning split (for score-based presence)."""
    best = (-1.0, 0.0)
    for t in sorted(set(scores)):
        acc = sum((s >= t) == y for s, y in zip(scores, y_true)) / len(y_true)
        if acc > best[0]:
            best = (acc, t)
    return best[1]
