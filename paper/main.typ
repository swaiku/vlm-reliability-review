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

It is hard to draw one clear conclusion about VLM reliability because studies test different tasks, models, images, and measures. Specialized systems also exist for many extraction tasks, and few of the studies we reviewed compare a VLM with such a system on the same real-world images. Such a comparison can show where a general model is strong and where it falls short. This paper reviews results from previous studies on object presence, localization, and counting, together with factors that affect reliability. We then compare one VLM with one specialized model for each of these three tasks on real-world images.

== Research question
// [budget] 2 sentences max
To what extent are VLMs reliable for visual information extraction (object presence, localization, and counting) on real-world images, compared with specialized models?

== Contributions
// [budget] 3 bullets, 1 line each. Contribution wording is yours to write.
- A narrative review of previous studies on VLM reliability for object presence, localization, and counting, with a table of the studies that compare a VLM with a specialized model.
- An experiment on real-world images that compares one VLM with one specialized model for each of the three tasks.
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
Object hallucination, where a model reports an object that is not in the image, is the best-studied reliability problem for presence @bai2024survey. POPE turns it into yes/no polling questions and finds that frequent and co-occurring objects are hallucinated more often @li2023pope. AMBER adds an evaluation without an LLM judge and shows the same asymmetry: for the nine models it tests, recall on the questions whose true answer is "no" is far below precision, so the models answer "yes" too readily @wang2023amber.

A correct answer does not prove that the image was used. HallusionBench pairs questions with edited images to separate language hallucination from visual illusion, and GPT-4V reaches only 31.42% question-pair accuracy @guan2024hallusionbench. MERLIM removes an object by inpainting and finds that the best models lose the most precision on the edited images, which suggests that some correct answers come from the language prior or the global context @villa2023merlim. A similar signal appears on POPE: removing 75% of the image tokens lowers accuracy by only about 3 points for two of the five open models tested, on a 300-example subset @lan2026seeing.

Few studies test whether a model can refuse a query that it cannot ground. GroundingME evaluates this rejection and reports that most models do it poorly @li2025groundingme. PVFH-Bench tests recent models on 258 COCO images, with an absent object that looks like a visible one. Qwen3-VL-8B answers 98.45% of the questions about the visible object correctly, but only 80.62% for the look-alike absent object and 58.14% once a false premise is added. Gemma-3-27B-IT falls from 98.84% to 28.29% @wang2026pvfh. Most other benchmarks ask about an object anywhere in the image and evaluate 2023-era models. They do not tell whether a presence answer holds when the object is small, partly hidden or absent from a real photograph.

== Object Localization
// [budget] 0.40 p
// sources: ramachandran2026gpt4o, jiang2025rexomni, wu2024dettoolchain, robicheaux2025rf100vl, liu2023groundingdino, cheng2024yoloworld
Open-vocabulary detectors such as Grounding DINO and YOLO-World are the usual reference for localizing a named object @liu2023groundingdino @cheng2024yoloworld. Recent VLMs now write boxes directly. On COCO, Rex-Omni reaches an F1 of 72.0 at IoU 0.5 against 69.8 for Grounding DINO, but at IoU 0.95 the detector is better (23.0 against 15.9), and Qwen2.5-VL-7B reaches 64.0 at IoU 0.5 @jiang2025rexomni. Because VLM boxes have no score, the detectors are compared at their best-F1 threshold. This comparison comes from a preprint whose authors also built Grounding DINO, so no independent group has checked it.

Independent studies are less favorable. Ramachandran et al. evaluate GPT-4o and other multimodal models on standard vision tasks through prompt chaining. On detection, GPT-4o reaches 60.62 AP50 with this chaining, against 17.69 with direct prompting and 91.30 for the specialist Co-DETR @ramachandran2026gpt4o. The prompting procedure therefore changes the outcome as much as the model does. DetToolChain obtains a similar gain by prompting: GPT-4V and Gemini reach 65.8 AP50 on COCO novel classes, 22.7 points above CORA @wu2024dettoolchain. In both studies, the gain comes from a procedure built around the model, not from the model alone.

Real-world images are harder. Roboflow100-VL collects 100 datasets outside the usual training domains. Zero-shot, Grounding DINO reaches 15.7 mAP over the 100 datasets and Qwen2.5-VL (72B) 5.6, and on the medical datasets the two reach 2.1 and 1.6 mAP @robicheaux2025rf100vl. The authors conclude that open-vocabulary detectors consistently outperform the VLMs they tested.

Two limits remain. These studies use closed models through APIs or older open models, and most report AP, which VLM boxes cannot give because they carry no score (@sec:background). We found no study that compares a recent open VLM with a detector at one fixed operating point on the same real photographs.

