#import "@preview/charged-ieee:0.1.4": ieee

// =============================================================================
// PAGE BUDGET: 8 pages IEEE two-column, references EXCLUDED from the 8 pages.
// Assumption: ~900 words per page of pure text. Tables and figures are counted
// separately. Measure after the first draft of section 3 and rebalance.
//
//  Section                          Pages  ~Words  Floats
//  Title block + Abstract + Intro    1.00    500   title block ~0.4 p
//  2 Background                      0.75    650   -
//  3 Review (reliability of VLMs)    2.25   1500   -
//  4 Methods                         1.15    800   -
//  5 Results                         1.40    550   Tab. 1 main results (~0.3 p), Fig. 1 qualitative (~0.5 p)
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
    Vision-language models (VLMs) can answer questions about images, but it is unclear how far their answers can be trusted for extraction tasks such as deciding whether an object is present, locating it, and counting it. We review previous studies of these three tasks and of the factors that affect reliability. We then compare one recent VLM, Qwen3.8-27B, with one specialized model per task on 500 COCO photographs: SigLIP 2 for presence, YOLO-World for localization, and CountGD++ for counting. The review shows uneven evidence: counting is the best covered, we found no study that compares a VLM with a specialist for presence, and recent models are rarely evaluated independently. In our experiment, the VLM is more accurate than the specialist for presence (83.5% to 93.3%, against 76.3% to 81.9%) and, over all counting queries, for counting (mean absolute error 0.41 against 0.85), while YOLO-World has the better F1 score for localization (56.6% against 49.2%). All three differences lie outside their 95% bootstrap intervals, and the VLM also beats YOLO-World used as a presence detector. However, the VLM reports too much: it returns boxes for 23.5% of the absent classes, against 6.3% for YOLO-World, it is exact for fewer than 10% of the counts of four or more, and it gives no confidence. In this test, a VLM can therefore match or beat specialists on some tasks, but it needs checks for false detections and for large counts.
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
- A narrative review of previous studies on VLM reliability for object presence, localization, and counting.
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
// [budget] 2.25 p (~1500 words text). Review = core of the paper.
// Sub-budgets below sum to 1.75 p text + 0.5 p table. Method and limits of the search: review/search-log.md.
// Opening paragraph ~0.10 p
This review is narrative, not systematic. With the help of an AI assistant, we found the studies through web searches and direct lookups of arXiv and conference pages between October and November 2026, starting from well-known works. We kept a study when it measures one of the three tasks, a specialized model for one of them, or a factor that affects reliability. Some studies were read in full and others only at the level of the abstract. We first review the evidence for object presence, localization, and counting, then the factors that cut across them: prompt wording, confidence, and domain shift.

== Object Presence
// [budget] 0.35 p
// sources: li2023pope, wang2023amber, villa2023merlim, guan2024hallusionbench, li2025groundingme (rejection), lan2026seeing (what yes/no scores measure), bai2024survey
Object hallucination, where a model reports an object that is not in the image, is the best-studied reliability problem for presence @bai2024survey. POPE turns it into yes/no polling questions and finds that frequent and co-occurring objects are hallucinated more often @li2023pope. AMBER adds an evaluation without an LLM judge and shows the same asymmetry: for the nine models it tests, recall on the questions whose true answer is "no" is far below precision, so the models answer "yes" too readily @wang2023amber.

A correct answer does not prove that the image was used. HallusionBench pairs questions with edited images to separate language hallucination from visual illusion, and GPT-4V reaches only 31.42% question-pair accuracy @guan2024hallusionbench. MERLIM removes an object by inpainting and finds that the best models lose the most precision on the edited images, which suggests that some correct answers come from the language prior or the global context @villa2023merlim. A similar signal appears on POPE: removing 75% of the image tokens lowers accuracy by only about 3 points for two of the five open models tested, on a 300-example subset @lan2026seeing.

