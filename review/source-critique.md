# Critical appraisal of the sources

Scope: the 39 sources in `sources.md` (updated 2026-10-26 after the restructuring around three tasks: presence, localization, counting, each compared with a specialist). Based on abstracts and project pages, not full texts. Written to be challenged by the authors.

## Overall picture

| Dimension | Count |
|---|---|
| Relevance | 19 core, 20 supporting |
| Venue | 23 main conference or Findings, 3 workshop, 13 arXiv-only preprints |
| Task | presence and hallucination 6, counting 8 (including 2 specialists), localization 7 (including 3 specialists), factors 7, perception 4, classification 1, benchmarks 4, models 1, presence specialist 1 |

The corpus now matches the paper structure. Counting is the best-covered task. Presence rests on older benchmarks plus one source that questions them. Localization evidence for VLMs against detectors on real photos is still thin.

## Task by task

### Presence ([1], [2], [3], [4], [39], [47], [49])
- Solid base: POPE (EMNLP), AMBER and MERLIM measure object existence; HallusionBench (CVPR) separates language hallucination from visual illusion.
- Weak: all are image-level yes/no. None checks where the object is. They evaluate 2023-era models.
- New caution from [49] (workshop, four authors): removing many image tokens barely lowered accuracy on a widely used hallucination benchmark, so yes/no scores may not reflect use of the image. The benchmark was not identified in the abstract. Consequence for our design: a presence score alone is not proof of visual reliability.
- Suggested control, not yet in the paper: run each VLM with the image blanked and report the presence score, to measure the language prior.
- [39] GroundingME is the only source on rejecting ungroundable queries, closest to our negative queries. December 2025 preprint, one benchmark of 1,005 examples.
- Specialist: [46] SigLIP 2 gives an image-text similarity, so a yes/no decision needs a threshold set on a tuning split. No source compares SigLIP-style presence with VLM yes/no; [15] (CLIP above VLMs on ImageNet classification) is indirect evidence.

### Localization ([26], [27], [28], [31], [32], [35], [36])
- Compared specialists [26], [27] are cited through their own papers: self-reported numbers. [26] has checkpoints with different pre-training data, one including COCO. [27] carries a "work in progress" comment on arXiv.
- [31] Rex-Omni shares authors with Grounding DINO (Zeng, Ren, Zhang): its claim to match Grounding DINO is a self-comparison and a preprint.
- [35] (ICLR 2026) is the best independent evidence that multimodal models trail specialists. It covers general vision tasks through prompt chaining, not YOLO-World or Grounding DINO, and predates Qwen3.
- [36] relies on closed models through APIs, so versions drift. [32] RF100-VL is the only out-of-distribution evidence for real photos; the benchmark comes from the company hosting the data.
- Tension: the Qwen3-VL report [38] gives a favorable grounding number for its largest model (48.6 mAP on ODinW-13), while [32] reports near-zero scores on hard medical sets for Qwen2.5-VL. Different models and domains, so do not compare the numbers.

### Counting ([7], [8], [9], [10], [41] to [45])
- Strongest theme. [44] UNICBench (CVPR 2026, 21 MLLMs on the image track) and [43] LVLM-Count agree with [8] CountQA (best 42.9%, errors grow with the count): VLMs are fine for small counts and degrade as the number of objects rises.
- [45] is a two-author survey (no venue, August 2026) arguing that generality claims outpace evaluation and that few saturated benchmarks dominate. Useful framing, but secondary and recent.
- [9] is a five-page preprint; I read no error values. [10] uses synthetic shapes; [7] studies CLIP, not a generative VLM.
- Specialist: [41] CountGD is built by repurposing Grounding DINO. It is therefore not independent of the localization specialist, and it was trained on FSC-147, so COCO and RF100-VL are out of distribution for it. Say this in the paper: the specialist is not guaranteed to be in its comfort zone.
- [42] CountGD++ is by the same authors. A search summary says it compares with MLLMs on FSC-147; I did not read the comparison. It is the nearest source to our counting comparison and the first to read in full.
- Counting from boxes depends on annotation quality: COCO crowd annotations and RF100-VL labeling differ in completeness.

### Factors ([17], [20] to [24], [48])
- Prompt: [20] and [21] are recent and peer-reviewed but measure multiple-choice VQA, not extraction. [17] is a text-only LLM study. Tension: [21] reports proprietary models as more sensitive to prompts, [35] reports that better models are less sensitive. The protocols differ.
- Confidence: weakest area. [22] is a workshop paper on CLIP classification. [23] is a workshop paper with outdated models. [24] (Findings) is the strongest, on knowledge-boundary question answering. None addresses box-level scores. VLMs return no score in our experiment, so calibration stays an open problem, not a finding.
- Domain shift: [48] reports that low-severity spatial perturbations can hurt more than severe photometric ones, but on multiple-choice benchmarks, not extraction.

## Cross-cutting weaknesses

1. **Model generation mismatch.** Sources evaluate GPT-4V, Gemini 1.5, Qwen2-VL and Qwen2.5-VL, not the Qwen3-VL and Qwen3.5 models we run. Findings on older models may not transfer.
2. **Self-reported results.** [26], [27], [31], [38], [41], [42] come from the groups that built the models.
3. **Seeded selection.** Most sources were proposed from one assistant's knowledge and then verified (`search-log.md`). The 2026 update added sources from Raul's earlier slides and targeted queries per task. Famous papers remain over-represented.
4. **Task distance.** Evidence on presence and perception is mostly yes/no or multiple choice. Localization and counting evidence is closer to our tasks but still rarely on real photos against specialists.
5. **Very recent sources.** [42], [44], [45], [48], [49] date from 2026 and several are preprints or workshop papers. Treat their claims as provisional.
6. **No contrary evidence sought deliberately.** Searches looked for failures. Counter-evidence (VLMs doing well) appears only in [9], [31] and [38].
7. **Abstract-level reading.** All numbers (42.9%, 31.42%, 58.07%, 48.6, ...) come from abstracts or summaries and must be checked in the full text.

## Gaps

- Calibration of box outputs and of detectors (no source).
- Head-to-head VLM against CountGD on the same photos (only [42] claims a comparison, not read).
- A presence comparison between a VLM and an image-text encoder.
- Independent evaluation of Qwen3-VL or Qwen3.5 on localization or counting.
- Evidence that VLMs are reliable under some conditions, to balance the review.

## Suggested actions

| Action | Sources |
|---|---|
| Read in full before citing numbers | [8], [9], [35], [31], [32], [39], [42], [43], [44] |
| Cite with a caveat in the text | [31] (author overlap), [45] (secondary, recent), [49] (workshop), [23], [22] (workshop, outdated), [41] (not independent of [26]) |
| Merge if space is short | [10] and [12] (both about low-level perception failures) |
| Add if time | a source on calibration of object detectors; an independent Qwen3 evaluation if one exists |
| Add to the experiment | a blank-image control for presence |

One slot is free under the 40-source cap (39 used).