== Object Counting
// [budget] 0.40 p
// sources: tamarapalli2025countqa, qharabagh2024lvlmcount, rong2026unicbench, fuzesseery2025counting, paiss2023countbench, rahmanzadehgervi2024blind, amini2024countgd, amini2025countgdpp, owusu2026counting
Counting is the best-covered task. CountBench holds 540 images with 2 to 10 objects and was built because CLIP ignores numerals @paiss2023countbench. On simple synthetic shapes, four VLMs reach only 58.07% on average, although the vision encoder keeps the information needed @rahmanzadehgervi2024blind. On real photographs, CountQA uses dense, cluttered scenes and finds that accuracy falls as the count rises @tamarapalli2025countqa. LVLM-Count and UNICBench agree: models are fairly reliable for small counts and degrade for large ones, and UNICBench covers 5,300 images and 21 MLLMs on its image track @qharabagh2024lvlmcount @rong2026unicbench. On the FSC-147 test set, GPT-4o and GPT-5 reach a mean absolute error (MAE) of 20.73 and 20.96, against 15.69 for the best zero-shot specialist in the same table, and on CARPK their errors (30.13 or more) are far above the 8.13 of a specialist counter @fuzesseery2025counting. Both models predict a count of 1 for an image of 2,560 Lego pieces.

HoloCount is the only study we found that evaluates the recent open models on counting. It tests Qwen3.5, Qwen3-VL and Gemma 3 on 2,480 questions: the average exact-match accuracy is 71.4% for Qwen3.5-9B, 58.1% for Qwen3-VL-8B and 48.4% for Gemma3-27B. In high-density scenes, Qwen3.5-27B reaches 20.0% and Gemma3-27B 0.0%. On questions about an object that is absent, Qwen3-VL-8B answers zero correctly in 96.4% of cases and Gemma3-27B in 87.2% @deng2026holocount. It includes no specialist counter.

Specialist counters give a reference. CountGD repurposes Grounding DINO to count from text, exemplars or both @amini2024countgd. Its successor reaches a mean absolute error of 8.39 on FSC-147, against 43.18 for Gemini-2.5 and 40.41 for Molmo @amini2025countgdpp. Both papers come from the same group, and the model was trained on FSC-147, so this is not an independent test. A recent survey argues that claims of generality outpace evaluation @owusu2026counting. We found no study that compares counts derived from detector boxes with the direct counts of a VLM on the same images.

== Factors Affecting Reliability
// [budget] 0.30 p
// sources: schmalfuss2025parc, ismithdeen2025promptception, sclar2024format (prompt); ding2025knowledge, groot2024overconfidence, levine2023calibration (confidence); saxena2026robustbench (domain shift)
*Prompt wording.* Changing the format of a prompt, without changing its meaning, can alter the accuracy of text-only LLMs by a large margin @sclar2024format. For VLMs, Promptception tests 10 models with 61 prompt types and finds accuracy deviations of up to 15% @ismithdeen2025promptception, and PARC measures the sensitivity of 22 VLMs to language and vision prompt variations @schmalfuss2025parc. These studies use multiple-choice questions, not boxes or counts. Ramachandran et al. are the exception: their detection score moves from 17.69 to 60.62 AP50 with the prompting procedure @ramachandran2026gpt4o.

*Confidence.* This is the least studied factor. Zero-shot CLIP is miscalibrated, but one learned temperature corrects it across datasets @levine2023calibration. LLMs and VLMs are overconfident when they state their own uncertainty, including for counting @groot2024overconfidence, and probability and consistency signals are more reliable than verbalized confidence @ding2025knowledge. No study we found addresses the confidence of generated boxes.

*Domain shift.* VLM-RobustBench applies 49 corruption types in 133 settings and reports losses of up to 34 points, with low-severity spatial changes sometimes hurting more than severe photometric ones @saxena2026robustbench. Roboflow100-VL shows the same effect on object detection across domains @robicheaux2025rf100vl. For specialists, a robustness study on COCO-O reports a mean mAP drop of 6.9 points for Grounding DINO (48.4 to 41.5, the clean value taken from its own paper), 15.9 for YOLO-World and 10.4 for OWL-ViT @chhipa2024ovrobust. We found no equivalent measure for VLMs on box or count tasks.

