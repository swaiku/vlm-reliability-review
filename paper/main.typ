#import "@preview/charged-ieee:0.1.4": ieee

// --- Figure helpers ---
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": chart
#let cols = (rgb("#d95f02"), rgb("#1b6ca8"), rgb("#8c8c8c"))
#let legend(items) = {
  set text(size: 7.5pt)
  items
    .enumerate()
    .map(((i, s)) => box(rect(width: 7pt, height: 5pt, fill: cols.at(i), stroke: none)) + " " + s)
    .join(h(10pt))
}
#let cols-chart(title, data, w: 5.4, h: 2.6, tick: 25) = {
  let n = data.first().len() - 1
  align(center, text(size: 7.5pt, weight: "bold", title))
  v(-2pt)
  cetz.canvas({
    chart.columnchart(
      data,
      mode: "clustered",
      label-key: 0,
      value-key: range(1, n + 1),
      size: (w, h),
      bar-width: 0.8,
      y-min: 0,
      y-max: 100,
      y-tick-step: tick,
      x-label: none,
      y-label: none,
      bar-style: i => (fill: cols.at(i), stroke: none),
    )
  })
}
#let node(body) = rect(width: 100%, inset: 3pt, radius: 2pt, fill: luma(245), stroke: 0.5pt + luma(130), align(
  center + horizon,
  text(size: 7pt, body),
))
#let level(s) = s

#show: ieee.with(
  title: [How Reliable Are Vision-Language Models for Visual Information Extraction?],
  abstract: [
    Vision-language models (VLMs) can answer questions about images, but it is unclear how far their answers can be trusted for deciding whether an object is present, locating it, and counting it. We review previous studies of these tasks and find uneven evidence: counting is the best covered, no study we found compares a VLM with a specialist for presence, and recent models are rarely evaluated independently. We then compare one recent VLM, Qwen3.8-27B, with one specialized model per task on 500 COCO photographs. The VLM is more accurate for presence than SigLIP 2 and than YOLO-World read as a presence detector (83.5% to 93.3% against 78.9% to 88.6% for YOLO-World), and it has a lower counting error than CountGD++ (mean absolute error 0.41 against 0.85). This lead comes from small groups, where CountGD++, used without visual exemplars, counts too few, and from its overcounts in dense scenes. YOLO-World has the better localization F1 score (56.6% against 49.2%). Over the test images, the 95% bootstrap interval of each difference excludes zero. However, the VLM returns boxes for 23.5% of the absent classes, against 6.3% for YOLO-World, is exact for fewer than 10% of the counts of four or more, and gives no confidence. With one VLM, one prompt, and COCO images, a VLM can match or beat small specialists on some tasks, but it needs checks for false detections and large counts.
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

Vision-Language Models (VLMs) can answer questions about images and describe what they show. Visual information extraction covers many tasks. A model may need to decide whether an object is present, classify it, count its instances, describe its attributes, or locate it with coordinates or bounding boxes. It may also need to describe relations between objects, such as distance or depth, and read text in a scene. VLMs offer one general way to approach these tasks. However, an answer is only useful if it is reliable, and studies have reported errors in object presence, counting, and visual grounding @li2023pope @tamarapalli2025countqa @li2025groundingme.

It is hard to draw one clear conclusion about VLM reliability because studies test different tasks, models, images, and measures. Specialized systems also exist for many extraction tasks, and few of the studies we reviewed compare a VLM with such a system on the same real-world images. Such a comparison can show where a general model is strong and where it falls short. This paper reviews results from previous studies on object presence, localization, and counting, together with factors that affect reliability; attributes, relations, and text reading are outside its scope. We then compare one VLM with one specialized model for each of these three tasks on real-world images.

== Research question
To what extent are VLMs reliable for visual information extraction from the real world?

== Contributions
- A narrative review of previous studies on VLM reliability for object presence, localization, and counting.
- An experiment on real-world images that compares one VLM with one specialized model for each of the three tasks.
- An analysis of where the models make errors and which questions remain open.

= Background <sec:background>

In this paper, a model is reliable for visual information extraction when a user can trust its output without checking every image by hand. This needs more than a high average score, so we look at three properties. The output must be correct, which includes saying when an object is absent instead of inventing one @li2023pope @li2025groundingme. It must also be stable when the prompt is reworded or the images come from a new domain @schmalfuss2025parc @robicheaux2025rf100vl. Finally, the model should be calibrated, meaning that its confidence matches its chance of being right @levine2023calibration @groot2024overconfidence.

These properties apply to both types of models that we compare, even though VLMs answer in free text while open-vocabulary detectors return boxes, each with a confidence score.

== Vision-Language Models
A VLM takes an image and a text prompt as input and writes a text answer. Most current models do this by connecting a vision encoder to a large language model (LLM): the encoder turns the image into a sequence of visual tokens, and the LLM reads these tokens together with the prompt before it generates the answer one token at a time. Open models such as Qwen2.5-VL, Qwen3-VL, and Molmo follow this design @bai2025qwen25vl @qwen3vl2025 @deitke2025molmo. Since the answer is plain text, the same model can handle many tasks without any change, whether the question asks if an object is present, what class it belongs to, or how many instances there are.

Localization fits less naturally in this setting, because a position in the image has to be written as text. Kosmos-2 was one of the first models to address this, by linking words in its answer to special location tokens @peng2023kosmos2. More recent models are trained to write box or point coordinates directly in their answer @bai2025qwen25vl @qwen3vl2025, and Molmo learns to point at objects from 2D pointing data @deitke2025molmo. Rex-Omni goes one step further and treats the whole detection task as the prediction of coordinates, one token after the other @jiang2025rexomni. For the user, however, a box from a VLM remains a piece of text. It must follow the expected format so that it can be parsed and mapped back to image pixels, which is not trivial because the coordinate format differs between model families. In addition, a VLM does not attach a confidence score to each box as a detector does, which makes its output harder to filter and to evaluate.

== Open-Vocabulary Object Detection
A classic object detector is trained on a fixed list of classes and cannot find anything outside this list. Open-vocabulary detectors remove this limit by taking class names or short phrases as text input, so that they can also search for categories that were not in their training labels. Grounding DINO, for example, extends the DINO transformer detector with grounded pre-training on image-text data, and it fuses text and image features to find the objects named in the prompt @liu2023groundingdino. YOLO-World follows a similar idea but builds on the fast YOLO detectors, which makes it suitable for real-time use @cheng2024yoloworld. Other work improves these detectors by scaling the training data through self-training on web images @minderer2023owlv2 or by using an LLM to supervise the training @fu2025llmdet.

#figure(
  image("figures/yolo_world.png", width: 100%),
  caption: [Overall architecture of YOLO-World from @cheng2024yoloworld.],
) <fig:yolo-world>

