"""Build the main-set JSONL files from POPE (COCO val2014) and the COCO annotations.

Inputs (see README): data/pope/coco_pope_{random,popular,adversarial}.json and
data/coco/instances_val2014.json. Missing images are downloaded to data/coco/val2014/.
Usage: python -m src.convert [--tune-frac 0.2] [--seed 0]
"""

import argparse
import json
import random
import re
import urllib.request
from collections import defaultdict
from pathlib import Path

SETTINGS = ("random", "popular", "adversarial")
IMG_URL = "http://images.cocodataset.org/val2014/{}"


def pope_label(text):
    m = re.fullmatch(r"Is there an? (.+) in the image\?", text.strip())
    assert m, f"unexpected POPE question: {text!r}"
    return m.group(1)


def build(pope, coco, img_dir, tune_frac, seed):
    """pope: {setting: [question rows]}, coco: instances json. Returns {task: rows}."""
    names = {c["id"]: c["name"] for c in coco["categories"]}
    by_file = {im["file_name"]: im["id"] for im in coco["images"]}
    boxes, crowd = defaultdict(list), set()
    for a in coco["annotations"]:
        key = (a["image_id"], names[a["category_id"]])
        if a["iscrowd"]:
            crowd.add(key)
        else:
            x, y, w, h = a["bbox"]
            boxes[key].append([x, y, x + w, y + h])

    files = sorted({q["image"] for qs in pope.values() for q in qs})
    order = files[:]
    random.Random(seed).shuffle(order)
    split = {f: "tune" if i < round(tune_frac * len(order)) else "test" for i, f in enumerate(order)}
    path = lambda f: str(img_dir / f)

    presence, absent = [], defaultdict(set)
    for s in SETTINGS:
        for q in pope[s]:
            label, present = pope_label(q["text"]), q["label"] == "yes"
            presence.append({"image": path(q["image"]), "task": "presence", "label": label, "present": present,
                             "setting": s, "split": split[q["image"]]})
            if not present:
                absent[q["image"]].add(label)

    targets = []
    for f in files:
        iid = by_file[f]
        present = sorted({lab for (i, lab) in boxes if i == iid})
        for lab in present:
            targets.append((f, lab, boxes[(iid, lab)]))
        for lab in sorted(absent[f]):
            # a POPE "no" class must have no COCO instance, crowd included
            assert (iid, lab) not in boxes and (iid, lab) not in crowd, (f, lab)
            targets.append((f, lab, []))
    row = lambda task, f, lab, b: {"image": path(f), "task": task, "label": lab, "present": bool(b),
                                   "boxes": b, "count": len(b), "split": split[f]}
    return {
        "presence": presence,
        "localization": [row("localization", *t) for t in targets],
        "counting": [row("counting", *t) for t in targets],
    }


def download(files, img_dir):
    img_dir.mkdir(parents=True, exist_ok=True)
    for f in files:
        dst = img_dir / f
        if not dst.exists():
            tmp = dst.with_suffix(".part")
            urllib.request.urlretrieve(IMG_URL.format(f), tmp)
            tmp.rename(dst)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default="data")
    ap.add_argument("--tune-frac", type=float, default=0.2)
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()
    data = Path(args.data)
    pope = {s: [json.loads(l) for l in (data / f"pope/coco_pope_{s}.json").read_text().splitlines() if l.strip()]
            for s in SETTINGS}
    coco = json.loads((data / "coco/instances_val2014.json").read_text())
    img_dir = data / "coco/val2014"
    out = build(pope, coco, img_dir, args.tune_frac, args.seed)
    download(sorted({Path(r["image"]).name for r in out["presence"]}), img_dir)
    for task, rows in out.items():
        (data / f"{task}.jsonl").write_text("".join(json.dumps(r) + "\n" for r in rows))
        n_img = len({r["image"] for r in rows})
        print(f"{task}: {len(rows)} rows, {n_img} images, "
              f"{sum(r['present'] for r in rows)} positive, {sum(r['split'] == 'tune' for r in rows)} tune")


if __name__ == "__main__":
    main()
