"""VLM through a local Ollama server, plus parsers for its text answers."""

import base64
import json
import re
import urllib.request

from ..cache import JsonlCache

# Every answer is appended here as soon as it arrives, so an interrupted run resumes where it
# stopped, and a question repeated across the POPE settings is asked once (answers are deterministic).
CACHE = JsonlCache("results/predictions/vlm_answers.jsonl")


def ask(model, image_path, prompt, host="http://localhost:11434", think=False, num_ctx=4096, seed=0):
    """One deterministic question about one image. Returns the answer text."""
    return CACHE.get([model, str(image_path), prompt, think, num_ctx, seed],
                     lambda: _ask(model, image_path, prompt, host, think, num_ctx, seed))


def _ask(model, image_path, prompt, host, think, num_ctx, seed):
    with open(image_path, "rb") as f:
        img = base64.b64encode(f.read()).decode()
    body = {
        "model": model,
        "stream": False,
        "think": think,  # fixed for every model: reasoning mode changes the results
        "messages": [{"role": "user", "content": prompt, "images": [img]}],
        "options": {"temperature": 0, "seed": seed, "num_ctx": num_ctx},
    }
    req = urllib.request.Request(
        f"{host}/api/chat", json.dumps(body).encode(), {"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=300) as r:
        return json.load(r)["message"]["content"]


def parse_yes_no(text):
    """True for yes, False for no, None if neither word starts the answer."""
    m = re.match(r"\W*(yes|no)\b", text.strip().lower())
    return None if m is None else m.group(1) == "yes"


def parse_count(text):
    """First integer in the answer, or None."""
    m = re.search(r"\d+", text)
    return int(m.group()) if m else None


def parse_boxes(text, size, box_format="pixels"):
    """Boxes (x1, y1, x2, y2) in pixels from a JSON list in the answer.

    box_format: "pixels", "norm1000" (0-999 grid) or "norm1" (0-1). `size` is (width, height).
    Accepts [x1,y1,x2,y2] or {"bbox_2d": [...]} items. Unparsable text gives an empty list.
    """
    m = re.search(r"\[.*\]", text, re.S)
    if m is None:
        return []
    try:
        items = json.loads(m.group())
    except json.JSONDecodeError:
        return []
    scale = {"pixels": (1, 1), "norm1000": (size[0] / 1000, size[1] / 1000), "norm1": size}[box_format]
    boxes = []
    for it in items:
        b = it.get("bbox_2d") if isinstance(it, dict) else it
        if isinstance(b, list) and len(b) == 4 and all(isinstance(v, (int, float)) for v in b):
            boxes.append((b[0] * scale[0], b[1] * scale[1], b[2] * scale[0], b[3] * scale[1]))
    return boxes