Few studies test whether a model can refuse a query that it cannot ground. GroundingME evaluates this rejection and reports that most models do it poorly @li2025groundingme. PVFH-Bench tests recent models on 258 COCO images, with an absent object that looks like a visible one. Qwen3-VL-8B answers 98.45% of the questions about the visible object correctly, but only 80.62% for the look-alike absent object and 58.14% once a false premise is added. Gemma-3-27B-IT falls from 98.84% to 28.29% @wang2026pvfh. Most other benchmarks ask about an object anywhere in the image and evaluate 2023-era models. They do not tell whether a presence answer holds when the object is small, partly hidden or absent from a real photograph. We found no study that compares a VLM with a specialist on object presence. The closest evidence is for classification: GPT-4 reaches 60.6% on ImageNet, against 79.2% for the CLIP model EVA-G @zhang2024classification.

== Object Localization
// [budget] 0.40 p
// sources: ramachandran2026gpt4o, jiang2025rexomni, wu2024dettoolchain, robicheaux2025rf100vl, liu2023groundingdino, cheng2024yoloworld
Open-vocabulary detectors such as Grounding DINO and YOLO-World are the usual reference for localizing a named object @liu2023groundingdino @cheng2024yoloworld. Recent VLMs now write boxes directly. On COCO, Rex-Omni reaches an F1 of 72.0 at IoU 0.5 against 69.8 for Grounding DINO, but at IoU 0.95 the detector is better (23.0 against 15.9), and Qwen2.5-VL-7B reaches 64.0 at IoU 0.5 @jiang2025rexomni. Because VLM boxes have no score, the detectors are compared at their best-F1 threshold. This comparison comes from a preprint whose authors also built Grounding DINO, so no independent group has checked it.

Independent studies are less favorable. Ramachandran et al. evaluate GPT-4o and other multimodal models on standard vision tasks through prompt chaining. On detection, GPT-4o reaches 60.62 AP50 with this chaining, against 17.69 with direct prompting and 91.30 for the specialist Co-DETR @ramachandran2026gpt4o. The prompting procedure therefore changes the outcome as much as the model does. DetToolChain obtains a similar gain by prompting: GPT-4V and Gemini reach 65.8 AP50 on COCO novel classes, 22.7 points above CORA @wu2024dettoolchain. In both studies, the gain comes from a procedure built around the model, not from the model alone.

Real-world images are harder. Roboflow100-VL collects 100 datasets outside the usual training domains. Zero-shot, Grounding DINO reaches 15.7 mAP over the 100 datasets and Qwen2.5-VL (72B) 5.6, and on the medical datasets the two reach 2.1 and 1.6 mAP @robicheaux2025rf100vl. The authors conclude that open-vocabulary detectors consistently outperform the VLMs they tested.

Two limits remain. These studies use closed models through APIs or older open models, and most report AP, which VLM boxes cannot give because they carry no score (@sec:background). We found no study that compares a recent open VLM with a detector at one fixed operating point on the same real photographs.

== Object Counting
// [budget] 0.40 p
// sources: tamarapalli2025countqa, qharabagh2024lvlmcount, rong2026unicbench, fuzesseery2025counting, amini2024countgd, amini2025countgdpp
Counting is the best-covered task. CountQA uses dense, cluttered scenes and finds that accuracy falls as the count rises @tamarapalli2025countqa. LVLM-Count and UNICBench agree: models are fairly reliable for small counts and degrade for large ones, and UNICBench covers 5,300 images and 21 MLLMs on its image track @qharabagh2024lvlmcount @rong2026unicbench. On the FSC-147 test set, GPT-4o and GPT-5 reach a mean absolute error (MAE) of 20.73 and 20.96, against 15.69 for the best zero-shot specialist in the same table, and on CARPK their errors (30.13 or more) are far above the 8.13 of a specialist counter @fuzesseery2025counting. Both models predict a count of 1 for an image of 2,560 Lego pieces.