Given an image and a prompt, these detectors return a list of boxes, each with its coordinates, a label taken from the prompt, and a confidence score. The user then keeps only the boxes whose score is above a threshold. This threshold sets a trade-off: a high value misses more objects, whereas a low value adds more false detections. The kept boxes also answer the other extraction tasks, since an object is present when at least one box remains and the count is simply the number of boxes. In contrast to VLMs, these detectors cannot answer general questions, but their output always has the same format and is easy to evaluate.

Two other specialized models are used in this paper. SigLIP 2 is a pair of image and text encoders trained with a sigmoid loss on image-text pairs @tschannen2025siglip2. It gives a similarity score between an image and a text, which can be turned into a presence decision with a threshold, but it gives no box. CountGD builds on Grounding DINO to count the objects named in a text prompt, with or without visual exemplars @amini2024countgd, and CountGD++ extends it with negative prompts and pseudo-exemplars @amini2025countgdpp. Like a detector, they return boxes with confidence scores, and the count is the number of boxes above a threshold. CountGD++ was trained on FSC-147.

== Evaluation of Visual Information Extraction
We consider three extraction tasks, which range from a simple yes/no answer to a precise position. *Object presence* asks whether an object of a given class is in the image. *Counting* then asks for the number of instances of a class, while *localization* asks where each instance is, given as a bounding box. Classification, which asks for the class of an object or of the whole image, is close to presence and is scored in the same way.

Presence and classification are mainly scored with accuracy. For yes/no questions, precision, recall, and F1 score are reported as well, because a model that answers "yes" too often can still reach a good accuracy. POPE uses this kind of question and asks about objects that are present as well as objects that are absent @li2023pope. Answering "yes" for an absent object is a case of object hallucination, which happens when a model reports something that is not in the image @bai2024survey @liu2024survey.

Counting is scored with exact-match accuracy or with the mean absolute error between the predicted and true counts. The datasets used for this task range from images that contain many objects of one class, such as cars in parking lots, to cluttered real-world photos @jiang2023clipcount @fuzesseery2025counting @tamarapalli2025countqa.

For localization, a predicted box $B_p$ is compared with a ground-truth box $B_g$ using the intersection over union (IoU):
$ "IoU"(B_p, B_g) = abs(B_p inter B_g) / abs(B_p union B_g). $
A predicted box counts as a true positive when its IoU with a ground-truth box that has not yet been matched reaches a threshold, often 0.5. From these matches, precision gives the share of predicted boxes that are correct, and recall gives the share of ground-truth boxes that are found. Detectors are usually compared with average precision (AP), which ranks the boxes by score and summarizes the precision-recall curve obtained over all score thresholds. AP50 fixes the IoU threshold at 0.5, while mean AP (mAP) averages AP over classes and, on COCO, also over several IoU thresholds. Such results are reported on datasets such as COCO and LVIS @liu2023groundingdino @cheng2024yoloworld, and also on sets that cover many different domains, such as ODinW and Roboflow100-VL @qwen3vl2025 @robicheaux2025rf100vl. Because VLM boxes have no score, AP cannot be computed for them in the usual way. A fair comparison with detectors must therefore rely on measures at a fixed operating point, such as precision, recall, and F1 score.

Finally, a reliable system must also be able to say that an object is not there, which these measures capture only in part. For this reason, OmniLabel adds negative descriptions that match no object in the image @schulter2023omnilabel, and GroundingME tests whether models reject queries that cannot be grounded @li2025groundingme.

