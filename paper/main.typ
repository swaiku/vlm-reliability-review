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

We conducted a narrative review of 40 sources published between 2023 and 2026 on the reliability of VLMs for classification, counting, and localization in still images. Sources were gathered through web searches (arXiv, conference proceedings, the ACL Anthology) that started from known benchmarks and were extended by one targeted query per theme; video work is excluded. We did not follow a systematic protocol, so coverage is not exhaustive. #todo[update the count and add a sentence on the complementary search once done]

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
We evaluate bounding-box localization of objects specified by a text prompt, on real-world photographs. Each query is a pair $(I, c)$ of an image and a category name, and a model returns a set of boxes $B$ for the instances of $c$ in $I$. A query is positive if $c$ has at least one annotated instance in $I$, and negative otherwise. Positive queries measure localization and, through the number of returned boxes $hat(n) = |B|$, counting. Negative queries measure false positives, in the spirit of POPE @li2023pope. Classification is covered by the review only.

== Dataset
// [budget] 0.25 p
We use two sources. COCO val2017 serves as a control: we sample 500 images with a fixed seed and use the annotated categories of these images #todo[confirm: crowd annotations (iscrowd) excluded]. COCO is probably part of the training data of at least some of the models, so it indicates performance in a familiar setting only. For real-world images from varied domains, we use a subset of Roboflow100-VL @robicheaux2025rf100vl. We choose $N$ datasets with a rule fixed before any model is run: non-medical domain, at least three classes with plain-English names, at least 100 test images, and distinct image domains #todo[N = 4 or 5; list the datasets chosen with their sizes]. Medical datasets are excluded because zero-shot detectors are reported to perform near zero on them @robicheaux2025rf100vl, which would not inform our question. For each positive query, we add one negative query: a category drawn with a fixed seed from the dataset's class list among those absent from the image. #todo[totals: images, positive and negative queries per source]

== Models
// [budget] 0.25 p
We compare four models from three families (@tab:models): two Qwen VLMs of successive generations, Qwen3-VL-8B-Instruct @qwen3vl2025 and Qwen3.5-9B @qwen35card, and two open-vocabulary detectors, Grounding DINO with a Swin-T backbone @liu2023groundingdino and YOLO-World-L @cheng2024yoloworld. We use the Grounding DINO checkpoint whose pre-training data exclude COCO #todo[verify the exact checkpoint id]. Each VLM receives every query under $K$ prompt templates, with $K$ between 3 and 5 #todo[final K and template texts], and decodes greedily, so each template gives one output per query #todo[confirm determinism across runs]. The answer is parsed into boxes in pixel coordinates. The coordinate convention of each Qwen model is checked on a pilot set of 20 images before the evaluation. Detectors receive the category name alone #todo[decide: text variants for detectors, e.g. "a photo of a c"].

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, left, left),
    table.header([*Model*], [*Type*], [*Text input*], [*Output*]),
    [Qwen3-VL-8B-Instruct], [VLM], [$K$ templates], [boxes as text],
    [Qwen3.5-9B], [VLM], [$K$ templates], [boxes as text],
    [Grounding DINO (Swin-T)], [detector], [category name], [boxes, scores],
    [YOLO-World-L], [detector], [category name], [boxes, scores],
  ),
  caption: [Models compared. VLMs return no per-box score.],
) <tab:models>

== Metrics
// [budget] 0.20 p
Predicted and ground-truth boxes of the queried category are matched one-to-one at $"IoU" >= 0.5$ #todo[also report 0.75?]. We report precision, recall and F1 over positive queries #todo[micro or macro averaging across datasets]. VLMs return no per-box score, so average precision is not defined for them, and we compare all models at a single operating point. Detectors use the default confidence threshold $tau$ of their reference implementation #todo[values], and we report an F1 sweep over $tau$ as a sensitivity analysis. For counting, we report the mean absolute error and the exact-match accuracy of $hat(n)$ against the number of annotated instances, on positive queries. The hallucination rate is the share of negative queries for which a model returns at least one box. The parse failure rate is the share of VLM answers that contain no valid box list. Prompt sensitivity is the spread (maximum minus minimum) of F1 across the templates of a VLM.

== Implementation
// [budget] 0.15 p
Experiments were run on #todo[GPU or Google Colab, hardware details]. The Qwen models and Grounding DINO run through Hugging Face Transformers, and YOLO-World through Ultralytics, both on PyTorch #todo[library versions]. Seeds, prompts, thresholds and model identifiers are fixed in configuration files, and the code is available at #todo[repository link].

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
