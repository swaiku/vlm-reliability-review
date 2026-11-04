#import "@preview/charged-ieee:0.1.4": ieee

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

It is hard to draw one clear conclusion about VLM reliability because studies test different tasks, models, images, and measures. Specialized systems also exist for many extraction tasks. Comparing VLMs with these systems can show where a general model is strong and where it falls short. This paper reviews results from previous studies on classification, counting, and localization, together with related reliability issues. We then focus on object localization in real-world images and compare VLMs with specialized open-vocabulary object detectors.

== Research question
// [budget] 2 sentences max
How Reliable Are Vision-Language Models for Visual Information Extraction?

== Contributions
// [budget] 3 bullets, 1 line each. Contribution wording is yours to write.
- A narrative review of previous studies on VLM reliability in classification, counting, and localization.
- An experiment that compares VLMs with open-vocabulary detectors on object localization in real-world images.
- An analysis of where the models make errors and which questions remain open.

== Paper overview
// [budget] 3 lines
@sec:background explains the models and evaluation measures. @sec:review summarizes the evidence on VLM reliability. @sec:methods describes the experiment, @sec:results reports its results, and @sec:discussion discusses their meaning and limits. @sec:conclusion closes the paper.

= Background <sec:background>

This section explains the two types of models that we compare and how their outputs are evaluated. General VLMs answer in free text. Open-vocabulary detectors return boxes with a score. This difference matters when we measure reliability.

== Vision-Language Models
A VLM takes an image and a text prompt as input and writes a text answer. Most current models connect a vision encoder to a large language model (LLM). The vision encoder turns the image into a sequence of visual tokens. The LLM reads these tokens together with the prompt and generates the answer one token at a time. Open models such as Qwen2.5-VL, Qwen3-VL, and Molmo follow this design @bai2025qwen25vl @qwen3vl2025 @deitke2025molmo. Because the answer is text, one model can handle many tasks. It can say whether an object is present, name its class, or give the number of instances.

Localization is harder to express in text. Kosmos-2 was an early model that linked words in its answer to location tokens in the image @peng2023kosmos2. Recent models are trained to write box or point coordinates directly in their answer @bai2025qwen25vl @qwen3vl2025, and Molmo is trained with 2D pointing data @deitke2025molmo. Rex-Omni goes further and treats detection as the prediction of coordinates, one token after the other @jiang2025rexomni. For a user, a box from a VLM is therefore a piece of text. It must follow the expected format, be parsed, and be mapped back to image pixels, and the coordinate format differs between model families. A VLM also does not return a confidence score for each box, as a detector does. @sapkota2025review gives a wider overview of object detection with VLMs.

== Open-Vocabulary Object Detection
A classic object detector is trained on a fixed list of classes. An open-vocabulary detector takes class names or short phrases as text input, so it can search for categories that were not in its training labels. Grounding DINO extends the DINO transformer detector with grounded pre-training on image-text data, and it fuses text and image features to find the objects named in the prompt @liu2023groundingdino. YOLO-World adds vision-language pre-training to the fast YOLO detectors and is designed for real-time use @cheng2024yoloworld. Other work scales the training data with self-training on web images @minderer2023owlv2 or uses an LLM to supervise the detector @fu2025llmdet.

For each image and prompt, these detectors return a list of boxes. Each box has coordinates, a label taken from the prompt, and a confidence score. The user keeps the boxes with a score above a threshold. A high threshold misses more objects, and a low threshold adds more false detections. Other answers can be derived from the kept boxes: an object is present if at least one box remains, and the count is the number of boxes. Unlike VLMs, these detectors cannot answer general questions, but their output has a fixed format. Their results are often called zero-shot when the test classes or datasets were not used in training. With large pre-training data, this is hard to check.

== Evaluation of Visual Information Extraction
We consider four extraction tasks. *Object presence* asks whether an object of a given class is in the image. *Classification* asks for the class of an object or image. *Counting* asks for the number of instances of a class. *Localization* asks where each instance is, given as a bounding box.

Presence and classification are scored with accuracy. For yes/no questions, precision, recall, and F1 score are also used, because a model that answers "yes" too often can still look accurate. POPE asks such yes/no questions about objects that are present and objects that are absent @li2023pope. When a model reports an object that is not in the image, this is called object hallucination @bai2024survey @liu2024survey. Many benchmarks use multiple-choice questions instead. The order of the options can change the answer, so MMBench asks the same question several times with the options shifted and counts it as correct only if every answer is correct @liu2024mmbench.

Counting is scored with exact-match accuracy or with the mean absolute error between the predicted and true counts. Common datasets range from images with many objects of one class, such as cars in parking lots, to cluttered real-world photos @jiang2023clipcount @fuzesseery2025counting @tamarapalli2025countqa.

Localization compares a predicted box $B_p$ with a ground-truth box $B_g$ using the intersection over union (IoU):
$ "IoU"(B_p, B_g) = abs(B_p inter B_g) / abs(B_p union B_g). $
A predicted box is a true positive if its IoU with a not yet matched ground-truth box is above a threshold, often 0.5. Precision is the share of predicted boxes that are correct, and recall is the share of ground-truth boxes that are found. Detectors are usually compared with average precision (AP). The boxes are ranked by score, and AP summarizes the precision-recall curve obtained over all score thresholds. AP50 uses an IoU threshold of 0.5, and mean AP (mAP) averages AP over classes and, on COCO, over several IoU thresholds. Results are reported on datasets such as COCO and LVIS @liu2023groundingdino @cheng2024yoloworld, and on multi-domain sets such as ODinW and Roboflow100-VL @qwen3vl2025 @robicheaux2025rf100vl. Since VLM boxes have no score, AP cannot be computed in the usual way for them. A fair comparison with detectors must then use measures at a fixed operating point, such as precision, recall, and F1 score.

A reliable system must also say when the object is not there. OmniLabel adds negative descriptions that match no object in the image @schulter2023omnilabel, and GroundingME tests whether models reject queries that cannot be grounded @li2025groundingme.

Finally, in this paper we use reliability in a broader sense than accuracy. A reliable model gives correct answers, keeps them when the prompt is reworded without changing its meaning @sclar2024format @schmalfuss2025parc, and expresses a confidence that matches its chance of being right. A model with this last property is called calibrated: among answers given with 80% confidence, about 80% should be correct @levine2023calibration @groot2024overconfidence.

= Reliability of VLMs: A Review <sec:review>
#todo[Explain the review approach and summarize the evidence across the three tasks.]

== Object Presence
#todo[Review object hallucination, absence queries, and false positives.]

== Object Localization
#todo[Review visual grounding, box quality, and comparisons with specialized detectors.]

== Object Counting
#todo[Review direct counting and counting from localized objects.]

== Factors Affecting Reliability
#todo[Discuss prompt wording, confidence, and domain shift across the three tasks.]

== Synthesis
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
#todo[Present model comparisons and illustrative errors.]

= Discussion <sec:discussion>
#todo[Interpret the results, limitations, and practical implications.]

= Conclusion <sec:conclusion>
#todo[Answer the research question and outline future work.]
