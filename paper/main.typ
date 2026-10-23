#import "@preview/big-todo:0.2.0": todo as big-todo, todo_outline
#import "@preview/charged-ieee:0.1.4": ieee

// =============================================================================
// PAGE BUDGET: 8 pages IEEE two-column, references EXCLUDED from the 8 pages.
// Assumption: ~900 words per page of pure text. Tables and figures are counted
// separately. Measure after the first draft of section 3 and rebalance.
//
//  Section                          Pages  ~Words  Floats
//  Title block + Abstract + Intro    1.00    500   title block ~0.4 p
//  2 Background                      0.75    650   -
//  3 Review (reliability of VLMs)    2.25   1500   Tab. 1 benchmarks, full width (~0.5 p)
//  4 Methods                         1.00    700   Tab. 2 models and settings (~0.2 p)
//  5 Results                         1.50    600   Tab. 3 main results (~0.3 p), Fig. 1 qualitative (~0.5 p)
//  6 Discussion                      0.85    750   -
//  7 Conclusion                      0.35    300   -
//  Slack (float placement)           0.30
//  Total                             8.00   ~5000
//
// Each section below carries its own [budget] tag. Remove before submission.
// =============================================================================

// Always inline: block mode is too large for a two-column layout
#let todo(body) = big-todo(body, inline: true)

#show: ieee.with(
  title: [How Reliable Are Vision-Language Models for Visual Information Extraction? A Review and Experiment],
  abstract: [
    Vision-Language Models (VLMs) are increasingly used to extract visual information from real-world images, but their reliability remains unclear. This paper reviews the literature on the reliability of VLMs for classification, counting, and localization on real-world images. #todo[main finding of the review and of the experiment, ~150 words max]
  ],
  authors: (
    (
      name: "Jérémy Prin",
      department: [MSE Data Science],
      organization: [HES-SO],
      location: [Switzerland],
      email: "jeremy.prin@hes-so.ch",
    ),
    (
      name: "Raul Santos Barreira",
      department: [MSE Data Science],
      organization: [HES-SO],
      location: [Switzerland],
      email: "raul.santosba@hes-so.ch",
    ),
  ),
  index-terms: (
    "Vision-language models",
    "Reliability",
    "Object localization",
    "Counting",
    "Open-vocabulary detection",
    "Hallucination",
  ),
  bibliography: bibliography("refs.yml"),
  figure-supplement: [Fig.],
)

= Introduction
// [budget] Title block + abstract + intro = 1.00 p total (~500 words of text)
// [budget] Intro body ~0.6 p: context (1 par), gap (1 par), RQ + contributions + overview (short)

#todo[context: why VLMs are used for extraction, why reliability matters (1 paragraph)]
#todo[gap: what the literature does not answer, in your own words (1 paragraph)]

== Research question
// [budget] 2 sentences max
To what extent are VLMs reliable for visual information extraction (classification, counting, and localization) on real-world images?

== Contributions
// [budget] 3 bullets, 1 line each. Contribution wording is yours to write.
- A review of the literature on VLM reliability for visual information extraction. #todo[40 sources, check final count]
- A small experiment comparing VLMs with open-vocabulary detectors on bounding-box localization.
- A discussion of limitations and open problems. #todo[refine]

== Paper overview
// [budget] 3 lines
@sec:background introduces VLMs, open-vocabulary detectors, and metrics. @sec:review reviews the reliability of VLMs. @sec:methods describes our experimental setup, @sec:results presents the results, and @sec:discussion discusses them. @sec:conclusion concludes.

= Background <sec:background>
// [budget] 0.75 p (~650 words): 3 subsections of ~0.25 p each

== Vision-Language Models
// [budget] 0.25 p
#todo[VLM architecture in one paragraph (vision encoder, projector, LLM); Qwen-VL family with native grounding output (qwen25vl, qwen3vl); VQA and grounding capabilities]

== Open-Vocabulary Object Detection
// [budget] 0.25 p
#todo[Grounding DINO, YOLO-World, OWLv2: text-conditioned detectors; difference with VLMs for localization (scored boxes vs generated text coordinates)]

== Evaluation of Visual Information Extraction
// [budget] 0.25 p
#todo[classification (accuracy), counting (MAE, exact accuracy), localization (IoU, precision/recall, AP); note that VLMs give no per-box score, so AP is ill-defined for them]

