"""Self-check of metrics and parsers. Run: python -m tests.test_evaluate (from experiments/)."""

from src import evaluate as ev
from src.models import vlm

assert ev.iou((0, 0, 10, 10), (0, 0, 10, 10)) == 1.0
assert ev.iou((0, 0, 10, 10), (20, 20, 30, 30)) == 0.0
assert abs(ev.iou((0, 0, 10, 10), (5, 0, 15, 10)) - 1 / 3) < 1e-9

# one good box, one box with no match, one missed object
assert ev.match([(0, 0, 10, 10), (50, 50, 60, 60)], [(0, 0, 10, 9), (100, 100, 110, 110)]) == (1, 1, 1)
assert ev.box_metrics([[(0, 0, 10, 10)]], [[(0, 0, 10, 10)]]) == (1.0, 1.0, 1.0)

# a high-score good box and a low-score false box: the best threshold drops the false one
f, t = ev.best_f1([[((0, 0, 10, 10), 0.9), ((50, 50, 60, 60), 0.2)]], [[(0, 0, 10, 10)]])
assert f == 1.0 and 0.2 < t <= 0.9

# the threshold found on one set is applied to another: the false low-score box is removed
assert ev.apply_threshold([[((0, 0, 10, 10), 0.9), ((50, 50, 60, 60), 0.2)]], t) == [[(0, 0, 10, 10)]]

m = ev.presence_metrics([True, True, False, False], [True, False, False, True])
assert m["acc"] == 0.5 and m["yes_ratio"] == 0.5
assert ev.count_metrics([3, 5], [3, 7]) == {"exact": 0.5, "mae": 1.0, "rmse": 2 ** 0.5}
assert ev.tune_threshold([0.1, 0.4, 0.8], [False, False, True]) == 0.8

assert vlm.parse_yes_no("Yes, there is one.") is True and vlm.parse_yes_no("No.") is False
assert vlm.parse_yes_no("Maybe") is None
assert vlm.parse_count("There are 12 cars") == 12 and vlm.parse_count("none") is None
assert vlm.parse_boxes('[{"bbox_2d": [100, 200, 500, 600]}]', (1000, 2000), "norm1000") == [(100.0, 400.0, 500.0, 1200.0)]
assert vlm.parse_boxes("[]", (10, 10)) == [] and vlm.parse_boxes("no box", (10, 10)) == []
# converter: crowd boxes dropped, COCO xywh -> xyxy, POPE "no" classes become empty targets
from pathlib import Path
from src import convert

coco = {"categories": [{"id": 1, "name": "dog"}, {"id": 2, "name": "cat"}, {"id": 3, "name": "car"}],
        "images": [{"id": 7, "file_name": "a.jpg"}],
        "annotations": [{"image_id": 7, "category_id": 1, "bbox": [1, 2, 3, 4], "iscrowd": 0},
                        {"image_id": 7, "category_id": 1, "bbox": [0, 0, 9, 9], "iscrowd": 1},
                        {"image_id": 7, "category_id": 2, "bbox": [5, 5, 1, 1], "iscrowd": 0}]}
qs = [{"image": "a.jpg", "text": "Is there a dog in the image?", "label": "yes"},
      {"image": "a.jpg", "text": "Is there a car in the image?", "label": "no"}]
out = convert.build({s: qs for s in convert.SETTINGS}, coco, Path("img"), 0.0, 0)
assert len(out["presence"]) == 6 and {r["setting"] for r in out["presence"]} == set(convert.SETTINGS)
loc = {r["label"]: r for r in out["localization"]}
assert loc["dog"]["boxes"] == [[1, 2, 4, 6]] and loc["dog"]["count"] == 1
assert loc["cat"]["present"] and loc["car"] == {**loc["car"], "boxes": [], "count": 0, "present": False}
assert all(r["split"] == "test" and r["image"] == str(Path("img/a.jpg")) for r in out["counting"])
print("ok")