HoloCount is the only study we found that evaluates the recent open models on counting. It tests Qwen3.5, Qwen3-VL and Gemma 3 on 2,480 questions: the average exact-match accuracy is 71.4% for Qwen3.5-9B, 58.1% for Qwen3-VL-8B and 48.4% for Gemma3-27B. In high-density scenes, Qwen3.5-27B reaches 20.0% and Gemma3-27B 0.0%. On questions about an object that is absent, Qwen3-VL-8B answers zero correctly in 96.4% of cases and Gemma3-27B in 87.2% @deng2026holocount. It includes no specialist counter.

Specialist counters give a reference. CountGD repurposes Grounding DINO to count from text, exemplars or both @amini2024countgd. Its successor reaches a mean absolute error of 8.39 on FSC-147, against 43.18 for Gemini-2.5 and 40.41 for Molmo @amini2025countgdpp. Both papers come from the same group, and the model was trained on FSC-147, so this is not an independent test. We found no study that compares counts derived from detector boxes with the direct counts of a VLM on the same images.

== Factors Affecting Reliability
// [budget] 0.30 p
// sources: schmalfuss2025parc, ismithdeen2025promptception (prompt); ding2025knowledge, groot2024overconfidence, levine2023calibration (confidence); saxena2026robustbench (domain shift)
*Prompt wording.* Promptception tests 10 models with 61 prompt types and finds accuracy deviations of up to 15% @ismithdeen2025promptception, and PARC measures the sensitivity of 22 VLMs to language and vision prompt variations @schmalfuss2025parc. These studies use multiple-choice questions, not boxes or counts. Ramachandran et al. are the exception: their detection score moves from 17.69 to 60.62 AP50 with the prompting procedure @ramachandran2026gpt4o.

*Confidence.* This is the least studied factor. Zero-shot CLIP is miscalibrated, but one learned temperature corrects it across datasets @levine2023calibration. LLMs and VLMs are overconfident when they state their own uncertainty, including for counting @groot2024overconfidence, and probability and consistency signals are more reliable than verbalized confidence @ding2025knowledge. No study we found addresses the confidence of generated boxes.

*Domain shift.* VLM-RobustBench applies 49 corruption types in 133 settings and reports losses of up to 34 points, with low-severity spatial changes sometimes hurting more than severe photometric ones @saxena2026robustbench. Roboflow100-VL shows the same effect on object detection across domains @robicheaux2025rf100vl. For specialists, a robustness study on COCO-O reports a mean mAP drop of 6.9 points for Grounding DINO (48.4 to 41.5, the clean value taken from its own paper), 15.9 for YOLO-World and 10.4 for OWL-ViT @chhipa2024ovrobust. We found no equivalent measure for VLMs on box or count tasks.

== Synthesis
// [budget] 0.20 p
The evidence is uneven across tasks. Counting is the most studied, and its studies agree that VLMs degrade as the number of objects grows. Presence rests on older benchmarks, and recent work questions what a high yes/no score proves @lan2026seeing. Studies that compare a VLM with a specialist exist for localization and counting, and in most of them the specialist is better, but none exists for presence. Localization is the weakest case: independent comparisons with detectors are few, and most use closed or older models. Across the three tasks, we found no study that tests recent open VLMs against a specialist on the same real photographs, measures prompt robustness on boxes or counts, or reports the confidence of generated boxes. Our experiment addresses the first of these gaps, for one recent open VLM. It does not address the other two.

= Methods <sec:methods>
// [budget] 1.15 p (~800 words)
We compare one VLM with one specialized model on each of the three tasks, using existing benchmark images and one run. Both models receive the same image and the same class name. Thresholds are set on a tuning part of the images and never on the test part.

== Task
We use the three tasks defined in @sec:background. For object presence, the model says whether an object of a given class is in the image. For localization, it returns a box for each instance of the class. For counting, it returns the number of instances.

== Dataset
We reuse the 500 COCO validation images of POPE @li2023pope @lin2014coco, which were chosen for having more than three annotated objects. For presence, we use the POPE questions: six per image, half about a present object and half about an absent one, in its random, popular, and adversarial settings (3,000 questions each). For localization and counting, we take the targets from the COCO annotations of the same images. Each present class gives a query whose targets are its boxes and their number, without crowd regions. Each absent class of the POPE questions gives a negative query, where the correct output is no box and a count of zero.

