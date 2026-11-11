# Références à contrôler — partiellement validées (voir la section Validation 2026-11-09)

Mise à jour 2026-10-23 : titres, auteurs, années et identifiants arXiv des 40 références ont été comparés à l'API arXiv, et `paper/refs.yml` est généré à partir de ces métadonnées. Les colonnes AUTEUR de ce tableau sont donc réglées ; il reste LIEU (pour 12 preprints) et CHIFFRE (lecture du texte intégral). Voir aussi `sources.md`, `search-log.md` et `source-critique.md`.

## Validation 2026-11-09

**Métadonnées : validées.** Titre, auteurs (nombre et ordre) et année comparés à l'API arXiv pour 43 des 44 entrées de `paper/refs.yml` : aucun écart. Les années de `refs.yml` suivent la conférence, pas le preprint (HallusionBench, Sclar, MMBench, Molmo, Ramachandran, CountGD++), ce qui est voulu. Qwen3-VL a un auteur collectif (« Qwen Team »). La 44e entrée, Qwen3.5-9B, est une fiche Hugging Face (HTTP 200 le 2026-11-09, pas d'article).

**Lieux confirmés** (commentaire arXiv ou Semantic Scholar) : POPE (EMNLP 2023), HallusionBench (CVPR 2024), CountBench (ICCV 2023), BLINK (ECCV 2024), Zhang (NeurIPS 2024), Sclar (ICLR 2024), MMBench (ECCV 2024), PARC (CVPR 2025), Promptception (EMNLP 2025), Ding (Findings EMNLP 2025), Groot (TrustNLP 2024), YOLO-World (CVPR 2024), OWLv2 (NeurIPS 2023), RF100-VL (NeurIPS 2025), Ramachandran (ICLR 2026), DetToolChain (ECCV 2024), OmniLabel (ICCV 2023), CountGD (NeurIPS 2024), CountGD++ (CVPR 2026), UNICBench (CVPR 2026), Molmo (CVPR 2025), Sapkota (Information Fusion 2025), CLIP-Count (ACM MM 2023). Ajoutés à `refs.yml` le 2026-11-09 : Grounding DINO (ECCV 2024), Kosmos-2 (ICLR 2024), LLMDet (CVPR 2025), LVLM-Count (TMLR), MERLIM (CVPRW 2025), Fuzesséry (SAMI 2025).

**Lieux non confirmés, à laisser en preprint ou en atelier tel quel** : Rex-Omni et GroundingME (Semantic Scholar donne « CVPR 2025 », impossible pour des preprints d'octobre et décembre 2025 : ignoré), BlindTest (ACCV 2024 dans `refs.yml`, aucune source interrogée ne le confirme), Levine (atelier ICLR 2023), Lan (atelier CVPR 2026 d'après le commentaire arXiv), AMBER, les deux surveys (Bai, Liu), CountQA, Owusu, VLM-RobustBench, SigLIP 2, Qwen2.5-VL, Qwen3-VL.

**Chiffres relus dans le texte** (PDF lus via alphaXiv, pages les plus pertinentes seulement) :
- HallusionBench : 31,42 % de précision par paire pour GPT-4V (évaluation humaine ; 28,79 avec le juge GPT-4).
- BLINK : GPT-4V 51,26 %, humains 95,70 %.
- BlindTest : 58,07 % en moyenne, Sonnet-3.5 à 77,84 %.
- Promptception : jusqu'à 15 % d'écart, 61 prompts, 10 modèles.
- CountBench : 540 images, 2 à 10 instances.
- MERLIM : 300 664 paires image-question.
- UNICBench : 21 modèles sur la piste image (45 modèles au total sur les trois modalités) ; corrigé.
- DetToolChain : 65,8 AP50 sur les classes nouvelles de COCO contre 43,1 pour CORA, soit +22,7 ; le résumé dit +21,5 ; corrigé.
- Ramachandran : GPT-4o 60,62 AP50 contre 91,30 pour Co-DETR ; prompting direct 17,69.
- CountGD++ : MAE 8,39 sur FSC-147 en texte seul, contre 43,18 pour Gemini-2.5 et 40,41 pour Molmo.
- Zhang : GPT-4 60,6 % contre 79,2 % pour EVA-G sur ImageNet ; corrélation de Spearman 0,76.
- VLM-RobustBench : 49 types de corruption, 133 configurations, baisse maximale de 34 points.
- Lan : environ 3 points de perte sur POPE avec 75 % des tokens retirés.

