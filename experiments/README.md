# Experiments

One VLM (served by Ollama) against one specialist per task, on the 500 COCO images of POPE:

| Task | VLM output | Specialist |
|---|---|---|
| Presence | yes/no | SigLIP 2 (so400m, 384 px) score of "a photo of a {class}", threshold that maximizes accuracy on `tune`, per POPE setting; also YOLO-World read as a presence detector (`detector`: best box score, same tuning) |
| Localization | boxes in text (0-999 grid), no score | YOLO-World (`yolov8s-worldv2`), boxes above 0.001, threshold that maximizes F1 at IoU 0.5 on `tune` (Rex-Omni protocol) |
| Counting | number | CountGD++ (class name only, no exemplar), count = boxes above a threshold, lowest MAE on `tune` over 0.05-0.99; `specialist_demo` uses the authors' 0.23 |

`localization_specialist: grounding_dino` in the config swaps YOLO-World for Grounding DINO; the paper uses YOLO-World only.

## Status

Full run done: VLM answers on 12 November 2026, specialist outputs on 13 November 2026. The metrics in `results/` are the ones reported in the paper. Out-of-domain sets (Roboflow100-VL, FSC-147) were dropped from the study.

## Setup

Requires [uv](https://docs.astral.sh/uv/), [just](https://github.com/casey/just) (optional), and an Ollama server with the VLM pulled (`ollama pull qwen3.8:27b`). Use the native Ollama install: the Homebrew build is CPU only.

```bash
just setup   # or: cd experiments && uv sync
```

`pyproject.toml` takes torch and torchvision from the PyTorch ROCm index (`rocm10.0`). The lock file pins PyTorch 2.15.0+rocm10.0, Transformers 4.57.6 and Ultralytics 8.4.210, and resolves for Linux x86_64 only.

CountGD++ code and weights (896 MB, not versioned), fetched into `third_party/countgdpp`:

```bash
uv run python -c "from huggingface_hub import snapshot_download; snapshot_download('nikigoli/CountGDPlusPlus', revision='06bd674ecd2d18ea55ec0dd9183fa24603dfa7e1', local_dir='third_party/countgdpp')"
```

Under ROCm, its compiled deformable-attention op does not build, so the model falls back to its pure-PyTorch version (slower, same maths). The whole image is resized to 800 px as in the authors' `count()` helper, without the adaptive cropping and pseudo-exemplars of the paper.

## Data

Not versioned. Put the POPE questions in `data/pope/coco_pope_{random,popular,adversarial}.json` and the COCO annotations in `data/coco/instances_val2014.json`, then:

```bash
uv run python -m src.convert   # --tune-frac 0.2 --seed 0 by default
```

It downloads the 500 images to `data/coco/val2014/` and writes `data/{presence,localization,counting}.jsonl` (row format in `src/run.py`). The images are split once, with the seed, into `tune` (100 images) and `test` (400 images); the same split is used for every task, and only `tune` sets the specialists' thresholds.

- Presence: the POPE questions, 3,000 per setting.
- Localization and counting: one query per class annotated in the image (its COCO boxes and their number), and one negative query (no box, count 0) per class that POPE asks about as absent, in any setting.
- Crowd regions (`iscrowd`) are removed from the targets but not ignored at evaluation: a predicted box on a crowd region is a false positive, unlike in the COCO evaluation.

## Run

```bash
just eval --config configs/default.yaml   # or: uv run python -m src.run --config configs/default.yaml
uv run python -m src.bootstrap --config configs/default.yaml
```

`src.run` writes `results/metrics.csv` and `results/{presence,localization,counting}.json`. Every model output is appended as it arrives, VLM answers to `results/predictions/vlm_answers.jsonl` and raw specialist outputs (scores, boxes with scores, before any threshold) to `results/predictions/specialist_outputs.jsonl`: stop with Ctrl+C at any time and rerun the same command to resume. Once both caches are complete, a rerun recomputes every metric in minutes and loads no model. Per-query counts go to `results/predictions/counting.jsonl`.

`src.bootstrap` reads the caches and the thresholds in `results/<task>.json`, and writes 95% percentile intervals over the test images (1,000 resamples, thresholds kept fixed) to `results/bootstrap.json`. Images are resampled, not queries, because the queries of one image are correlated.

The caches in `results/predictions/` are not versioned. Delete them to start over (for example after changing a prompt or the data).

`just test` checks the metrics, parsers and converter without a GPU.

## Reproducibility

| Item | Value |
|---|---|
| VLM | `qwen3.8:27b` (Ollama default 4-bit tag, 18 GB), reasoning off, temperature 0, fixed seed, context 4,096 tokens |
| Prompts, IoU threshold, box format | `configs/default.yaml` |
| Split | `src.convert` with `--tune-frac 0.2 --seed 0` |
| CountGD++ | Hugging Face revision `06bd674ecd2d18ea55ec0dd9183fa24603dfa7e1` |
| Software | Ollama 0.40.16 (native install), PyTorch 2.15.0+rocm10.0, Transformers 4.57.6, Ultralytics 8.4.210, uv |
| Hardware | AMD Radeon RX 7900 XTX (24 GB, ROCm) |
