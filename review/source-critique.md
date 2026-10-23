# Critical appraisal of the sources

Scope: the 40 sources in `sources.md`. Based on abstracts and project pages, not full texts. Written to be challenged by the authors.

## Overall picture

| Dimension | Count |
|---|---|
| Relevance | 15 core, 18 supporting, 2 background, 5 peripheral |
| Venue | 24 main conference or Findings, 12 preprints only, 3 workshop or low-visibility venue, 1 journal |
| Theme | hallucination 7, perception 5, counting 4, prompt sensitivity 4, calibration 4, detectors 4, detectors versus VLMs 4, benchmarks 3, grounding VLMs 3, classification 1, localization 1 |

The corpus is solid on **why VLMs fail** (hallucination, counting, perception) and thin on **how reliable they are for localization** and on **calibration of box outputs**, which is the part the experiment tests.

## Theme by theme

### Hallucination ([1] to [6], [39])
- Strong: POPE, AMBER and HallusionBench are well-known and peer-reviewed (EMNLP, CVPR).
- Weak: they measure image-level presence or yes/no answers. None checks where the object is.
- Risk of dated evidence: they evaluate 2023 models. Whether current models saturate them was not checked.
- [39] GroundingME is the only source on rejecting ungroundable queries, which is closest to our negative prompts. It is a December 2025 preprint with one benchmark of 1,005 examples.

### Counting and perception ([7] to [14], [37])
- Closest to the question: [8] CountQA (best model 42.9% on dense real photos) and [9] (GPT-4o and GPT-5 on FSC-147 and CARPK).
- Both are preprints; [9] has five pages and I read no error values. Treat them as indicative until read in full.
- [7] studies CLIP, a contrastive model, not a generative VLM. [10] uses synthetic shapes. [11], [12], [13] are multiple choice and far from extraction. They explain mechanisms, they do not measure our task.
- Counting evidence uses question answering. None uses boxes, so our derived count from boxes is not directly comparable.

### Prompt sensitivity ([17] to [21])
- [20] and [21] are recent and peer-reviewed (CVPR 2025, EMNLP 2025) but measure multiple-choice VQA.
- [17] and [18] are text-only LLM studies. Their transfer to VLMs rests on [20] and [21].
- Tension: [21] reports proprietary models as more sensitive to prompts, while [35] reports that better models are less sensitive. The protocols differ, so this has to be discussed, not averaged.
- No source measures prompt sensitivity for localization. This is a gap our experiment addresses.

### Calibration ([22] to [25])
- Weakest theme. [22] is a workshop paper on CLIP classification. [23] is a workshop paper with models now outdated (GPT-4V, Gemini Pro Vision). [25] comes from a low-visibility venue with two authors.
- [24] (EMNLP Findings) is the strongest, and it concerns knowledge-boundary question answering.
- None addresses box-level scores or detector calibration. The experiment cannot measure it either for VLMs, because they return no score. State this as an open problem, not as a finding.

### Detectors and VLMs versus detectors ([26] to [36])
- The compared detectors [26], [27] are cited through their own papers, so their numbers are self-reported. [26] has checkpoints with different pre-training data, one including COCO.
- [27] carries a "work in progress" comment on arXiv, so published numbers may differ.
- [31] Rex-Omni shares authors with Grounding DINO (Zeng, Ren, Zhang). Its claim to match Grounding DINO is a self-comparison and a preprint.
- [35] is the best independent evidence (ICLR 2026): multimodal models trail specialists on every task. It covers general vision tasks through prompt chaining, not YOLO-World or Grounding DINO, and it predates Qwen3.
- [36] relies on closed models through APIs, so versions drift.
- [33] is a projection by two authors, not evidence. [34] is about detector training, not VLM reliability.
- [32] RF100-VL is the only out-of-distribution evidence for real-world photos. The benchmark comes from the company hosting the data.

## Cross-cutting weaknesses

1. **Model generation mismatch.** The sources evaluate GPT-4V, Gemini 1.5, Qwen2-VL and Qwen2.5-VL. The experiment runs Qwen3-VL and Qwen3.5, for which the corpus has only developer reports ([38]) and a model card. Findings on older models may not transfer.
2. **Self-reported results.** [26], [27], [30], [31], [38] come from the groups that built the models.
3. **Seeded selection.** Most sources were proposed from one assistant's knowledge and then verified (see `search-log.md`). Famous papers are over-represented.
4. **Task distance.** Only about a third of the sources (14 of 40) concern localization, detection or grounding, and few of those test VLMs on real photos against detectors. Most evidence is multiple-choice or yes/no.
5. **No contrary evidence sought.** The searches looked for failures. Papers reporting that VLMs are reliable were not searched for deliberately. The review may lean negative.
6. **Abstract-level reading.** All numbers (for example 42.9%, 31.42%, 58.07%) come from abstracts and must be checked in the full text.

## Gaps to fill

- Calibration of object detectors and of box outputs (no source).
- Counting from detections with open-vocabulary detectors such as YOLO-World (no head-to-head with VLMs).
- Prompt sensitivity for grounding and detection tasks.
- Independent evaluations of Qwen3-VL or Qwen3.5 on localization.
- Evidence that VLMs are reliable under some conditions, to balance the review.

## Suggested actions

| Action | Sources |
|---|---|
| Drop first if space is short | [34] LLMDet, [37] CLIP-Count, [16] Molmo, [25] conformal prediction, [6] VCD |
| Merge | [4] and [5] (overlapping surveys): keep one |
| Read in full before citing numbers | [8], [9], [35], [31], [32], [39] |
| Cite with a caveat in the text | [31] (author overlap), [33] (projection), [23] (outdated models), [22] (workshop) |
| Add | one detector-calibration source, one counting source with boxes, one independent Qwen3 evaluation if it exists |

Freeing the five peripheral sources leaves room for about five additions while staying at 40.