**Chiffres jamais relus dans le texte intégral** (ne pas les citer sans relecture) : Sclar (76 points), CountQA (42,9 %), Fuzesséry, PARC, Levine, Groot, Grounding DINO (52,5 AP), YOLO-World (35,4 AP), OWLv2 (44,6 %), Rex-Omni, RF100-VL (moins de 2 %), Qwen3-VL (48,6 mAP), GroundingME (45,1 %), OmniLabel, CountGD, LVLM-Count, SigLIP 2, MMBench, Bai et les 7 sources remises pour le Background.

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
| 36 | Wu et al., 2024, ECCV, arXiv:2403.12488 (DetToolChain) | 65,8 AP50 sur COCO classes nouvelles contre 43,1 pour CORA (+22,7 selon le tableau ; le résumé dit +21,5) | LIEU (ECCV vu sur page de conférence seulement) |
| 37 | Jiang et al., 2023, arXiv:2305.07304 (CLIP-Count) | comptage guidé par texte, FSC-147/CARPK/ShanghaiTech | AUTEUR, LIEU |
| 38 | Qwen Team, 2025, arXiv:2511.21631 (Qwen3-VL) | tailles 2B/4B/8B/32B + 2 MoE ; 48,6 mAP ODinW-13 pour le plus gros | CHIFFRE |
| 39 | Li et al., 2025, arXiv:2512.17495 (GroundingMe) | 25 modèles, 1 005 exemples ; meilleur 45,1 %, la plupart 0 % sur le rejet | CHIFFRE, LIEU |
| 40 | Schulter et al., 2023, ICCV (oral), arXiv:2304.11463 (OmniLabel) | descriptions libres avec négatives, plus de 25 000 images | CHIFFRE |

Notes
- MME (arXiv:2306.13394) a été retiré pour tenir dans les 40 sources.
- Qwen3.5-9B n'est PAS dans cette liste : pas d'article vérifié, à citer comme ressource en ligne (fiche Hugging Face ou blog Qwen) en vérifiant l'URL et la date d'accès.
- Ne citer aucun chiffre dans le papier sans l'avoir relu dans le corps de l'article.


## Mise à jour 2026-10-26 (restructuration par tâche)

- 10 sources retirées (voir `sources.md`) : lignes [5], [6], [16], [18], [25], [29], [30], [33], [34], [37] ci-dessus, à ignorer.
- 9 sources ajoutées, métadonnées comparées à l'API arXiv (titres, auteurs, années) :

| # | Réf. | Affirmation utilisée | Point à vérifier |
|---|---|---|---|
| 41 | Amini-Naieni et al., 2024, NeurIPS, arXiv:2407.04619 (CountGD) | spécialiste du comptage, basé sur Grounding DINO, texte ou exemples | CHIFFRE (aucun lu), entraînement sur FSC-147 |
| 42 | Amini-Naieni et Zisserman, 2026, CVPR, arXiv:2512.23351 (CountGD++) | comparaison avec des MLLMs sur FSC-147 | CHIFFRE ; comparaison non lue |
| 43 | Qharabagh et al., 2024, arXiv:2412.00686 (LVLM-Count) | les LVLMs se dégradent quand le nombre d'objets augmente | LIEU (preprint v4) |
| 44 | Rong et al., 2026, CVPR, arXiv:2603.00595 (UNICBench) | 5 300 images, 21 MLLMs sur la piste image (45 sur image, texte et audio) | CHIFFRE |
| 45 | Owusu et Sheshappanavar, 2026, arXiv:2608.23845 | survey du comptage ; benchmarks saturés | LIEU (aucun) |
| 46 | Tschannen et al., 2025, arXiv:2502.14786 (SigLIP 2) | spécialiste de présence (similarité image-texte) | seuil de décision à régler sur un jeu de réglage |
| 47 | Villa et al., 2023, arXiv:2312.02219 (MERLIM) | benchmark d'hallucination inter-modale | liste exacte des tâches |
| 48 | Saxena et al., 2026, arXiv:2603.06148 (VLM-RobustBench) | perturbations spatiales de faible sévérité nuisibles | CHIFFRE |
| 49 | Lan et al., 2026, CVPR Workshop GRAIL-V, arXiv:2605.22903 | scores d'un benchmark d'hallucination peu sensibles à la perte de tokens d'image | benchmark non identifié dans le résumé |

