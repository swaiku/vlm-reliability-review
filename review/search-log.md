# Search log

How the literature was searched. All searches were run on 2026-10-23 with a general web search tool driven by an AI assistant (Claude), plus direct fetches of arXiv, Hugging Face and conference pages. No bibliographic database (Scopus, IEEE Xplore, Google Scholar, Semantic Scholar, DBLP) was queried.

## What was actually done

1. **Discovery queries (6).** Six broad queries, one per theme (hallucination, counting, open-vocabulary detectors versus VLMs, calibration, prompt sensitivity, video hallucination).
2. **Seed lookups (about 40).** The assistant proposed well-known papers from its own prior knowledge of the field and looked each one up by title or arXiv id to confirm that it exists and to read its abstract. Most of the 40 sources come from this step, not from the discovery queries.
3. **Gap-filling queries (about 8).** Targeted queries when a theme had no direct evidence: counting in the wild, VLM versus specialist detectors, newer Qwen releases, benchmark datasets.
4. **Metadata check.** Titles, authors, years and arXiv ids of all 40 sources were compared against the arXiv API (2026-10-23). Venues come from the arXiv comment field or from conference pages.
5. **Scope change.** After the scope was narrowed to still photos (no video), five video sources were dropped.

Consequence: this is a narrative review seeded from known works. It is not a systematic search and it cannot be reproduced from the queries alone.

## Queries

Counts are the approximate number of links the search tool returned (about 10 per query); exact numbers were not recorded.

| Date | Source | Query or lookup | Filters | Results | Kept |
|---|---|---|---|---|---|
| 2026-10-23 | Web search | POPE Evaluating Object Hallucination in Large Vision-Language Models arXiv | none | ~10 | [1] |
| 2026-10-23 | Web search | vision-language models counting benchmark failure CountBench VLMs can't count | none | ~10 | [7] |
| 2026-10-23 | Web search | YOLO-World Grounding DINO versus multimodal LLM object detection benchmark comparison | none | ~10 | [32], [33] |
| 2026-10-23 | Web search | calibration vision-language models confidence uncertainty VQA overconfidence LVLM | none | ~10 | [24], [25] |
| 2026-10-23 | Web search | prompt sensitivity vision-language models benchmark robustness prompt variations multiple-choice | none | ~10 | [20], [21] |
| 2026-10-23 | Web search | video LLM hallucination benchmark VidHalluc EventHallusion temporal counting video understanding | none | ~10 | none (video excluded) |
| 2026-10-23 | Web search | title or arXiv-id lookups: Vision language models are blind; Grounding DINO; YOLO-World; OWLv2; HallusionBench; AMBER; Bai hallucination survey; Molmo and PixMo | none | ~10 each | [10], [26], [27], [28], [3], [2], [4], [16] |
| 2026-10-23 | arXiv page fetch | Roboflow100-VL (2505.20612); Sapkota review (2508.19294) | none | 2 pages | [32], [33] |
| 2026-10-23 | Web search | Why are Visually-Grounded Language Models Bad at Image Classification | none | ~10 | [15] |
| 2026-10-23 | Web search | multimodal LLM counting benchmark 2025 object counting accuracy degrades with count GPT-4o Qwen2-VL real-world images | none | ~10 | [8], [9] |
| 2026-10-23 | Web search | Video-MME; VideoHallucer; EventHallusion (lookups) | none | ~10 each | none (video excluded) |
| 2026-10-23 | Web search | Overconfidence is Key: verbalized uncertainty evaluation in LLMs and VLMs; MMBench | none | ~10 each | [23], [19] |
| 2026-10-23 | Web search | lookups: Qwen2.5-VL; Rex-Omni ("Detect Anything via Next Point Prediction"); Kosmos-2; What's "Up" with VLMs; GPT-4o and GPT-5 object counting; VCD; Liu hallucination survey | none | ~10 each | [30], [31], [29], [13], [9], [6], [5] |
| 2026-10-23 | Web search | lookups: MMVP (Eyes Wide Shut); CLIP zero-shot calibration; Sclar prompt formatting; V*; BLINK; Zheng selection bias; PARC | none | ~10 each | [11], [22], [17], [14], [12], [18], [20] |
| 2026-10-23 | Web search | Florence-2 OR LLMDet OR MM-Grounding-DINO open-vocabulary detection large language model 2024 | none | ~10 | [34] |
| 2026-10-23 | Web search | zero-shot object counting text-guided CounTX CLIP-Count FSC-147 class-agnostic counting vs multimodal LLM | none | ~10 | [37] |
| 2026-10-23 | Web search | MME comprehensive evaluation benchmark multimodal large language models | none | ~10 | none (dropped for the 40-source cap) |
| 2026-10-23 | Web search | evaluating multimodal LLMs object detection COCO mAP GPT-4V Gemini compared to specialist detector zero-shot benchmark | none | ~10 | [35], [36] |
| 2026-10-23 | Web search | Rohrbach CHAIR object hallucination image captioning; Woodpecker | none | ~10 | none (CHAIR is from 2018; mitigation papers) |
| 2026-10-23 | Web search (extended) | Qwen3-VL technical report grounding detection model sizes release | none | ~10 | [38], [39] (GroundingME surfaced in these results) |
| 2026-10-23 | Web search (extended) | latest Qwen vision-language model 2026 release Qwen3.5 OR Qwen4 VL Hugging Face | none | ~10 | Qwen3.5 model card (online resource, not counted) |
| 2026-10-23 | Web search | YOLO-World pre-training data; Grounding DINO pre-training datasets and leakage | none | ~10 each | none (used for the Methods caveats) |
| 2026-10-23 | Web search | benchmark datasets for open-vocabulary detection and MLLM grounding (ODinW, LVIS, RefCOCO, OmniLabel, D3, HumanRef, counting boxes) | none | ~10 | [40] |
| 2026-10-23 | Page fetch | arXiv abs pages of [8], [9], [21], [24], [25], [31], [35], [36], [39], [40] | none | 10 pages | metadata and abstract read |
| 2026-10-23 | Page fetch | Hugging Face cards Qwen3.5-9B, Qwen3-VL-8B-Instruct, Qwen3.8-27B; GitHub QwenLM/Qwen3.8 | none | 4 pages | model facts for the experiment |
| 2026-10-23 | Web search | Roboflow100-VL dataset access; ODinW-13 download and licenses | none | ~10 each | dataset choice (no new source) |
| 2026-10-23 | arXiv API | id_list of the 40 sources | none | 40 of 40 found | titles, authors, years, venue comments checked |