The images are split once into a tuning part (100 images) and a test part (400 images), with a fixed seed, and the same split is used for all tasks. The test part has 2,400 presence questions per setting and 4,473 localization and counting queries, 2,897 of them negative. The tuning part sets the score thresholds of the specialists.

== Models
The VLM is Qwen3.8-27B @qwen38card, served by Ollama with its default 4-bit tag (18 GB). The specialists are SigLIP 2 for presence @tschannen2025siglip2, YOLO-World for localization @cheng2024yoloworld, and CountGD++ for counting @amini2025countgdpp. We did not use Grounding DINO for localization because CountGD++ extends CountGD, which is built on it @amini2024countgd, so the two specialists would be dependent.

The VLM receives a fixed prompt for each task: "Is there a {class} in the image? Answer yes or no.", "Locate every {class} in the image. Answer with a JSON list of bounding boxes [x1, y1, x2, y2]. Answer [] if there is none.", and "How many {class} are in the image? Answer with a single number." Its reasoning mode is off, its temperature is 0, its seed is fixed, and its context is 4,096 tokens. Its boxes are on a grid of 0 to 999 and are converted to pixels.

SigLIP 2 (so400m, 384 pixels) scores the text "a photo of a {class}". It predicts "present" when the score is above a threshold, chosen to maximize accuracy on the tuning questions of each POPE setting. YOLO-World (yolov8s-worldv2) returns boxes with scores, and we keep those above 0.001. The score threshold is the one that maximizes F1 at IoU 0.5 on the tuning queries, as in @jiang2025rexomni. CountGD++ receives the class name only, without visual exemplars, on the whole image resized to 800 pixels as in the example code of its authors, without the adaptive cropping of their paper. Its count is the number of boxes above a confidence threshold, chosen like the other two on the tuning queries (lowest MAE over a grid from 0.05 to 0.99); we also report the default of its authors, 0.23. As a second presence specialist, we read presence from YOLO-World: the object is present when its best box scores above a threshold, chosen like the one of SigLIP 2.

== Metrics
For presence, we report accuracy, precision, recall, F1, and the share of "yes" answers, for each POPE setting. For localization, we match predicted and true boxes one to one by decreasing IoU, with a minimum IoU of 0.5, and report precision, recall, and F1 over all queries. A box returned for a negative query counts as a false positive. We also report the share of queries for which the VLM returns no box, precision, recall, and F1 on the positive queries alone, and the share of negative queries that receive at least one box. For counting, we report exact-match accuracy, MAE, and RMSE over all queries and by true count (0, 1 to 3, 4 to 9, and 10 or more). For presence and counting, we report the share of VLM answers that cannot be parsed. Such an answer counts as "no" for presence and as zero for counting. Calibration cannot be measured for the VLM, because it returns no confidence for its boxes or counts. We give 95% confidence intervals by bootstrap over the 400 test images (1,000 resamples) for the F1 of presence and localization, the MAE of counting, and the difference between the VLM and each specialist. We resample images rather than queries, because the queries about one image are correlated.

== Implementation
The code is at #todo[GitHub URL and commit] (folder `experiments`). The VLM runs locally with Ollama 0.40.16, installed directly, on an AMD RX 7900 XTX (ROCm). The specialists run with PyTorch 2.15 for ROCm, Transformers (below version 4.50, as required by CountGD++), and Ultralytics. The environment is managed with uv. The weights of CountGD++ come from a fixed revision of its Hugging Face repository. Every model output is saved (VLM answers, and specialist scores and boxes before any threshold), so a run can be resumed, and all metrics and intervals can be recomputed without the models. The VLM answers were obtained on 12 November 2026 and the specialist outputs on 13 November 2026.