== Synthesis
// [budget] 0.20 p
// Tab. 1 [budget] ~0.5 p, full width: VLM vs specialist comparisons found in the reviewed studies, by task.
#place(top, float: true, scope: "parent")[
  #set text(size: 8pt)
  #set par(justify: false)
  #figure(
    table(
      columns: (0.9fr, 1.2fr, 1.7fr, 1.2fr, 1.5fr, 2fr),
      inset: (x: 3pt, y: 2pt),
      align: left,
      table.header[*Task*][*Study*][*VLM*][*Specialist*][*Data, metric*][*Direction*],
      [Presence], [Zhang et al. #cite(<zhang2024classification>) (indirect)], [GPT-4], [EVA-G], [ImageNet, accuracy], [Specialist better],
      [Localization], [Ramachandran et al. #cite(<ramachandran2026gpt4o>)], [GPT-4o], [Co-DETR], [CV tasks, AP50], [Specialist better, prompt-dependent],
      [Localization], [DetToolChain #cite(<wu2024dettoolchain>)], [GPT-4V, Gemini], [CORA], [COCO novel, AP50], [VLM better, dedicated prompting],
      [Localization], [Rex-Omni #cite(<jiang2025rexomni>) #sym.dagger], [Rex-Omni, Qwen2.5-VL-7B], [Grounding DINO], [COCO, F1], [Mixed: IoU 0.5 vs 0.95],
      [Localization], [RF100-VL #cite(<robicheaux2025rf100vl>)], [Qwen2.5-VL, Gemini 2.5 Pro], [Grounding DINO], [RF100-VL, mAP], [Specialist better],
      [Counting], [CountGD++ #cite(<amini2025countgdpp>) #sym.dagger], [Gemini-2.5, Molmo], [CountGD++], [FSC-147, MAE], [Specialist better],
      [Counting], [Füzesséry et al. #cite(<fuzesseery2025counting>)], [GPT-4o, GPT-5], [CountTX, RCC], [FSC-147, CARPK, MAE], [Specialist better, small gap on FSC-147],
    ),
    caption: [Studies that compare a VLM with a specialist model. Datasets and metrics differ, so rows cannot be compared with each other. #sym.dagger Same group as the specialist. We found no direct study for object presence. All VLMs date from 2025 or earlier.],
  ) <tab:comparisons>
]

The evidence is uneven across tasks. Counting is the most studied, and its studies agree that VLMs degrade as the number of objects grows. Presence rests on older benchmarks, and recent work questions what a high yes/no score proves @lan2026seeing. Localization is the weakest case: independent comparisons with detectors are few, and most use closed or older models (@tab:comparisons). Across the three tasks, we found no study that tests recent open VLMs against a specialist on the same real photographs, measures prompt robustness on boxes or counts, or reports the confidence of generated boxes. These gaps are the points that our experiment addresses.

= Methods <sec:methods>
#todo[Describe the shared protocol for comparing one VLM with one specialized model per task.]

== Task
We use the three tasks defined in @sec:background. For object presence, the model says whether an object of a given class is in the image. For localization, it returns a box for each instance of the class. For counting, it returns the number of instances. The class is given as a text prompt, and the VLM and the specialist receive the same class names.

== Dataset
We reuse existing benchmarks, so that the three tasks are scored on the same real-world photographs. The main set is the 500 COCO validation images of POPE @li2023pope @lin2014coco, which were chosen for having more than three annotated objects. For presence, we use the six yes/no questions of POPE per image, half about a present object and half about an absent one, under its random, popular, and adversarial settings (3,000 questions each). For localization and counting, we take the targets from the COCO annotations of the same images: the boxes of each present class and their number, without crowd regions. The absent classes of POPE give negative queries, where the correct output is no box and a count of zero.

Two out-of-domain sets complete it. For localization, we use a subset of Roboflow100-VL, which holds 100 datasets from domains that web pre-training rarely covers @robicheaux2025rf100vl. For counting, we use the test split of FSC-147 @ranjan2021fsc147. CountGD was trained on the FSC-147 training split @amini2024countgd, so this set may favor the specialist. Each set is split by image into a tuning part and a test part: the tuning part sets the score thresholds of the specialists. #todo[Sizes of the subsets and of the tuning and test parts.]

== Models
We compare one VLM with one specialist for each task. #todo[VLM: model, Ollama tag, quantization.] The specialists are SigLIP 2 for presence @tschannen2025siglip2, YOLO-World for localization @cheng2024yoloworld, and CountGD for counting @amini2024countgd. We did not use Grounding DINO for localization because CountGD is built on it, which would make the two specialists dependent. The VLM gets a fixed prompt for each task: a yes/no question, a request for a JSON list of boxes, and a request for one number. Its reasoning mode is off and its temperature is 0. CountGD receives the class name only, as the VLM does. SigLIP 2 returns a similarity score, so it predicts "present" when the score is above a threshold chosen on the tuning part.

== Metrics
For presence, we report accuracy, precision, recall, F1, and the share of "yes" answers. For localization, we match predicted and true boxes one to one at IoU 0.5 and report precision, recall, and F1. VLM boxes have no score, so YOLO-World is compared at one score threshold, chosen on the tuning part to maximize F1, as in @jiang2025rexomni. For counting, we report exact-match accuracy, MAE, and RMSE. For all three tasks, we also report the share of answers that cannot be parsed. Calibration cannot be measured for the VLM, because it returns no confidence for its boxes or counts. #todo[Prompt robustness and false-positive rate on negative queries.]

== Implementation
The VLM runs locally with Ollama, with a fixed seed. The specialists run with PyTorch through Transformers and Ultralytics. The environment is managed with uv. #todo[Versions, hardware, dates.]

= Results <sec:results>
// [budget] 1.40 p (~550 words + Tab. 3 ~0.3 p + Fig. 1 ~0.5 p)
// Tab. 3: model x tasks x reliability criteria; Fig. 1: qualitative examples and failure cases
#todo[Present the VLM and specialist comparison by task and illustrative errors.]

= Discussion <sec:discussion>
// [budget] 0.80 p (~700 words)
// link each finding to the review themes; limits: dataset choice, one VLM, quantization, possible training-data overlap, no box scores for VLMs
#todo[Interpret the results, limitations, and practical implications.]

= Conclusion <sec:conclusion>
// [budget] 0.35 p (~300 words)
#todo[Answer the research question and outline future work.]