= Reliability of VLMs: A Review <sec:review>
This review is narrative, not systematic. Between October and November 2026, with the help of an AI assistant, we started from well-known works that the assistant proposed, looked each one up on arXiv or conference pages, and ran about fifteen web queries to fill the gaps. No bibliographic database was queried, and the assistant alone screened the results, without a second reader. We kept a study when it measures one of the three tasks, a specialized model for one of them, or a factor that affects reliability. Of the 43 works cited, the assistant read 23 in full to check the figures we report, and four (Ramachandran et al., DetToolChain, Promptception, UNICBench) only in the passages that give them. The others, mostly cited for their design, were read in the abstract, the only check of our figures for HallusionBench and Grounding DINO. Both authors read in full the three studies the paper relies on most: POPE, Roboflow100-VL, and Ramachandran et al. The queries, the selection, and the reading level of each source are listed in the `review` folder of the repository given in @sec:methods. A statement that no study exists therefore means that we found none. We first review the evidence for object presence, localization, and counting, then the factors that cut across them: prompt wording, confidence, and domain shift.

== Object Presence
Object hallucination, where a model reports an object that is not in the image, is the best-studied reliability problem for presence @bai2024survey. POPE turns it into yes/no polling questions and finds that frequent and co-occurring objects are hallucinated more often @li2023pope. AMBER adds an evaluation without an LLM judge and shows the same asymmetry: for the nine models it tests, recall on the questions whose true answer is "no" is far below precision, so the models answer "yes" too readily @wang2023amber.

A correct answer does not prove that the image was used. HallusionBench pairs questions with edited images to separate language hallucination from visual illusion, and GPT-4V reaches only 31.42% question-pair accuracy @guan2024hallusionbench. MERLIM removes an object by inpainting and finds that the best models lose the most precision on the edited images, which suggests that some correct answers come from the language prior or the global context @villa2023merlim. A similar signal appears on POPE: removing 75% of the image tokens lowers accuracy by only about 3 points for two of the five open models tested, on a 300-example subset @lan2026seeing.

Few studies test whether a model can refuse a query that it cannot ground. GroundingME evaluates this rejection and reports that most models do it poorly @li2025groundingme. PVFH-Bench tests recent models on 258 COCO images, with an absent object that looks like a visible one. Qwen3-VL-8B answers 98.45% of the questions about the visible object correctly, but only 80.62% for the look-alike absent object and 58.14% once a false premise is added. Gemma-3-27B-IT falls from 98.84% to 28.29% @wang2026pvfh. Most other presence benchmarks, such as POPE and AMBER, evaluate 2023-era models. We found no study that compares a VLM with a specialist on object presence. The closest evidence is for whole-image classification, not for an object in a scene: GPT-4 reaches 60.6% on ImageNet, against 79.2% for the CLIP model EVA-G @zhang2024classification.

== Object Localization
Open-vocabulary detectors such as Grounding DINO and YOLO-World are the usual reference for localizing a named object @liu2023groundingdino @cheng2024yoloworld. Recent VLMs now write boxes directly. On COCO, Rex-Omni reaches an F1 of 72.0 at IoU 0.5 against 69.8 for Grounding DINO, but at IoU 0.95 the detector is better (Grounding DINO 23.0, Rex-Omni 15.9), and Qwen2.5-VL-7B reaches 64.0 at IoU 0.5 @jiang2025rexomni. Because VLM boxes have no score, the detectors are compared at their best-F1 threshold. This comparison comes from a preprint whose authors also built Grounding DINO, so no independent group has checked it.

Independent studies are less favorable. Ramachandran et al. evaluate GPT-4o and other multimodal models on standard vision tasks through prompt chaining. On detection, GPT-4o reaches 60.62 AP50 with this chaining, against 17.69 with direct prompting and 91.30 for the specialist Co-DETR @ramachandran2026gpt4o. The prompting procedure therefore changes the outcome as much as the model does. DetToolChain obtains a similar gain by prompting: GPT-4V and Gemini reach 65.8 AP50 on COCO novel classes, 22.7 points above CORA @wu2024dettoolchain. In both studies, the gain comes from a procedure built around the model, not from the model alone.

Real-world images are harder. Roboflow100-VL collects 100 datasets outside the usual training domains. Zero-shot, Grounding DINO reaches 15.7 mAP over the 100 datasets and Qwen2.5-VL (72B) 5.6, and on the medical datasets the two reach 2.1 and 1.6 mAP @robicheaux2025rf100vl. The authors conclude that open-vocabulary detectors consistently outperform the VLMs they tested.

Two limits remain. These studies use closed models through APIs or older open models, and most report AP, which VLM boxes cannot give because they carry no score (@sec:background). We found no study that compares a recent open VLM with a detector at one fixed operating point on the same real photographs.

