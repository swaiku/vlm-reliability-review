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
#todo[Define the models and concepts needed for the comparison.]

== Vision-Language Models
#todo[Explain how general VLMs answer visual questions.]

== Open-Vocabulary Object Detection
#todo[Introduce specialized detectors and their box outputs.]

== Evaluation of Visual Information Extraction
#todo[Define the extraction tasks and evaluation measures.]

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
