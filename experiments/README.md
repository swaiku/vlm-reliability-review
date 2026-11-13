# Experiments

One VLM (served by Ollama) against one specialist per task, on existing benchmarks:

| Task | VLM output | Specialist |
|---|---|---|
| Presence | yes/no | SigLIP 2 score, threshold tuned on a `tune` split; also the localization specialist's best box score (`detector`) |
| Localization | boxes in text, no score | YOLO-World (or Grounding DINO, `localization_specialist` in the config), best-F1 threshold (Rex-Omni protocol) |
| Counting | number | CountGD++ (text only), confidence threshold tuned on `tune` (lowest MAE); `specialist_demo` uses the authors' 0.23 |

## Status

Run on an AMD RX 7900 XTX (ROCm, PyTorch 2.15+rocm10.0). `just test` checks the metrics, parsers and converter. Checked on the GPU: Ollama (native install, not the Homebrew build, which is CPU only), the VLM box format (`norm1000` for qwen3.8), YOLO-World, SigLIP 2, and a 10-image end-to-end run. Out-of-domain sets (Roboflow100-VL, FSC-147) were dropped from the study.

## Setup

Requires [uv](https://docs.astral.sh/uv/) and a running Ollama server with the VLM pulled (`ollama pull <tag>`).

```bash
just setup   # or: cd experiments && uv sync
```

`pyproject.toml` takes torch and the ROCm runtime from the PyTorch ROCm index (Linux x86_64 only). `transformers` stays below 4.50 for CountGD++.

CountGD++ code and weights (896 MB, not versioned):

```bash
uv run python -c "from huggingface_hub import snapshot_download; snapshot_download('nikigoli/CountGDPlusPlus', revision='06bd674ecd2d18ea55ec0dd9183fa24603dfa7e1', local_dir='third_party/countgdpp')"
```

## Data

Not versioned. One JSONL file per task in `data/` (row format in `src/run.py`), with a `split` of `tune` or `test` chosen by image. The tuning part sets the specialists' score thresholds.

| Set | Source | Used for |
|---|---|---|
| Main | The 500 COCO val images of POPE (3 settings, 6 questions per image) | presence (POPE questions); localization and counting from the COCO annotations of the same images, crowd regions excluded; absent POPE classes give negative queries (no box, count 0) |

`python -m src.convert` builds the main-set files (POPE questions from `data/pope/`, COCO val2014 annotations from `data/coco/instances_val2014.json`) and downloads the 500 images.

## Run

```bash
just eval --config configs/default.yaml
```

Metrics go to `results/metrics.csv` and `results/<task>.json`. Every model output is appended as it arrives, VLM answers to `results/predictions/vlm_answers.jsonl` and raw specialist outputs (scores, boxes with scores, before any threshold) to `results/predictions/specialist_outputs.jsonl`: stop with Ctrl+C at any time and rerun the same command to resume. Once both files are complete, a rerun recomputes every metric in minutes, and loads no model. Per-query counts go to `results/predictions/counting.jsonl`. Then `python -m src.bootstrap --config configs/default.yaml` writes 95% intervals by bootstrap over test images to `results/bootstrap.json`, from the caches only. Delete the caches to start over (for example after changing a prompt or the data).

## Reproducibility

Pin the exact Ollama tag, its quantization, the prompts, the IoU threshold and the seed in `configs/`. Record the hardware here.