== Object Counting
Counting is the best-covered task. CountQA uses dense, cluttered scenes and finds that accuracy falls as the count rises @tamarapalli2025countqa. LVLM-Count and UNICBench agree: models are fairly reliable for small counts and degrade for large ones, and UNICBench covers 5,300 images and 21 MLLMs on its image track @qharabagh2024lvlmcount @rong2026unicbench. On the FSC-147 test set, GPT-4o and GPT-5 reach a mean absolute error (MAE) of 20.73 and 20.96, against 15.69 for the best zero-shot specialist in the same table (16.2 and 16.8 when the authors skip the images with the largest errors), and on CARPK their errors (30.13 or more) are far above the 8.13 of a specialist counter @fuzesseery2025counting. Both models predict a count of 1 for an image of 2,560 Lego pieces.

HoloCount is the only study we found that evaluates the recent open models on counting. It tests Qwen3.5, Qwen3-VL and Gemma 3 on 2,480 questions: the average exact-match accuracy is 71.4% for Qwen3.5-9B in thinking mode (57.5% without), 58.1% for Qwen3-VL-8B-Instruct and 48.4% for Gemma3-27B. In high-density scenes, Qwen3.5-27B in thinking mode reaches 20.0% and Gemma3-27B 0.0%. On questions about an object that is absent, Qwen3-VL-8B answers zero correctly in 96.4% of cases and Gemma3-27B in 87.2% @deng2026holocount. It includes no specialist counter.

Specialist counters give a reference. CountGD repurposes Grounding DINO to count from text, exemplars or both @amini2024countgd. Its successor reaches a mean absolute error of 8.39 on FSC-147, against 43.18 for Gemini-2.5 and 40.41 for Molmo @amini2025countgdpp. This figure uses pseudo-exemplars and synthetic exemplars generated from the class name, which our experiment does not use (16.55 with the class name alone). Both papers come from the same group, and the model was trained on FSC-147, so this is not an independent test. We found no study that compares counts derived from detector boxes with the direct counts of a VLM on the same images.

== Factors Affecting Reliability
*Prompt wording.* Promptception tests 10 models with 61 prompt types and finds accuracy deviations of up to 15% @ismithdeen2025promptception, and PARC measures the sensitivity of 22 VLMs to language and vision prompt variations @schmalfuss2025parc. These studies use multiple-choice questions, not boxes or counts. Ramachandran et al. are the exception: their detection score moves from 17.69 to 60.62 AP50 with the prompting procedure @ramachandran2026gpt4o.

*Confidence.* This is the least studied factor. Zero-shot CLIP is miscalibrated, but one learned temperature corrects it across datasets @levine2023calibration. LLMs and VLMs are overconfident when they state their own uncertainty, including for counting @groot2024overconfidence, and probability and consistency signals are more reliable than verbalized confidence @ding2025knowledge. No study we found addresses the confidence of generated boxes.

*Domain shift.* VLM-RobustBench applies 49 corruption types in 133 settings and reports losses of up to 34 points, with low-severity spatial changes sometimes hurting more than severe photometric ones @saxena2026robustbench. For object detection, Roboflow100-VL finds low zero-shot scores for both detectors and VLMs on domains outside their usual training data (15.7 mAP for Grounding DINO and 5.6 for Qwen2.5-VL) @robicheaux2025rf100vl. For specialists, a robustness study on COCO-O reports a mean mAP drop of 6.9 points for Grounding DINO (48.4 to 41.5, the clean value taken from its own paper), 15.9 for YOLO-World and 10.4 for OWL-ViT @chhipa2024ovrobust. We found no equivalent measure for VLMs on box or count tasks.

== Synthesis
The evidence is uneven across tasks. Counting is the most studied, and its studies agree that VLMs degrade as the number of objects grows. Presence rests on older benchmarks, and recent work questions what a high yes/no score proves @lan2026seeing. Studies that compare a VLM with a specialist exist for localization and counting, and in most of them the specialist is better, but none exists for presence. For localization, comparisons with detectors are the most numerous, but the independent ones use closed or older models, so recent open models remain untested. We found no study that tests recent open VLMs against a specialist on the same real photographs, measures prompt robustness on presence answers or counts, or reports the confidence of generated boxes. Our experiment addresses the first of these gaps, for one recent open VLM.


#figure(
  {
    set text(size: 7.5pt)
    table(
      columns: (auto, 1fr, 1fr, 1fr, 1fr),
      inset: (x: 3pt, y: 2.2pt),
      stroke: none,
      align: (left, center, center, center, center),
      table.hline(stroke: 0.8pt),
      table.header[*Task*][*Recent VLMs*][*Vs specialist*][*Prompt*][*Confidence*],
      table.hline(stroke: 0.4pt),
      [Presence], [limited], [none], [none], [limited],
      [Localization], [limited], [found], [limited], [none],
      [Counting], [limited], [found], [none], [limited],
      table.hline(stroke: 0.8pt),
    )
  },
  caption: [Evidence found in the studies of this review, for independent studies of recent open VLMs, comparisons with a specialist, prompt robustness, and confidence of the outputs. "Found": several studies, at least one of them independent. "Limited": one study, older or closed models, or not independent. "None": no study found. Prompt robustness counts only when it is measured on the output of the task, not on multiple-choice questions.],
) <tab:evidence>