= Reliability of VLMs: A Review <sec:review>
// [budget] 2.25 p (~1500 words text + Tab. 1 ~0.5 p). Review = core of the paper.
// Sub-budgets below sum to 1.75 p text + 0.5 p table.

#todo[2-3 sentences: scope, how sources were selected (narrative review, photos only, 2023-2026)]

== Object Hallucination
// [budget] 0.35 p
#todo[POPE, AMBER, HallusionBench: what they measure; frequent and co-occurring objects get hallucinated; surveys (bai2024survey, liu2024survey); mitigation only in one sentence (vcd)]

== Counting and Low-Level Perception
// [budget] 0.40 p
#todo[CountBench (CLIP), CountQA 42.9 pct best, GPT-4o/GPT-5 on FSC-147 vs CARPK, BlindTest, MMVP, BLINK, What'sUp, V-star; classification: frequency of class in training data (zhang2024classification)]

== Prompt Sensitivity
// [budget] 0.25 p
#todo[LLM precedent (sclar2024format, zheng2024selection); VLM: PARC, Promptception up to 15 pct; MMBench CircularEval as a mitigation]

== Calibration and Confidence
// [budget] 0.25 p
#todo[CLIP miscalibration (levine2023), verbalized overconfidence (groot2024), probabilities and consistency better than verbalized (ding2025), conformal prediction (ye2025); gap: no calibration work on box-level outputs]

== VLMs versus Open-Vocabulary Detectors
// [budget] 0.50 p
#todo[Grounding DINO, YOLO-World, OWLv2, LLMDet; Kosmos-2, Qwen-VL grounding; specialists still ahead (ramachandran2026); Rex-Omni and DetToolChain: detection training or prompting closes part of the gap; Roboflow100-VL out-of-distribution; GroundingME rejection; stated gap: no controlled head-to-head on counting]

// Tab. 1 [budget] ~0.5 p, full width (place with #place(top, float: true, scope: "parent"))
#todo[Table 1: benchmark, task, size, key finding (POPE, AMBER, HallusionBench, CountBench, CountQA, BLINK, MMVP, PARC, Roboflow100-VL, OmniLabel, GroundingME)]

= Methods <sec:methods>
// [budget] 1.00 p (~700 words + Tab. 2 ~0.2 p)

== Task
// [budget] 0.15 p
We evaluate bounding-box localization of objects specified by a text prompt, on real-world images. #todo[precise task definition: input (image, category name), output (set of boxes); counting derived as number of boxes; negative prompts (category absent from the image) to measure false positives]

== Dataset
// [budget] 0.25 p
#todo[main: ODinW-13 subset (4 to 6 datasets, up to 200 images each); control: COCO val subset (~500 images); negative prompts sampled from absent categories; sizes, split, rationale, contamination caveat]

== Models
// [budget] 0.25 p
We compare three families of models: (a Qwen VLM, YOLO-World, and Grounding DINO). #todo[exact versions: Qwen3-VL-8B-Instruct, Qwen3.5-9B, YOLO-World-L, Grounding DINO Swin-T; optional Rex-Omni 3B; prompt templates (3 to 5 variants), box parsing, inference settings, thresholds]

== Metrics
// [budget] 0.20 p
#todo[IoU 0.5 precision, recall, F1 at a fixed confidence threshold for detectors; parse failure rate for VLMs; count MAE; false positive rate on negative prompts; spread across prompt variants]

== Implementation
// [budget] 0.15 p
Experiments were run on #todo[local GPU or Google Colab, hardware details, libraries and versions, seeds, code link].

= Results <sec:results>
// [budget] 1.50 p (~600 words + Tab. 3 ~0.3 p + Fig. 1 ~0.5 p)

#todo[Tab. 3 main results (models x datasets); prompt sensitivity (spread across variants); negative prompts; derived counting MAE; Fig. 1 qualitative examples and failure cases]

= Discussion <sec:discussion>
// [budget] 0.85 p (~750 words)
#todo[interpretation; link each finding to the review themes (hallucination, counting, prompt, calibration); limitations (one main dataset, few models, possible training-data overlap, no box scores for VLMs); practical implications]

= Conclusion <sec:conclusion>
// [budget] 0.35 p (~300 words)
#todo[answer to the research question in a few sentences, future work]

// Remove before submission
#todo_outline
