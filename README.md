# vlm-reliability-review

How reliable are Vision-Language Models (VLMs) for visual information extraction (object presence, localization, and counting) on real-world images, compared with specialized models? A literature review and an experiment comparing one VLM (Qwen3.8-27B) with SigLIP 2, YOLO-World, and CountGD++ on the COCO images of POPE.

## Structure

| Folder | Content |
|---|---|
| `paper/` | Typst source of the paper (`main.typ`) and bibliography (`refs.yml`) |
| `review/` | Literature review: search log, source table, and the slides of the research question |
| `experiments/` | Code, configs and results of the experiment |

## Build the paper

Requires [Typst](https://typst.app).

```bash
just paper   # compile to paper/main.pdf
just watch   # recompile on every save
```

## Run the experiment

See [`experiments/README.md`](experiments/README.md).

## Authors

Jérémy Prin, Raul Santos Barreira (MSE Data Science, HES-SO)
