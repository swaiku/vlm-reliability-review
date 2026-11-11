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
//  4 Methods                         1.15    800   Tab. 2 tasks and models (~0.25 p)
//  5 Results                         1.40    550   Tab. 3 main results (~0.3 p), Fig. 1 qualitative (~0.5 p)
//  6 Discussion                      0.80    700   -
//  7 Conclusion                      0.35    300   -
//  Slack (float placement)           0.30
//  Total                             8.00   ~5000
//
// Each section below carries its own [budget] tag. Remove before submission.
// =============================================================================

// Paper outline. The introduction is drafted; later sections are placeholders.

// Keep draft notes visible without disrupting the two-column reading flow.
#let todo(body) = text(fill: rgb("#f00000"), size: 8.5pt)[*TODO:* #body]

#show: ieee.with(
  title: [How Reliable Are Vision-Language Models for Visual Information Extraction?],
  abstract: [
    #todo[At the end]
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

Vision-Language Models (VLMs) can answer questions about images and describe what they show. Visual information extraction covers many tasks. A model may need to decide whether an object is present, classify it, count its instances, describe its attributes, or locate it with coordinates or bounding boxes. It may also need to describe relations between objects, such as distance or depth, and read text in a scene. VLMs offer one general way to approach these tasks. However, an answer is only useful if it is reliable and studies have, for example, reported errors in object presence, counting, and visual grounding @li2023pope @tamarapalli2025countqa @li2025groundingme.

It is hard to draw one clear conclusion about VLM reliability because studies test different tasks, models, images, and measures. Specialized systems also exist for many extraction tasks, and few of the studies we reviewed compare a VLM with such a system on the same real-world images. Such a comparison can show where a general model is strong and where it falls short. This paper reviews results from previous studies on object presence, localization, and counting, together with factors that affect reliability. We then compare two VLMs with one specialized model for each of these three tasks on real-world images.

== Research question
// [budget] 2 sentences max
To what extent are VLMs reliable for visual information extraction (object presence, localization, and counting) on real-world images, compared with specialized models?

== Contributions
// [budget] 3 bullets, 1 line each. Contribution wording is yours to write.
- A narrative review of previous studies on VLM reliability for object presence, localization, and counting.
- An experiment on real-world images that compares two VLMs with a specialized model for each of the three tasks.
- An analysis of where the models make errors and which questions remain open.

== Paper overview
// [budget] 3 lines
@sec:background explains the models and evaluation measures. @sec:review summarizes the evidence on VLM reliability. @sec:methods describes the experiment, @sec:results reports its results, and @sec:discussion discusses their meaning and limits. @sec:conclusion closes the paper.

= Background <sec:background>

In this paper, a model is reliable for visual information extraction when a user can trust its output without checking every image by hand. This needs more than a high average score, so we look at three properties. The output must be correct, which includes saying when an object is absent instead of inventing one @li2023pope @li2025groundingme. It must also be stable when the prompt is reworded or the images come from a new domain @schmalfuss2025parc @robicheaux2025rf100vl. Finally, the model should be calibrated, meaning that its confidence matches its chance of being right @levine2023calibration @groot2024overconfidence.

These three properties apply to both types of models that we compare, even though the two types produce very different outputs. General VLMs answer in free text, while open-vocabulary detectors return boxes with a confidence score for each box. The rest of this section first describes the two model types and then the measures used to evaluate their outputs.

== Vision-Language Models
A VLM takes an image and a text prompt as input and writes a text answer. Most current models do this by connecting a vision encoder to a large language model (LLM): the encoder turns the image into a sequence of visual tokens, and the LLM reads these tokens together with the prompt before it generates the answer one token at a time. Open models such as Qwen2.5-VL, Qwen3-VL, and Molmo follow this design @bai2025qwen25vl @qwen3vl2025 @deitke2025molmo. Since the answer is plain text, the same model can handle many tasks without any change, whether the question asks if an object is present, what class it belongs to, or how many instances there are.

Localization fits less naturally in this setting, because a position in the image has to be written as text. Kosmos-2 was one of the first models to address this, by linking words in its answer to special location tokens @peng2023kosmos2. More recent models are trained to write box or point coordinates directly in their answer @bai2025qwen25vl @qwen3vl2025, and Molmo learns to point at objects from 2D pointing data @deitke2025molmo. Rex-Omni goes one step further and treats the whole detection task as the prediction of coordinates, one token after the other @jiang2025rexomni. For the user, however, a box from a VLM remains a piece of text. It must follow the expected format so that it can be parsed and mapped back to image pixels, which is not trivial because the coordinate format differs between model families. In addition, a VLM does not attach a confidence score to each box as a detector does, which makes its output harder to filter and to evaluate. A wider overview of object detection with VLMs is given by @sapkota2025review.

== Open-Vocabulary Object Detection
A classic object detector is trained on a fixed list of classes and cannot find anything outside this list. Open-vocabulary detectors remove this limit by taking class names or short phrases as text input, so that they can also search for categories that were not in their training labels. Grounding DINO, for example, extends the DINO transformer detector with grounded pre-training on image-text data, and it fuses text and image features to find the objects named in the prompt @liu2023groundingdino. YOLO-World follows a similar idea but builds on the fast YOLO detectors, which makes it suitable for real-time use @cheng2024yoloworld. Other work improves these detectors by scaling the training data through self-training on web images @minderer2023owlv2 or by using an LLM to supervise the training @fu2025llmdet.

#figure(
  image("figures/yolo_world.png", width: 100%),
  caption: [Overall architecture of YOLO-World from @cheng2024yoloworld.],
) <fig:yolo-world>

