"""One specialist per task: SigLIP 2 (presence), YOLO-World or Grounding DINO (localization), CountGD++ (counting).

Models load on the first cache miss: with every output in CACHE, the analysis runs without the GPU.
"""

from PIL import Image

from ..cache import JsonlCache

# raw outputs (scores, boxes with scores), before any threshold
CACHE = JsonlCache("results/predictions/specialist_outputs.jsonl")


class SigLIP2:
    """Presence score: probability that the image matches "a photo of a {label}"."""

    def __init__(self, name="google/siglip2-so400m-patch14-384", device="cuda"):
        self.name, self.device, self.model = name, device, None

    def score(self, image_path, label):
        return CACHE.get(["SigLIP2", self.name, str(image_path), label], lambda: self._score(image_path, label))

    def _score(self, image_path, label):
        import torch
        from transformers import AutoModel, AutoProcessor

        if self.model is None:
            # slow processor, stated explicitly: the fast one gives slightly different scores
            self.processor = AutoProcessor.from_pretrained(self.name, use_fast=False)
            self.model = AutoModel.from_pretrained(self.name).to(self.device).eval()

        inputs = self.processor(
            text=[f"a photo of a {label}"], images=Image.open(image_path).convert("RGB"),
            padding="max_length", max_length=64, return_tensors="pt",
        ).to(self.device)
        with torch.no_grad():
            return torch.sigmoid(self.model(**inputs).logits_per_image)[0, 0].item()


class GroundingDino:
    """Boxes with scores for one text label."""

    def __init__(self, name="IDEA-Research/grounding-dino-base", device="cuda"):
        self.name, self.device, self.model = name, device, None

    def detect(self, image_path, label, min_score=0.05):
        """List of ((x1, y1, x2, y2), score) in pixels, with a low cutoff so that the
        score threshold can be swept afterwards (evaluate.best_f1)."""
        return CACHE.get(["GroundingDino", self.name, str(image_path), label, min_score],
                         lambda: self._detect(image_path, label, min_score))

    def _detect(self, image_path, label, min_score):
        import torch
        from transformers import AutoModelForZeroShotObjectDetection, AutoProcessor

        if self.model is None:
            self.processor = AutoProcessor.from_pretrained(self.name)
            self.model = AutoModelForZeroShotObjectDetection.from_pretrained(self.name).to(self.device).eval()

        image = Image.open(image_path).convert("RGB")
        inputs = self.processor(images=image, text=f"{label}.", return_tensors="pt").to(self.device)
        with torch.no_grad():
            out = self.model(**inputs)
        res = self.processor.post_process_grounded_object_detection(
            out, inputs.input_ids, threshold=min_score, text_threshold=min_score,
            target_sizes=[image.size[::-1]],
        )[0]
        return [([round(v, 1) for v in b.tolist()], round(s.item(), 4)) for b, s in zip(res["boxes"], res["scores"])]


class YoloWorld:
    """Boxes with scores for one text label. Plain PyTorch through ultralytics: no custom CUDA ops."""

    def __init__(self, name="yolov8s-worldv2.pt", device="cuda"):
        self.name, self.device, self.model = name, device, None

    def detect(self, image_path, label, min_score=0.001):
        """Same output as GroundingDino.detect: list of ((x1, y1, x2, y2), score) in pixels."""
        return CACHE.get(["YoloWorld", self.name, str(image_path), label, min_score],
                         lambda: self._detect(image_path, label, min_score))

    def _detect(self, image_path, label, min_score):
        if self.model is None:
            from ultralytics import YOLOWorld

            self.model = YOLOWorld(self.name)  # weights are downloaded on first use (*.pt is git-ignored)
        self.model.set_classes([label])
        res = self.model.predict(image_path, conf=min_score, device=self.device, verbose=False)[0]
        # rounded: 0.1 px and 1e-4 in score change no metric and keep the cache small
        return [([round(v, 1) for v in b.tolist()], round(s.item(), 4)) for b, s in zip(res.boxes.xyxy, res.boxes.conf)]


class CountGDPlusPlus:
    """Count = number of boxes above a confidence threshold, text prompt only, no exemplar.

    Code and weights: Hugging Face model nikigoli/CountGDPlusPlus (see README), loaded from
    third_party/countgdpp. Without the compiled deformable-attention op (it does not build under
    ROCm), the model uses its own pure-PyTorch version: slower, same maths.
    shortcut: the whole image is resized to 800 px like the authors' count() helper, without the
    paper's adaptive cropping and pseudo-exemplars; counts on very dense images may be lower.
    """

    DEMO_THRESH = 0.23  # the authors' default

    def __init__(self, root="third_party/countgdpp", device="cuda"):
        self.root, self.device, self.model = root, device, None

    def scores(self, image_path, label, min_score=0.05):
        """Confidence of every box above min_score; the count at threshold t is sum(s > t)."""
        return CACHE.get(["CountGDPlusPlus", str(image_path), label, min_score],
                         lambda: self._scores(image_path, label, min_score))

    def _scores(self, image_path, label, min_score):
        if self.model is None:
            import sys
            from pathlib import Path

            root = str(Path(self.root).resolve())
            sys.path.insert(0, root)
            from countgdpp import CountGDPlusPlus as Model, count

            self.model = Model.from_pretrained(root).to(self.device).eval()
            self._count = count
        res = self._count(self.model, image_path, label, conf_thresh=min_score)
        return sorted((round(float(s), 4) for s in res["scores"]), reverse=True)
