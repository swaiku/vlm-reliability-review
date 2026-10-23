# Experiments

Bounding-box localization of text-prompted objects: Qwen VLM vs YOLO-World vs Grounding DINO.

## Setup

Requires [uv](https://docs.astral.sh/uv/).

```bash
just setup   # or: cd experiments && uv sync
```

## Data

Not versioned. Download instructions: TODO (dataset name, link, subset used).
Place files in `data/`.

## Run

```bash
just eval --config configs/default.yaml
```

Raw predictions go to `results/predictions/`, metrics to `results/metrics.csv`, figures to `results/figures/`.

## Reproducibility

Pin exact model versions, prompts, IoU thresholds and the random seed in `configs/`. Record the hardware used (GPU or Colab) here.