Given an image and a prompt, these detectors return a list of boxes, each with its coordinates, a label taken from the prompt, and a confidence score. The user then keeps only the boxes whose score is above a threshold. This threshold sets a trade-off: a high value misses more objects, whereas a low value adds more false detections. The kept boxes also answer the other extraction tasks, since an object is present when at least one box remains and the count is simply the number of boxes. In contrast to VLMs, these detectors cannot answer general questions, but their output always has the same format and is therefore easy to evaluate. Their results are often called zero-shot when the test classes or datasets were not seen during training, although this is hard to check when the pre-training data is very large.

== Evaluation of Visual Information Extraction
We consider four extraction tasks, which range from a simple yes/no answer to a precise position. *Object presence* asks whether an object of a given class is in the image, and classification asks for the class of an object or of the whole image. *Counting* then asks for the number of instances of a class, while *localization* asks where each instance is, given as a bounding box.

Presence and classification are mainly scored with accuracy. For yes/no questions, precision, recall, and F1 score are reported as well, because a model that answers "yes" too often can still reach a good accuracy. POPE uses this kind of question and asks about objects that are present as well as objects that are absent @li2023pope. Answering "yes" for an absent object is a case of object hallucination, which happens when a model reports something that is not in the image @bai2024survey @liu2024survey. Many other benchmarks rely on multiple-choice questions, where the order of the options can change the answer. To reduce this effect, MMBench asks the same question several times with the options shifted and counts it as correct only if all answers are correct @liu2024mmbench.

Counting is scored with exact-match accuracy or with the mean absolute error between the predicted and true counts. The datasets used for this task range from images that contain many objects of one class, such as cars in parking lots, to cluttered real-world photos @jiang2023clipcount @fuzesseery2025counting @tamarapalli2025countqa.

For localization, a predicted box $B_p$ is compared with a ground-truth box $B_g$ using the intersection over union (IoU):
$ "IoU"(B_p, B_g) = abs(B_p inter B_g) / abs(B_p union B_g). $
A predicted box counts as a true positive when its IoU with a ground-truth box that has not yet been matched is above a threshold, often 0.5. From these matches, precision gives the share of predicted boxes that are correct, and recall gives the share of ground-truth boxes that are found. Detectors are usually compared with average precision (AP), which ranks the boxes by score and summarizes the precision-recall curve obtained over all score thresholds. AP50 fixes the IoU threshold at 0.5, while mean AP (mAP) averages AP over classes and, on COCO, also over several IoU thresholds. Such results are reported on datasets such as COCO and LVIS @liu2023groundingdino @cheng2024yoloworld, and also on sets that cover many different domains, such as ODinW and Roboflow100-VL @qwen3vl2025 @robicheaux2025rf100vl. Because VLM boxes have no score, AP cannot be computed for them in the usual way. A fair comparison with detectors must therefore rely on measures at a fixed operating point, such as precision, recall, and F1 score.