Total : 39 sources (plafond 40).

## Relecture 2026-11-11 (alphaXiv, texte intégral)

- **Rex-Omni (2510.12798)** : COCO zéro-shot, F1@IoU0,5 = 72,0 (Rex-Omni) contre 69,8 (Grounding DINO-Swin-T) et 64,0 (Qwen2.5-VL-7B) ; F1@IoU0,95 = 15,9 contre 23,0 et 12,6 ; F1@mIoU 52,9 contre 56,6. Les détecteurs sont évalués à leur meilleur seuil de F1 (AP écarté parce que les MLLM n'ont pas de score fiable). Dense200 : Qwen2.5-VL-7B 1,1 contre 36,9 pour Grounding DINO. Auteurs communs avec Grounding DINO : confirmé (Zeng, Ren).
- **RF100-VL (2505.20612, NeurIPS 2025 D&B)** : mAP zéro-shot, 100 jeux : Grounding DINO 15,7 ; Qwen2.5-VL 72B 5,6 ; Gemini 2.5 Pro 11,6. Médical : 2,1 ; 1,6 ; 5,3. Le résumé dit « moins de 2 % » : le tableau donne 2,1 pour Grounding DINO. Citer le tableau. Sur ODinW-13, Grounding DINO 49,2 contre 15,7 sur RF100-VL.
- **Fuzesséry (2512.03233)** : FSC-147 test, MAE : GPT-4o 20,73 / 22,1 ; GPT-5 20,96 / 21,59 (prompts 1 / 2) ; CountTX 15,69, RichCount 16,37, VLCounter 17,05, CLIP-count 17,78, VA-Count 17,88, ZSC 22,09. CARPK : GPT-4o 31,08 / 38,57 ; GPT-5 30,13 / 40,41 ; RCC 8,13, CLIP-count 11,96. Échecs : 2 560 Lego prédits à 1.
- **HoloCount (2607.06420, Meituan, arXiv juillet 2026, ajouté 2026-11-11)** : 2 480 questions, 20 modèles. Exact match moyen : Qwen3.5-9B 71,4 ; Qwen3-VL-8B 58,1 ; Gemma3-27B 48,4. Dense : Qwen3.5-27B 20,0 ; Gemma3-27B 0,0. Cible absente : Qwen3-VL-8B 96,4 ; Gemma3-27B 87,2. Pas de spécialiste. Preprint, pas de venue.
- **WADE (2608.22950)** : Qwen3-VL-2B et d'autres petits VLM, pas de détecteur spécialisé (limite que les auteurs citent). Non retenu.
- **PVFH-Bench (2610.14635, arXiv 10 oct. 2026)** : 258 images COCO val 2014, 1 032 questions, 10 LVLM. Qwen3-VL-8B : 98,45 / 80,62 / 81,40 / 58,14 (vanilla / objet confondable / fausse prémisse / cœur) ; Gemma-3-27B : 98,84 / 67,05 / 60,08 / 28,29 ; Gemma-3-12B cœur 18,99 ; Gemma-3-4B cœur 1,94. Juge LLM : Qwen3.5-Flash (même famille que des modèles évalués ; re-notation GPT-5.4-mini, écarts ≤ 4,55 points). Accord humain-juge 95,5 % sur 200 réponses. Preprint, pas de spécialiste.
- **Chhipa et al. (2405.14874)** : détecteurs seuls, aucun VLM. COCO-O, mAP 0,5:0,95 moyenne : OWL-ViT 15,97, YOLO-World 23,42, Grounding DINO 41,52 (COCO propre : 26,40 ; 39,30 ; 48,40, valeur Grounding DINO reprise de son article). COCO-DC original : YOLO-World 49,8, OWL-ViT 42,5, Grounding DINO 40,4 ; adversarial : 24,6 ; 22,8 ; 34,7. Venue non identifiée dans le texte lu.