= Results <sec:results>
// [budget] 1.40 p (~550 words + Tab. 1 ~0.3 p + Fig. 1 ~0.5 p)
// Tab. 1: VLM vs specialist by task; Fig. 1: qualitative examples and failure cases (todo)
All numbers come from one run on the test part of the 500 POPE images, which is 400 images. The other 100 images set the thresholds of the specialists. Presence has 2,400 questions per POPE setting. Localization and counting share 4,473 queries, and 2,897 of them (65%) ask about a class that is absent from the image. Numbers in brackets are 95% bootstrap intervals over the test images.

*Presence.* The VLM is more accurate than SigLIP 2 in all three settings (@tab:results): 93.3%, 87.9%, and 83.5% against 81.9%, 81.4%, and 76.3%. Both models lose accuracy from the random to the adversarial setting, as in the original POPE results @li2023pope. The two models fail in opposite ways. The VLM finds 92.7% of the present objects in every setting, but its precision falls from 93.8% to 78.3% and its share of "yes" answers rises from 49.4% to 59.2%. SigLIP 2 is cautious: its share of "yes" is 37% to 41%, its recall is 67% to 69%, and its precision stays between 82% and 93%. The tuned thresholds are small (about $4 times 10^(-6)$), so its raw scores cannot be read as probabilities. YOLO-World, read as a presence detector, is a closer baseline: its accuracy is 88.6%, 83.6%, and 78.9%. In F1, the VLM leads SigLIP 2 by 9.8 to 13.9 points and YOLO-World by 4.8 to 7.1 points, and none of the six intervals of the difference contains zero (7.1 [5.0, 8.9] points over YOLO-World in the adversarial setting).

*Localization.* YOLO-World has a higher F1 than the VLM, 56.6% against 49.2% at IoU 0.5, a difference of 7.4 points [4.1, 10.6]. The VLM finds more objects (recall 61.4% against 49.2%) but with many more wrong boxes (precision 41.0% against 66.7%). Much of the gap comes from the absent classes: the VLM returns at least one box for 23.5% of the negative queries, against 6.3% for YOLO-World. On the positive queries alone, the F1 scores are close, 55.9% against 58.6%, although YOLO-World stays more precise (72.4% against 51.3%).

*Counting.* With its threshold tuned on the tuning queries (0.35), CountGD++ is exact for 74.4% of the queries with an MAE of 0.85, against 80.0% and 0.41 for the VLM, a difference in MAE of 0.44 [0.28, 0.61]. The default threshold of its authors does slightly worse (73.8%, MAE 1.08). The average is dominated by the 65% of zero counts, where CountGD++ is almost always right (99.0% against 90.3%). From 1 to 3 objects, CountGD++ is exact for only 32.5% of the queries, against 71.1%, and it mostly counts too few (749 of 1,325 queries, against 146 too many). From 4 up, both models are rarely exact (9.6% and 7.1% for the VLM, 14.4% and 7.1% for CountGD++), as earlier counting studies report for VLMs @tamarapalli2025countqa @rong2026unicbench. On the counts of 10 or more, they err in opposite directions: the VLM gives 5.5 objects on average for 12.1, and CountGD++ gives 24.4, with an MAE of 17.8 against 6.62. These few dense images also explain its RMSE (5.79 against 1.38), with up to 218 books counted where COCO has 13. This comparison is uncertain, because COCO marks dense groups as crowd regions, which we exclude: 43 of the 84 queries with 10 or more objects have one, and the MAE of CountGD++ is 25.8 on them against 9.5 on the others. Part of its excess is probably objects that COCO does not annotate one by one.

*Limits.* These results come from a single run with one VLM, Qwen3.8-27B in its 4-bit Ollama version @qwen38card. The intervals cover the choice of images, not the variation across runs or prompts. VLM boxes have no score, so the VLM has one operating point, while each specialist was set on the tuning part. All images are COCO photographs of common objects, so the results say nothing about other domains. We did not measure prompt robustness or calibration. #todo[Fig. 1: qualitative examples and failure cases.]