= Methods <sec:methods>
We compare one VLM with one specialized model on each of the three tasks of @sec:background, using existing benchmark images and one run. Both models receive the same image and the same class name. Thresholds are set on a tuning part of the images and never on the test part.


#figure(
  {
    import cetz.draw: *
    let box-txt(w, body) = box(width: w, align(center, text(size: 6.5pt, body)))
    cetz.canvas({
      let st(c) = (fill: c.lighten(88%), stroke: 0.7pt + c, radius: 0.08)
      content((0.9, 0), box-txt(1.5cm)[*Input*\ image and\ class name], frame: "rect", padding: 3pt, name: "in", ..st(
        luma(90),
      ))
      content(
        (4.25, 0.72),
        box-txt(3cm)[*VLM*\ fixed prompt, temperature 0,\ answer parsed],
        frame: "rect",
        padding: 3pt,
        name: "vlm",
        ..st(luma(90)),
      )
      content(
        (4.25, -0.72),
        box-txt(3cm)[*Specialist*\ score or boxes above a threshold\ tuned on 100 images],
        frame: "rect",
        padding: 3pt,
        name: "spec",
        ..st(luma(90)),
      )
      content(
        (7.7, 0),
        box-txt(1.9cm)[*Same outputs*\ presence, boxes,\ count\ #sym.arrow.b\ *Metrics*\ 400 test images],
        frame: "rect",
        padding: 3pt,
        name: "out",
        ..st(luma(90)),
      )
      set-style(mark: (end: "stealth", fill: black, scale: 0.6), stroke: 0.6pt)
      line("in.east", "vlm.west")
      line("in.east", "spec.west")
      line("vlm.east", "out.west")
      line("spec.east", "out.west")
    })
  },
  caption: [Protocol: both models receive the same image and class name, and their outputs are scored with the same metrics, with 95% bootstrap intervals over images.],
) <fig:protocol>

== Dataset
We reuse the 500 COCO validation images of POPE @li2023pope @lin2014coco, which were chosen for having more than three annotated objects. For presence, we use the POPE questions: six per image, half about a present object and half about an absent one, in its random, popular, and adversarial settings (3,000 questions each). For localization and counting, we take the targets from the COCO annotations of the same images. Each class annotated in the image gives a query whose targets are its boxes and their number, without crowd regions. Each class that POPE asks about as absent, in any of its three settings, gives one negative query, where the correct output is no box and a count of zero. A class asked in several settings gives a single query, so the random, popular, and adversarial absent classes are pooled for these two tasks.

The images are split once into a tuning part (100 images) and a test part (400 images), with a fixed seed, and the same split is used for all tasks. The test part has 2,400 presence questions per setting and 4,473 localization and counting queries, 2,897 of them negative. The tuning part sets the score thresholds of the specialists.

== Models
The VLM is Qwen3.8-27B @qwen38card, served by Ollama with its default 4-bit tag (18 GB). The specialists are SigLIP 2 for presence @tschannen2025siglip2, YOLO-World for localization @cheng2024yoloworld, and CountGD++ for counting @amini2025countgdpp. Grounding DINO, the reference detector of the studies in @sec:review, is supported by our code but was not run.

The VLM receives a fixed prompt for each task: "Is there a {class} in the image? Answer yes or no.", "Locate every {class} in the image. Answer with a JSON list of bounding boxes [x1, y1, x2, y2]. Answer [] if there is none.", and "How many {class} are in the image? Answer with a single number." Its reasoning mode is off, its temperature is 0, its seed is fixed, and its context is 4,096 tokens. Its boxes are on a grid of 0 to 999 and are converted to pixels.

SigLIP 2 (so400m, 384 pixels) scores the text "a photo of a {class}". It predicts "present" when the score is above a threshold, chosen to maximize accuracy on the tuning questions of each POPE setting. YOLO-World (yolov8s-worldv2) returns boxes with scores, and we keep those above 0.001. The score threshold is the one that maximizes F1 at IoU 0.5 on the tuning queries, as in @jiang2025rexomni. CountGD++ receives the class name only, without visual exemplars, on the whole image resized to 800 pixels as in the example code of its authors, without the adaptive cropping of their paper. Its count is the number of boxes above a confidence threshold, chosen like the other two on the tuning queries (lowest MAE over a grid from 0.05 to 0.99); we also report the default of its authors, 0.23. As a second presence specialist, we read presence from YOLO-World: the object is present when its best box scores above a threshold, chosen like the one of SigLIP 2.

== Metrics
For presence, we report accuracy, precision, recall, F1, and the share of "yes" answers, for each POPE setting. For localization, we match predicted and true boxes one to one by decreasing IoU, with a minimum IoU of 0.5, and report precision, recall, and F1 over all queries. A box returned for a negative query counts as a false positive. Unlike in the COCO evaluation, crowd regions are not ignored, so a box on one is a false positive. We also report the share of queries for which the VLM returns no box, precision, recall, and F1 on the positive queries alone, and the share of negative queries that receive at least one box. For counting, we report exact-match accuracy, MAE, and root mean squared error (RMSE) over all queries and by true count (0, 1 to 3, 4 to 9, and 10 or more). For presence and counting, we report the share of VLM answers that cannot be parsed. Such an answer counts as "no" for presence and as zero for counting. For localization, an unreadable answer gives no box, like an empty list, and we did not count such answers. Calibration cannot be measured for the VLM, because it returns no confidence for its boxes or counts. We give 95% confidence intervals by bootstrap over the 400 test images (1,000 resamples) for the F1 of presence and localization, the MAE of counting, and the difference between the VLM and each specialist. We resample images rather than queries, because the queries about one image are correlated.

