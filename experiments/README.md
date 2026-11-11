# Experiments

One VLM (served by Ollama) against one specialist per task, on existing benchmarks:

| Task | VLM output | Specialist |
|---|---|---|
| Presence | yes/no | SigLIP 2 score, threshold tuned on a `tune` split |
| Localization | boxes in text, no score | YOLO-World (or Grounding DINO, `localization_specialist` in the config), best-F1 threshold (Rex-Omni protocol) |
| Counting | number | CountGD (wrapper not written yet) |

## Status

Written without a GPU: `python3 -m tests.test_evaluate` (`just test`) checks the metrics and parsers. `src/run.py`, the Ollama call and the specialist wrappers have **not been run**. First checks on the GPU machine: Ollama uses the GPU, the box format of the chosen VLM (`box_format` in the config), the `post_process_grounded_object_detection` argument names, and whether CountGD builds under ROCm.

## Setup

Requires [uv](https://docs.astral.sh/uv/) and a running Ollama server with the VLM pulled (`ollama pull <tag>`).

```bash
just setup   # or: cd experiments && uv sync
```

No lock file is committed yet: run `uv lock` on the GPU machine. `uv sync` installs the default PyTorch build; for the AMD GPU, install the ROCm build instead (index `https://download.pytorch.org/whl/rocm7.2`).

## Data

Not versioned. One JSONL file per task in `data/` (row format in `src/run.py`), with a `split` of `tune` or `test` chosen by image. The tuning part sets the specialists' score thresholds.

| Set | Source | Used for |
|---|---|---|
| Main | The 500 COCO val images of POPE (3 settings, 6 questions per image) | presence (POPE questions); localization and counting from the COCO annotations of the same images, crowd regions excluded; absent POPE classes give negative queries (no box, count 0) |
| Out-of-domain localization | Subset of Roboflow100-VL | localization |
| Out-of-domain counting | FSC-147 test split | counting (CountGD was trained on FSC-147 train: caveat) |

The converters that build these JSONL files are not written yet.

## Run

```bash
just eval --config configs/default.yaml
```

Metrics go to `results/metrics.csv` and `results/<task>.json`.

## Reproducibility

Pin the exact Ollama tag, its quantization, the prompts, the IoU threshold and the seed in `configs/`. Record the hardware here.