#figure(
  {
    set text(size: 7.5pt)
    table(
      columns: (auto, auto, auto, 1fr, 1fr, 1fr),
      inset: (x: 2pt, y: 2pt),
      align: (left, left, left, right, right, right),
      table.header[*Task*][*Setting*][*Metric (%)*][*VLM*][*Specialist*][*Detector*],
      [Presence], [random], [acc. / F1], [93.3 / 93.2], [81.9 / 79.3], [88.6 / 88.2],
      [Presence], [popular], [acc. / F1], [87.9 / 88.4], [81.4 / 78.6], [83.6 / 83.6],
      [Presence], [adversarial], [acc. / F1], [83.5 / 84.9], [76.3 / 73.9], [78.9 / 77.8],
      [Localization], [all queries], [P / R / F1], [41.0 / 61.4 / 49.2], [66.7 / 49.2 / 56.6], [],
      [Localization], [positives], [P / R / F1], [51.3 / 61.4 / 55.9], [72.4 / 49.2 / 58.6], [],
      [Localization], [negatives], [with a box], [23.5], [6.3], [],
      [Counting], [all queries], [exact / MAE], [80.0 / 0.41], [74.4 / 0.85], [],
      [Counting], [true count 0], [exact / MAE], [90.3 / 0.11], [99.0 / 0.03], [],
      [Counting], [true count 1-3], [exact / MAE], [71.1 / 0.34], [32.5 / 1.15], [],
      [Counting], [true count 4-9], [exact / MAE], [9.6 / 3.02], [14.4 / 4.13], [],
      [Counting], [true count 10+], [exact / MAE], [7.1 / 6.62], [7.1 / 17.8], [],
    )
  },
  caption: [VLM (Qwen3.8-27B) and specialist on the test part of the POPE images. Specialist: SigLIP 2 for presence, YOLO-World for localization, and CountGD++ with its threshold tuned on the tuning part for counting. Detector: presence read from the best YOLO-World box. MAE is in counts, not in %.],
) <tab:results>

= Discussion <sec:discussion>
// [budget] 0.80 p (~700 words)
// link each finding to the review themes; limits: dataset choice, one VLM, quantization, possible training-data overlap, no box scores for VLMs
*Main findings.* Neither model is more reliable on every task. The VLM is more accurate than SigLIP 2 for presence and, on average, than CountGD++ for counting, while YOLO-World has the better F1 for localization. The two types of model also fail in opposite ways. The VLM reports too much: it says "yes" more often as the questions become adversarial, it returns a box for 23.5% of the absent classes (6.3% for YOLO-World), and it gives a non-zero count for 9.7% of the queries whose true count is zero (1.0% for CountGD++). The specialists mostly report too little: SigLIP 2 misses about a third of the present objects, YOLO-World finds 49.2% of the true boxes, and CountGD++ counts too few objects for most small groups. The lead of the VLM for presence also holds against YOLO-World read as a presence detector, a closer baseline than SigLIP 2, and every difference between the VLM and a specialist is larger than its 95% interval.

*Link to earlier work.* The drop of the VLM from the random to the adversarial setting, with a stable recall and a falling precision, is consistent with the finding of POPE that objects which co-occur with the present ones are hallucinated more @li2023pope, and with the bias towards "yes" that AMBER reports @wang2023amber. These results are probably favorable to the VLM, because POPE is a comparatively easy presence test. On PVFH-Bench, Qwen3-VL-8B falls from the 88.8% reported for POPE to 58.1% when the absent object looks like a visible one and the question assumes that it exists @wang2026pvfh. For localization, the specialist leads by 7 F1 points at IoU 0.5. This gap is much smaller than the 31 AP50 points that Ramachandran et al. report for GPT-4o, although the metrics differ @ramachandran2026gpt4o. It is in the same direction as the finding of Roboflow100-VL that detectors beat VLMs @robicheaux2025rf100vl. For counting, the drop of the VLM with the true count agrees with CountQA and UNICBench @tamarapalli2025countqa @rong2026unicbench. Its 90.3% of exact answers on zero counts lies between the 96.4% and 87.2% that HoloCount reports for Qwen3-VL-8B and Gemma3-27B on absent objects @deng2026holocount.