== Implementation
The code is at #link("https://github.com/swaiku/vlm-reliability-review") (folder `experiments`). The VLM runs locally with Ollama 0.40.16, installed directly, on an AMD RX 7900 XTX (ROCm). The specialists run with PyTorch 2.15 for ROCm, Transformers 4.57, and Ultralytics 8.4. The environment is managed with uv. The weights of CountGD++ come from a fixed revision of its Hugging Face repository. Every model output is saved (VLM answers, and specialist scores and boxes before any threshold), so a run can be resumed, and all metrics and intervals can be recomputed without the models. The VLM answers were obtained on 12 November 2026 and the specialist outputs on 13 November 2026.

= Results <sec:results>
All numbers come from one run on the 400 test images, and 65% of the localization and counting queries ask about an absent class. Numbers in brackets are 95% bootstrap intervals over the test images.

*Presence.* The VLM is more accurate than SigLIP 2 in all three settings (@tab:results), and both models lose accuracy from the random to the adversarial setting, as in the original POPE results @li2023pope. At most 0.13% of the VLM answers cannot be parsed. The two models fail in opposite ways. The VLM finds 92.7% of the present objects in every setting, since the settings differ only in their absent objects, but its precision falls from 93.8% to 78.3% as its share of "yes" answers rises from 49% to 59%. SigLIP 2 is cautious: it says "yes" to at most 41% of the questions and finds only about two thirds of the present objects. Its tuned thresholds are tiny (about $4 times 10^(-6)$), so its raw scores cannot be read as probabilities. YOLO-World, read as a presence detector, is a closer baseline. In F1, the VLM leads SigLIP 2 by 9.8 to 13.9 points and YOLO-World by 4.8 to 7.1 points, and no interval of the difference contains zero (7.1 [5.0, 8.9] over YOLO-World, adversarial setting).

*Localization.* At IoU 0.5, YOLO-World has a higher F1 than the VLM (YOLO-World 56.6%, VLM 49.2%), a difference of 7.4 points [4.1, 10.6]. The VLM finds more objects (recall: VLM 61.4%, YOLO-World 49.2%) but returns many more wrong boxes (precision: VLM 41.0%, YOLO-World 66.7%). Some of these may fall on crowd regions (@sec:methods), which we did not measure. Much of the gap comes from the absent classes: the VLM returns at least one box for 23.5% of the negative queries, and YOLO-World for 6.3%. It returns no box (empty or unreadable answer) for 50.7% of all queries, almost all of them about absent classes, so it rarely misses a present class entirely. On the positive queries alone, the F1 scores are close (VLM 55.9%, YOLO-World 58.6%), although YOLO-World stays more precise (VLM 51.3%, YOLO-World 72.4%).

*Counting.* With its threshold tuned on the tuning queries (0.35), CountGD++ is less accurate than the VLM (exact counts: VLM 80.0%, CountGD++ 74.4%; MAE: VLM 0.41, CountGD++ 0.85), a difference in MAE of 0.44 [0.28, 0.61]. The default threshold of its authors, 0.23, does slightly worse (exact 73.8%, MAE 1.08). All VLM counting answers can be parsed. Most queries (65%) have a true count of zero, where CountGD++ is almost always right (VLM 90.3%, CountGD++ 99.0%), so the lead of the VLM comes from the other counts. From 1 to 3 objects, CountGD++ is exact for only 32.5% of the queries and the VLM for 71.1%, and CountGD++ mostly counts too few: on 749 of the 1,325 queries, and too many on only 146. The tuned threshold explains little of this: with the lower default threshold, CountGD++ is still exact for only 36.0% of these queries. From 4 objects up, both models are exact for fewer than 15% of the queries, as earlier counting studies report for VLMs @tamarapalli2025countqa @rong2026unicbench.

On the counts of 10 or more, the two models err in opposite directions: for 12.1 true objects on average, the VLM gives 5.5 and CountGD++ 24.4 (MAE: VLM 6.62, CountGD++ 17.8). These few dense images also explain the overall RMSE of CountGD++ (VLM 1.38, CountGD++ 5.79), with up to 218 books counted where COCO has 13. This comparison is uncertain, because COCO marks dense groups as crowd regions, which we exclude: 43 of the 84 queries with 10 or more objects have one, and the MAE of CountGD++ is 25.8 on them and 9.5 on the others. Part of its excess is probably objects that COCO does not annotate one by one.

