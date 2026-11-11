"""One specialist per task: SigLIP 2 (presence), YOLO-World or Grounding DINO (localization), CountGD (counting).

Loaded lazily so the metrics and parsers work without torch. Not run yet: the GPU machine
is not available, so check the post-processing argument names against the installed
transformers version.
"""

from PIL import Image


class SigLIP2:
    """Presence score: probability that the image matches "a photo of a {label}"."""

    def __init__(self, name="google/siglip2-so400m-patch14-384", device="cuda"):
        from transformers import AutoModel, AutoProcessor

        self.processor = AutoProcessor.from_pretrained(name)
        self.model = AutoModel.from_pretrained(name).to(device).eval()
        self.device = device

    def score(self, image_path, label):
        import torch

        inputs = self.processor(
            text=[f"a photo of a {label}"], images=Image.open(image_path).convert("RGB"),
            padding="max_length", max_length=64, return_tensors="pt",
        ).to(self.device)
        with torch.no_grad():
            return torch.sigmoid(self.model(**inputs).logits_per_image)[0, 0].item()


class GroundingDino:
    """Boxes with scores for one text label."""

    def __init__(self, name="IDEA-Research/grounding-dino-base", device="cuda"):
        from transformers import AutoModelForZeroShotObjectDetection, AutoProcessor

        self.processor = AutoProcessor.from_pretrained(name)
        self.model = AutoModelForZeroShotObjectDetection.from_pretrained(name).to(device).eval()
        self.device = device

    def detect(self, image_path, label, min_score=0.05):
        """List of ((x1, y1, x2, y2), score) in pixels, with a low cutoff so that the
        score threshold can be swept afterwards (evaluate.best_f1)."""
        import torch

        image = Image.open(image_path).convert("RGB")
        inputs = self.processor(images=image, text=f"{label}.", return_tensors="pt").to(self.device)
        with torch.no_grad():
            out = self.model(**inputs)
        res = self.processor.post_process_grounded_object_detection(
            out, inputs.input_ids, threshold=min_score, text_threshold=min_score,
            target_sizes=[image.size[::-1]],
        )[0]
        return [(tuple(b.tolist()), s.item()) for b, s in zip(res["boxes"], res["scores"])]


class YoloWorld:
    """Boxes with scores for one text label. Plain PyTorch through ultralytics: no custom CUDA ops."""

    def __init__(self, name="yolov8s-worldv2.pt", device="cuda"):
        from ultralytics import YOLOWorld

        self.model = YOLOWorld(name)  # weights are downloaded on first use (*.pt is git-ignored)
        self.device = device

    def detect(self, image_path, label, min_score=0.001):
        """Same output as GroundingDino.detect: list of ((x1, y1, x2, y2), score) in pixels."""
        self.model.set_classes([label])
        res = self.model.predict(image_path, conf=min_score, device=self.device, verbose=False)[0]
        return [(tuple(b.tolist()), s.item()) for b, s in zip(res.boxes.xyxy, res.boxes.conf)]


class CountGD:
    """Official repo: https://github.com/niki-amini-naieni/CountGD (needs compiled deformable-attention ops).

    Not wrapped yet: check first that it builds under ROCm (see README).
    """

    def count(self, image_path, label):
        raise NotImplementedError("wrap the official CountGD inference script here")