*Reliability beyond accuracy.* The VLM has one operating point, because it returns no confidence. We cannot trade its false boxes for missed objects, as we did for YOLO-World with a threshold chosen on the tuning images. The specialists give a score, but it needs tuning: the threshold of SigLIP 2 is about $4 times 10^(-6)$, so its score is not a probability. A combination looks useful. Roboflow100-VL shows that adding SigLIP 2 scores to VLM boxes raises their mAP on a 20-dataset subset, from 7.4 to 9.7 for Qwen2.5-VL and from 5.7 to 8.3 for Gemini 2.5 Pro @robicheaux2025rf100vl @tschannen2025siglip2. The exact-match average for counting also hides the cases that matter. Two thirds of the queries are zero counts, and for counts of 4 or more the VLM is exact in less than 10% of the cases. CountGD++ has the opposite problem on dense scenes, where it gives up to 218 objects when COCO has 13, partly because COCO does not annotate dense groups one by one. Above about ten objects, COCO is therefore a weak test of counting, and a set with complete annotations, such as FSC-147, would be needed.

*Limits.* We tested one VLM, Qwen3.8-27B in its 4-bit version, in one run, and our intervals cover only the choice of images. Other VLMs and other quantizations may behave differently: Gemma3-27B and Qwen3-VL-8B differ clearly on PVFH-Bench and HoloCount. We used a single prompt per task and did not measure its effect, although Ramachandran et al. report a large effect on detection. All images are COCO photographs of common objects. They are likely to be in the pre-training data of the VLM and possibly of the specialists, which we cannot check. CountGD++ was trained on FSC-147 and used here without the adaptive cropping of its paper, which may be unfavorable on COCO; tuning its threshold on COCO already lowered its MAE from 1.08 to 0.85. We did not run a control with a blank image, so a correct presence answer does not prove that the image was used @lan2026seeing. Finally, we measured neither calibration nor robustness to the prompt or the domain, which are two of the three properties of reliability defined in @sec:background.

= Conclusion <sec:conclusion>
// [budget] 0.35 p (~300 words)
On common objects in COCO photographs, one recent VLM, Qwen3.8-27B, was more accurate than the specialists for object presence, including YOLO-World read as a presence detector, and, over all counting queries, for counting. It was behind YOLO-World for localization by 7 F1 points at IoU 0.5. In this test, the VLM could replace the specialist for presence on common objects. We could not show that it is reliable in the broader sense that we defined: we measured accuracy and the behavior on absent objects, but not calibration or robustness. The VLM reports too much: it says "yes" more often on adversarial questions, it returns boxes for absent objects, and it is exact on only a small share of the counts of four or more. It returns no confidence, so its errors cannot be traded against each other. The specialists miss more objects, and their scores must be tuned before use. The review shows that this comparison is rarely made: no study compares a VLM with a specialist for presence, and we found no independent evaluation of the recent Qwen and Gemma models for localization.

Several steps would make these results firmer. We would test more VLMs and quantizations, such as Gemma 4. We would measure the effect of the prompt, add a control with a blank image, and use harder presence questions such as those of PVFH-Bench. We would count dense scenes on a set with complete annotations, and evaluate localization at a stricter IoU. We would also run out-of-domain images, for example from Roboflow100-VL and FSC-147. Finally, giving the VLM a confidence, for example from SigLIP 2 scores or from token probabilities, would let us measure the third property of reliability, calibration.

#heading(numbering: none)[Statement on the Use of AI]
Both authors used Claude (Anthropic) in preparing this paper. One author used it through Claude Code with the Academic Research Skills plugin (version 3.23.1) and the alphaXiv tool, in October and November 2026, to search and summarize the literature, to draft and revise the text of the Review, Methods and Results sections, to write all the experiment code and the Typst formatting, to compute derived figures from the result files, and to check the bibliography against arXiv. The authors then reviewed the text produced with AI and take full responsibility for the content of the paper. The AI tools are not authors of this paper.