#figure(
  placement: top,
  scope: "parent",
  [
    #align(center, legend(([VLM], [Specialist], [YOLO-World read as presence detector])))
    #v(2pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 8pt,
      cols-chart([Presence: F1 (%)], (
        ([rand.], 93.2, 79.3, 88.2),
        ([pop.], 88.4, 78.6, 83.6),
        ([adv.], 84.9, 73.9, 77.8),
      )),
      cols-chart([Localization at IoU 0.5 (%)], (
        ([P], 41.0, 66.7),
        ([R], 61.4, 49.2),
        ([F1], 49.2, 56.6),
        ([absent], 23.5, 6.3),
      )),
      cols-chart([Counting: exact match (%)], (
        ([all], 80.0, 74.4),
        ([0], 90.3, 99.0),
        ([1-3], 71.1, 32.5),
        ([4-9], 9.6, 14.4),
        ([10+], 7.1, 7.1),
      )),
    )
  ],
  caption: [VLM and specialists on the test images (values of @tab:results). Specialist: SigLIP 2 for presence, YOLO-World for localization, CountGD++ for counting. Presence: random, popular and adversarial POPE settings. Localization: precision (P), recall (R), F1, and share of absent classes that receive a box (lower is better). Counting: all queries, then by true count.],
) <fig:results>

#figure(
  {
    set text(size: 7.5pt)
    table(
      columns: (1fr, auto, auto, auto),
      inset: (x: 3pt, y: 2.2pt),
      stroke: none,
      align: (left, center, center, center),
      table.hline(stroke: 0.8pt),
      table.header[*Metric*][*VLM*][*Specialist*][*Detector*],
      table.hline(stroke: 0.4pt),
      table.cell(colspan: 4, fill: luma(238), align: left)[*Presence*: accuracy / F1 (%)],
      [random], [93.3 / 93.2], [81.9 / 79.3], [88.6 / 88.2],
      [popular], [87.9 / 88.4], [81.4 / 78.6], [83.6 / 83.6],
      [adversarial], [83.5 / 84.9], [76.3 / 73.9], [78.9 / 77.8],
      table.cell(colspan: 4, fill: luma(238), align: left)[*Localization* at IoU 0.5 (%)],
      [precision], [41.0], [66.7], [],
      [recall], [61.4], [49.2], [],
      [F1], [49.2], [56.6], [],
      [precision, positive queries], [51.3], [72.4], [],
      [F1, positive queries], [55.9], [58.6], [],
      [absent classes with a box], [23.5], [6.3], [],
      table.cell(colspan: 4, fill: luma(238), align: left)[*Counting*: exact match (%) / MAE],
      [all queries], [80.0 / 0.41], [74.4 / 0.85], [],
      [true count 0], [90.3 / 0.11], [99.0 / 0.03], [],
      [true count 1 to 3], [71.1 / 0.34], [32.5 / 1.15], [],
      [true count 4 to 9], [9.6 / 3.02], [14.4 / 4.13], [],
      [true count 10 or more], [7.1 / 6.62], [7.1 / 17.8], [],
      table.hline(stroke: 0.8pt),
    )
  },
  caption: [VLM (Qwen3.8-27B) and specialist on the test part of the POPE images. Specialist: SigLIP 2 for presence, YOLO-World for localization, and CountGD++ with its threshold tuned on the tuning part for counting. Detector: presence read from the best YOLO-World box. MAE is in counts, not in %. The recall on positive queries is the "recall" row.],
) <tab:results>

= Discussion <sec:discussion>
*Main findings.* In our setting, with small specialists and COCO images, neither model is more reliable on every task. The VLM is more accurate than SigLIP 2 for presence and, on average, than CountGD++ for counting, while YOLO-World has the better F1 for localization. The two types of model also fail in opposite ways. The VLM reports too much: it says "yes" more often as the questions become adversarial, it returns boxes for absent classes almost four times as often as YOLO-World, and it gives a non-zero count for 9.7% of the queries whose true count is zero, against 1.0% for CountGD++. The specialists mostly report too little: SigLIP 2 misses about a third of the present objects, YOLO-World finds only half of the true boxes, and CountGD++ counts too few objects for most small groups. In practice, these results point to the VLM for presence questions and small counts and to a detector when boxes are needed, with a check on absent classes in both cases.

*Link to earlier work.* The drop of the VLM from the random to the adversarial setting, with a stable recall and a falling precision, is consistent with the finding of POPE that objects which co-occur with the present ones are hallucinated more @li2023pope, and with the bias towards "yes" that AMBER reports @wang2023amber. These results are probably favorable to the VLM, because POPE is a comparatively easy presence test. Qwen3-VL-8B reaches 88.8% on the balanced POPE questions, as quoted by PVFH-Bench, but 58.1% on its questions about an absent look-alike object with a false premise @wang2026pvfh, a different measure that points the same way. For localization, the specialist leads by 7 F1 points at IoU 0.5, in the same direction as Ramachandran et al. and Roboflow100-VL, which find specialists ahead of VLMs @ramachandran2026gpt4o @robicheaux2025rf100vl. For counting, the drop of the VLM with the true count agrees with CountQA and UNICBench @tamarapalli2025countqa @rong2026unicbench. Its 90.3% of exact answers on zero counts lies between the 96.4% and 87.2% that HoloCount reports for Qwen3-VL-8B and Gemma3-27B on absent objects @deng2026holocount.