## Screening

One reader (the assistant) screened by title and abstract, then confirmed that each paper exists. No second reader, no independent screening of a sample, no per-record decision log.

## Inclusion / exclusion criteria

- Include: work from 2023 to 2026 on VLMs, multimodal LLMs or open-vocabulary detectors, that measures or explains reliability for one of: object hallucination, counting, low-level perception or classification, prompt sensitivity, calibration, localization or detection. Static images only. Peer-reviewed venue or arXiv preprint. English. At least the abstract accessible.
- Include, exceptionally: two text-only LLM studies on prompt formatting ([17], [18]) as the precedent for prompt sensitivity; three model or method papers ([16], [29], [30]) as background.
- Exclude: video-only work (VidHalluc, EventHallusion, VideoHallucer, Video-MME, a 2026 video-hallucination survey); work before 2023 (CHAIR, 2018); hallucination mitigation methods beyond one illustrative example ([6]); medical-imaging-specific work; blog posts and vendor pages.
- Excluded for space (40-source cap): MME, MM-Grounding-DINO, OmniCount, D3, HumanRef, Woodpecker, OPERA.
- Not a source: Qwen3.8 (model card only, no paper, not run in the main comparison).

## Known limits of the search

- Seeded by one assistant's memory of the field: popular and early-cited papers are favored, recent or obscure ones are under-represented.
- One search tool, no database, no citation chasing from the surveys [4] and [5].
- No recorded record counts, so a PRISMA-style flow cannot be reconstructed.
- Claims were read from abstracts and pages, not full texts.

## Suggested complementary steps (about half a day)

- Run fixed queries on arXiv and Semantic Scholar per theme (hallucination, counting, prompt sensitivity, calibration, open-vocabulary detection versus MLLM) and log the counts.
- Snowball from [4], [5] and [35]: references and papers that cite them since 2025.
- Add at least one source on calibration of object detectors (none in the corpus).
- Have the second author screen a sample of 20 records and compare decisions.
