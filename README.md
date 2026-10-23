# vlm-reliability-review

How reliable are Vision-Language Models (VLMs) for visual information extraction (classification, counting, localization) on real-world images and videos? A literature review and a small experiment comparing a Qwen VLM with YOLO-World and Grounding DINO on bounding-box localization.

## Structure

| Folder | Content |
|---|---|
| `paper/` | Typst source of the paper (`main.typ`) and bibliography (`refs.yml`) |
| `review/` | Literature review working files: search log, source table, notes per theme |
| `experiments/` | Code, configs and results of the localization experiment |

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