*Reliability beyond accuracy.* The VLM has one operating point, because it returns no confidence. We cannot trade its false boxes for missed objects, as we did for YOLO-World with a threshold chosen on the tuning images. The specialists give a score, but it needs tuning, and each specialist was tuned on our images, for presence even separately for each POPE setting, which a user could not do. A combination looks useful. Roboflow100-VL shows that adding SigLIP 2 scores to VLM boxes raises their mAP on a 20-dataset subset, from 7.4 to 9.7 for Qwen2.5-VL and from 5.7 to 8.3 for Gemini 2.5 Pro @robicheaux2025rf100vl @tschannen2025siglip2. The exact-match average for counting also hides the cases that matter, because two thirds of the queries are zero counts.
*Limits.* We tested one VLM, Qwen3.8-27B in its 4-bit version @qwen38card, in one run, and our intervals cover only the choice of images, not runs or prompts. Other VLMs and other quantizations may behave differently: Gemma3-27B and Qwen3-VL-8B differ clearly on PVFH-Bench and HoloCount. For the specialists, we used the smallest YOLO-World variant (S), and a larger one could widen its lead in localization and narrow the gap in presence. We also did not measure cost: the VLM weights alone take 18 GB, and YOLO-World-S has two to three orders of magnitude fewer parameters, and inference time and memory count when a model must run on many images or on small hardware. Despite this difference in size, the gaps between the VLM and YOLO-World are modest, about 7 F1 points at most for presence and for localization. We used a single prompt per task and did not measure its effect, although Ramachandran et al. report a large effect on detection.

All images are COCO photographs of common objects. They are likely to be in the pre-training data of the VLM and possibly of the specialists, which we cannot check. CountGD++ was trained on FSC-147, where the object is always present, and used here on absent classes and without the adaptive cropping of its paper, which may be unfavorable on COCO; tuning its threshold on COCO already lowered its MAE from 1.08 to 0.85. This threshold favors empty answers, since two thirds of the tuning queries have a true count of zero, but it explains little of the undercounting of small groups. The missing exemplars, adaptive cropping, and resizing to 800 pixels are more likely causes, which we did not test.

The labels of POPE and COCO also contain errors @neuhaus2025repope @penquitt2026incomplete. They matter more for the positive queries (9.3% of the "yes" questions of POPE have a wrong label and 13.8% are ambiguous) than for the negative ones, so the recall and the counts of all models are measured against noisy targets. For the negative queries, RePOPE finds a wrong label for 1.7% of the "no" questions and 4.3% more that are ambiguous, so few of the absent classes that receive a VLM box are likely to be real objects. A re-annotation of COCO validation still finds 40% more objects, mostly small or occluded, and we did not check our boxes by hand.

We did not run a control with a blank image, so a correct presence answer does not prove that the image was used @lan2026seeing. Finally, we measured neither calibration nor robustness to the prompt or the domain, which are two of the three properties of reliability defined in @sec:background.

= Conclusion <sec:conclusion>
On common objects in COCO photographs, one recent VLM, Qwen3.8-27B, was more accurate than the specialists for object presence, including YOLO-World read as a presence detector, and, over all counting queries, for counting. YOLO-World was ahead for localization by 7 F1 points at IoU 0.5. We cannot conclude that the VLM could replace a specialist for presence: POPE is an easy test, our specialists are small models, and the images are probably in the pre-training data of the VLM. The counting lead also comes from small counts, where CountGD++, used without exemplars and outside the setting it was trained for, counts too few. Nor do the results show that the VLM is reliable in the broader sense that we defined, since we measured accuracy and behavior on absent objects but not calibration or robustness. The VLM also reports objects that are not there, is rarely exact for counts of four or more, and gives no confidence, whereas the specialists miss more objects and need tuned thresholds. The review shows that this comparison is rarely made: no study compares a VLM with a specialist for presence, and we found no independent evaluation of the recent Qwen and Gemma models for localization.

Several steps would make these results firmer. We would test more VLMs and quantizations, such as Gemma 4. We would measure the effect of the prompt, add a control with a blank image, and use harder presence questions such as those of PVFH-Bench. We would count dense scenes on a set with complete annotations, and evaluate localization at a stricter IoU. We would also run out-of-domain images, for example from Roboflow100-VL and FSC-147. Finally, giving the VLM a confidence, for example from SigLIP 2 scores or from the token probabilities that Ollama can return, would let us measure the third property of reliability, calibration.

#heading(numbering: none)[Statement on the Use of AI]
Both authors used Claude (Anthropic) in preparing this paper. One author used it through Claude Code with the Academic Research Skills plugin (version 3.24.3) and the alphaXiv tool, in October and November 2026, to search and summarize the literature, to draft and revise the text of the Review, Methods and Results sections, to write all the experiment code and the Typst formatting, to compute derived figures from the result files, and to check the bibliography against arXiv. The authors then reviewed the text produced with AI and take full responsibility for the content of the paper.
