# Références à contrôler (40) — NON validées

Mise à jour 2026-10-23 : titres, auteurs, années et identifiants arXiv des 40 références ont été comparés à l'API arXiv, et `paper/refs.yml` est généré à partir de ces métadonnées. Les colonnes AUTEUR de ce tableau sont donc réglées ; il reste LIEU (pour 12 preprints) et CHIFFRE (lecture du texte intégral). Voir aussi `sources.md`, `search-log.md` et `source-critique.md`.

Statut global : trouvées par recherche web, lues au niveau page arXiv / résumé. Aucun PDF lu en entier.
Pour chaque entrée : vérifier (1) l'identifiant arXiv/DOI, (2) le titre exact, (3) la liste complète des auteurs, (4) le lieu et l'année de publication, (5) que l'affirmation citée figure bien dans le texte intégral.

Légende « Point à vérifier » :
- AUTEUR = prénom ou liste d'auteurs non confirmés par la source lue (venait de ma mémoire ou d'une URL)
- LIEU = conférence/revue non confirmée sur la page officielle
- CHIFFRE = valeur tirée du résumé, à relire dans le corps de l'article

| # | Réf. (premier auteur, année, id) | Affirmation utilisée dans le papier | Point à vérifier |
|---|---|---|---|
| 1 | Li et al., 2023, EMNLP, arXiv:2305.10355 (POPE) | questions oui/non sur la présence d'objets ; objets fréquents ou co-occurrents hallucinés | LIEU |
| 2 | Wang et al., 2023, arXiv:2311.07397 (AMBER) | benchmark sans juge LLM : existence, attributs, relations | AUTEUR |
| 3 | Guan et al., 2024, CVPR, arXiv:2310.14566 (HallusionBench) | 31,42 % de précision par paire pour GPT-4V | AUTEUR, CHIFFRE |
| 4 | Bai et al., 2024, arXiv:2404.18930 | survey hallucination MLLM | LIEU (preprint ?) |
| 5 | Liu et al., 2024, arXiv:2402.00253 | survey hallucination LVLM | LIEU (preprint ?) |
| 6 | Leng et al., 2024, CVPR, arXiv:2311.16922 (VCD) | atténuation sans réentraînement par décodage contrastif | — |
| 7 | Paiss et al., 2023, ICCV, arXiv:2302.12066 (CountBench) | CLIP code mal les nombres, 2 à 10 instances | — |
| 8 | Tamarapalli et al., 2025, arXiv:2508.06585 (CountQA) | 15 MLLMs, meilleur modèle 42,9 %, baisse avec le nombre d'objets | CHIFFRE, LIEU |
| 9 | Füzesséry et al., 2025, arXiv:2512.03233 | GPT-4o/GPT-5 comparables au zéro-shot sur FSC-147, faibles sur CARPK | CHIFFRE (aucun MAE lu) |
| 10 | Rahmanzadehgervi et al., 2024, ACCV, arXiv:2407.06581 (BlindTest) | 58,07 % en moyenne pour 4 VLMs ; sondage linéaire | CHIFFRE |
| 11 | Tong et al., 2024, CVPR, arXiv:2401.06209 (MMVP) | paires CLIP-aveugles | — |
| 12 | Fu et al., 2024, ECCV, arXiv:2404.12390 (BLINK) | GPT-4V 51,26 % contre 95,70 % humains | AUTEUR, CHIFFRE |
| 13 | Kamath et al., 2023, EMNLP, arXiv:2310.19785 (What'sUp) | relations spatiales, 56 % contre 99 % humains | CHIFFRE |
| 14 | Wu & Xie, 2024, CVPR, arXiv:2312.14135 (V*) | petits objets, haute résolution | — |
| 15 | Zhang et al., 2024, NeurIPS, arXiv:2405.18415 | VLMs sous CLIP sur ImageNet ; lien avec fréquence des classes | — |
| 16 | Deitke et al., 2025, CVPR, arXiv:2409.17146 (Molmo/PixMo) | données de pointage 2D | AUTEUR |
| 17 | Sclar et al., 2024, ICLR, arXiv:2310.11324 | jusqu'à 76 points d'écart selon le formatage (LLM) | CHIFFRE |
| 18 | Zheng et al., 2024, ICLR, arXiv:2309.03882 | biais de sélection sur l'ID de l'option | AUTEUR |
| 19 | Liu et al., 2024, ECCV, arXiv:2307.06281 (MMBench) | CircularEval | AUTEUR |
| 20 | Schmalfuss et al., 2025, CVPR, arXiv:2506.14808 (PARC) | 22 VLMs, InternVL2 le plus robuste | AUTEUR (liste), CHIFFRE |
| 21 | Ismithdeen et al., 2025, EMNLP, arXiv:2509.03986 (Promptception) | jusqu'à 15 % d'écart, 61 types de prompts | LIEU, CHIFFRE |
| 22 | Levine et al., 2023, ICLR Workshop, arXiv:2303.12748 | CLIP zéro-shot mal calibré ; une température apprise se généralise | LIEU (atelier) |
| 23 | Groot & Valdenegro-Toro, 2024, TrustNLP, arXiv:2405.02917 | LLMs et VLMs surconfiants en confiance verbalisée | — |
| 24 | Ding et al., 2025, Findings EMNLP, arXiv:2508.19111 | probabilité et cohérence plus fiables que la confiance verbalisée | — |
| 25 | Ye & Wen, 2025, ICIPCA, arXiv:2504.17671 | prédiction conforme pour le VQA | LIEU (venue peu connue) |
| 26 | Liu et al., 2023, arXiv:2303.05499 (Grounding DINO) | 52,5 AP zéro-shot COCO (meilleure variante) | LIEU (ECCV 2024 ?), CHIFFRE |
| 27 | Cheng et al., 2024, CVPR, arXiv:2401.17270 (YOLO-World) | 35,4 AP LVIS, 52 FPS | CHIFFRE |
| 28 | Minderer et al., 2023, NeurIPS, arXiv:2306.09683 (OWLv2) | 44,6 % AP classes rares LVIS | CHIFFRE |
| 29 | Peng et al., 2023, arXiv:2306.14824 (Kosmos-2) | grounding natif via jetons de position | LIEU (ICLR 2024 ?) |
| 30 | Bai et al., 2025, arXiv:2502.13923 (Qwen2.5-VL) | sortie de boîtes ; coordonnées absolues non confirmées | AUTEUR, détail coordonnées |
| 31 | Jiang et al., 2025, arXiv:2510.12798 (Rex-Omni) | 3B, comparable à Grounding DINO en zéro-shot COCO/LVIS ; faible rappel des MLLMs généralistes | LIEU (CVPR 2026 ?), CHIFFRE |
| 32 | Robicheaux et al., 2025, NeurIPS D&B, arXiv:2505.20612 (RF100-VL) | moins de 2 % zéro-shot en imagerie médicale | CHIFFRE |
| 33 | Sapkota & Karkee, 2025, Information Fusion, arXiv:2508.19294 | projection : les LVLMs rattraperont les détecteurs | LIEU |
| 34 | Fu et al., 2025, arXiv:2501.18954 (LLMDet) | co-entraînement avec un LLM améliore Grounding DINO | AUTEUR (prénom) |
| 35 | Ramachandran et al., 2026, ICLR, arXiv:2507.01955 | MFMs loin des spécialistes sur toutes les tâches ; meilleurs modèles moins sensibles au prompt | CHIFFRE, relire dans le texte |
| 36 | Wu et al., 2024, ECCV, arXiv:2403.12488 (DetToolChain) | +21,5 % AP50 sur COCO classes nouvelles | LIEU (ECCV vu sur page de conférence seulement) |
| 37 | Jiang et al., 2023, arXiv:2305.07304 (CLIP-Count) | comptage guidé par texte, FSC-147/CARPK/ShanghaiTech | AUTEUR, LIEU |
| 38 | Qwen Team, 2025, arXiv:2511.21631 (Qwen3-VL) | tailles 2B/4B/8B/32B + 2 MoE ; 48,6 mAP ODinW-13 pour le plus gros | CHIFFRE |
| 39 | Li et al., 2025, arXiv:2512.17495 (GroundingMe) | 25 modèles, 1 005 exemples ; meilleur 45,1 %, la plupart 0 % sur le rejet | CHIFFRE, LIEU |
| 40 | Schulter et al., 2023, ICCV (oral), arXiv:2304.11463 (OmniLabel) | descriptions libres avec négatives, plus de 25 000 images | CHIFFRE |

Notes
- MME (arXiv:2306.13394) a été retiré pour tenir dans les 40 sources.
- Qwen3.5-9B n'est PAS dans cette liste : pas d'article vérifié, à citer comme ressource en ligne (fiche Hugging Face ou blog Qwen) en vérifiant l'URL et la date d'accès.
- Ne citer aucun chiffre dans le papier sans l'avoir relu dans le corps de l'article.