Finally, a reliable system must also be able to say that an object is not there, which these measures capture only in part. For this reason, OmniLabel adds negative descriptions that match no object in the image @schulter2023omnilabel, and GroundingME tests whether models reject queries that cannot be grounded @li2025groundingme.

= Reliability of VLMs: A Review <sec:review>
// [budget] 2.25 p (~1500 words text + Tab. 1 ~0.5 p). Review = core of the paper.
// Sub-budgets below sum to 1.75 p text + 0.5 p table. Method and limits of the search: review/search-log.md.
// Opening paragraph ~0.10 p
#todo[Explain the review approach and summarize the evidence across the three tasks.]

== Object Presence
// [budget] 0.35 p
// sources: li2023pope, wang2023amber, villa2023merlim, guan2024hallusionbench, li2025groundingme (rejection), lan2026seeing (what yes/no scores measure), bai2024survey
#todo[Review object hallucination, absence queries, and false positives.]

== Object Localization
// [budget] 0.40 p
// sources: ramachandran2026gpt4o, jiang2025rexomni, wu2024dettoolchain, robicheaux2025rf100vl, wu2024vstar, liu2023groundingdino, cheng2024yoloworld
#todo[Review visual grounding, box quality, and comparisons with specialized detectors.]

== Object Counting
// [budget] 0.40 p
// sources: tamarapalli2025countqa, qharabagh2024lvlmcount, rong2026unicbench, fuzesseery2025counting, paiss2023countbench, rahmanzadehgervi2024blind, amini2024countgd, amini2025countgdpp, owusu2026counting
#todo[Review direct counting and counting from localized objects.]

== Factors Affecting Reliability
// [budget] 0.30 p
// sources: schmalfuss2025parc, ismithdeen2025promptception, sclar2024format (prompt); ding2025knowledge, groot2024overconfidence, levine2023calibration (confidence); saxena2026robustbench (domain shift)
#todo[Discuss prompt wording, confidence, and domain shift across the three tasks.]

== Synthesis
// [budget] 0.20 p
// Tab. 1 [budget] ~0.5 p, full width (place with #place(top, float: true, scope: "parent")):
// benchmark, task, size, key finding (POPE, AMBER, MERLIM, CountQA, UNICBench, BLINK, PARC, Roboflow100-VL, OmniLabel, GroundingME)
#todo[Summarize the comparison with detectors and identify what the experiment adds.]

= Methods <sec:methods>
#todo[Describe the shared protocol for comparing VLMs and detectors.]

== Task
#todo[Define object presence, localization, and counting tasks.]

== Dataset
#todo[State the image sources, selection rules, and annotations.]

== Models
#todo[List the VLMs, specialized baselines, and input prompts.]

== Metrics
#todo[Define measures for boxes, presence, counting, and robustness.]

== Implementation
#todo[Record code, model versions, settings, and hardware.]

= Results <sec:results>
// [budget] 1.40 p (~550 words + Tab. 3 ~0.3 p + Fig. 1 ~0.5 p)
// Tab. 3: models x tasks x sources; Fig. 1: qualitative examples and failure cases
#todo[Present model comparisons and illustrative errors.]

= Discussion <sec:discussion>
// [budget] 0.80 p (~700 words)
// link each finding to the review themes; limits: dataset choice, two VLMs of one family, possible training-data overlap, no box scores for VLMs
#todo[Interpret the results, limitations, and practical implications.]

= Conclusion <sec:conclusion>
// [budget] 0.35 p (~300 words)
#todo[Answer the research question and outline future work.]
