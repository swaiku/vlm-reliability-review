# Review académique simulée — origin/jeremy @ 969253a (2026-11-15)

Mode : full (panel simulé en un seul passage : Journal-Fit, Méthodologie, Domaine, Perspective, Devil's Advocate).
Pas de sous-agents ni de compilation Typst (typst absent de cette machine). Les chiffres du papier ont été recoupés avec `experiments/results/*.json` et le tableau ; les références 2026 n'ont pas été revérifiées en ligne.

## Décision éditoriale : **Major revision** (venue type atelier / conférence applicative)

Papier clair, honnête sur ses limites, bien instrumenté (cache, bootstrap, split tune/test). Mais le titre et la question promettent « fiabilité » alors que seule l'exactitude (et le comportement sur absents) est mesurée, et plusieurs conclusions reposent sur des choix de protocole qui favorisent un camp ou ne sont pas contrôlés.

## Points forts (consensus)
- Intervalles bootstrap par image, seuils réglés sur un split tune, sorties en cache : reproductible sans GPU.
- Limites explicitement écrites ; déclaration d'usage de l'IA ; écarts entre sources signalés (cross-study non comparable).
- Séparation positives/négatives en localisation et comptage par taille : l'analyse la plus utile du papier.

## Problèmes critiques / majeurs

**C1. Faux positifs possiblement faux : annotations COCO/POPE incomplètes** (Méthodo, DA — CRITICAL)
Les « classes absentes » sont définies par l'absence dans les annotations COCO. COCO n'est pas exhaustif et POPE a du bruit d'étiquettes connu. Les 23,5 % de négatifs avec boîte du VLM et sa précision de 41 % peuvent en partie être de vrais objets. Le résultat de localisation (VLM F1 49,2 contre 56,6) repose à 65 % sur ces négatifs ; sur les positifs seuls l'écart est de 2,7 points, sans IC. → Auditer à la main un échantillon (ex. 100 « faux positifs » du VLM) et reporter la part réelle ; donner l'IC du F1 positifs.

**C2. Titre / RQ / conclusion plus larges que les preuves** (Journal-Fit, DA)
- La fiabilité est définie par trois propriétés (exactitude, stabilité, calibration) ; deux ne sont pas mesurées (prompt, calibration), et le domaine est unique (COCO).
- Un seul VLM (Qwen3.8-27B, 4 bits, Ollama), un prompt, un run. « VLMs » au pluriel dans titre/abstract.
- « Le VLM pourrait remplacer le spécialiste pour la présence » (Conclusion) dépasse les données : POPE est facile (vous le dites), le baseline SigLIP 2 est faible (seuil ≈ 4e-6 : usage probablement hors de son régime, pas un détecteur), YOLO-World est la petite variante `yolov8s` face à 27 Mds de paramètres.
→ Reformuler le titre/RQ (« A case study… on COCO ») ou mesurer au moins 2 des 3 propriétés. TODO 6-8 de `review/TODO.md` sont exactement ce qui manque ; la robustesse au prompt (4 formulations POPE) est la moins chère.

**M1. Comparaison pas à armes égales** (Méthodo)
Spécialistes : seuil réglé sur tune ; VLM : un seul point de fonctionnement, prompt non réglé. CountGD++ sans exemplaires ni cropping adaptatif (donc dégradé par rapport à son papier) ; SigLIP 2 avec un prompt unique « a photo of a {class} ». Lire ces écarts comme « VLM > spécialiste » est fragile. → Au minimum, rapporter une variante plus forte de chaque spécialiste (YOLO-World-L/X, SigLIP 2 avec ensemble de templates, CountGD++ avec cropping) ou reformuler en « baselines simples ».

**M2. Contamination non contrôlée** (Domaine)
COCO val est très probablement dans les données de pré-entraînement de Qwen ; mentionné comme limite mais jamais testé. Les conclusions « VLM meilleur en présence » sont donc des bornes hautes. → Ajouter un jeu non-COCO (même 100 images) ou un contrôle image vide (TODO 8).

**M3. Statistiques** (Méthodo)
- IC bootstrap sur 400 images, mais les seuils sont réglés sur 100 autres : la variance du réglage n'est pas dans l'IC.
- Les écarts par tranche de comptage (surtout 10+, n=84) n'ont pas d'IC ; « 4-9 : CountGD++ meilleur en exact » n'est pas testé.
- Le MAE global (0,41 vs 0,85) est dominé par 65 % de comptes nuls ; le titre « le VLM compte mieux » dans l'abstract est trompeur. L'abstract devrait rapporter les tranches ≥ 1.
- Pas de test apparié (McNemar / bootstrap apparié) pour l'exact-match.

**M4. Revue narrative assistée par IA, affirmations négatives fortes** (Domaine)
« Nous n'avons trouvé aucune étude… » apparaît dans l'abstract, la Synthèse et la Conclusion. Or la recherche est non systématique, plusieurs articles ne sont lus qu'au niveau résumé, et `refs_to_verify.md` liste les chiffres jamais relus (CountQA, Fuzesséry, RF100-VL, GroundingME, Rex-Omni…). Le papier cite ces chiffres. → Relire les PDF des chiffres cités dans le corps (Rex-Omni F1 72,0/69,8 ; RF100-VL 15,7/5,6 ; Fuzesséry 20,73/8,13, avec l'attribution « RCC/CounTX » à vérifier), et adoucir « aucune étude » en « parmi les N études examinées ».

**M5. Effort de revue vs expérience déséquilibrés / budget de pages** (Journal-Fit)
~5 800 mots de corps pour un budget de ~5 000 (8 pages IEEE) avec 2 figures/tableaux : probable dépassement. Le Background décrit YOLO-World/Grounding DINO mais pas SigLIP 2 ni CountGD++ qui sont les vrais modèles utilisés (déjà noté dans TODO). La Fig. 1 « yolo_world.png » est une capture d'architecture tirée d'un autre papier : droits/valeur faibles pour 0,3 page.

## Problèmes mineurs
- Abstract ≈ 230 mots avec ~15 chiffres ; « All three differences lie outside their 95% bootstrap intervals » est mal formulé (l'IC de la différence exclut zéro).
- Discussion : comparaisons croisées (31 pts AP50 vs 7 pts F1 ; 90,3 % vs 96,4 %/87,2 % pour d'autres modèles/jeux) sont décoratives ; à supprimer ou marquer comme non comparables, déjà à moitié fait.
- « Qwen3.8 » : source = fiche modèle uniquement ; épingler le digest Ollama et le commit de la fiche pour la reproductibilité.
- `#todo` restants : URL GitHub + commit, Fig. 1. Contribution 3 (« analyse des erreurs ») est mince sans la figure ou une taxonomie d'erreurs.
- Les boîtes du VLM sont gratuites : calculer des comptes dérivés des boîtes (VLM et YOLO-World) comble à coût nul le trou que la Synthèse identifie (« aucune étude ne compare comptes dérivés de boîtes et comptes directs »).
- Calibration : vérifier si Ollama expose les logprobs des tokens yes/no ; sinon ECE possible via SigLIP.

## Devil's Advocate — contre-argument le plus fort
Le résultat central (« le VLM bat les spécialistes en présence et comptage ») peut être entièrement expliqué par trois artefacts : (1) le VLM a probablement vu COCO/POPE à l'entraînement ; (2) les spécialistes sont des variantes petites/sous-configurées, et le comptage est dominé par 65 % de zéros faciles ; (3) les « erreurs » du VLM sur les absents sont en partie des objets réels non annotés. Dans ce cas, l'expérience ne mesure ni la fiabilité ni l'avantage du VLM, seulement l'alignement de chaque modèle avec les étiquettes COCO. L'adjudication : C1 et M2 sont validés comme plausibles ; ils doivent être traités (audit manuel + jeu hors COCO) avant d'affirmer « peut remplacer ».

## Feuille de route (priorité décroissante, coût croissant)
1. Audit manuel de ~100 faux positifs VLM (C1) + IC F1 positifs.
2. Reformuler titre/RQ/abstract/conclusion : portée « cas d'étude COCO, un VLM » ; abstract par tranches de comptage.
3. Comptes dérivés des boîtes (VLM, YOLO-World) — gratuit, tout est en cache.
4. IC par tranche + test apparié ; inclure la variance de réglage du seuil (bootstrap tune+test).
5. Robustesse au prompt (4 formulations POPE) + contrôle image vide.
6. Spécialistes plus forts (YOLO-World-L/X, SigLIP 2 templates, CountGD++ cropping).
7. Relire les PDF des chiffres cités ; adoucir les « aucune étude ».
8. Second VLM et/ou jeu hors COCO ; calibration (logprobs).
9. Ajuster longueur (≤ 8 pages) ; décrire SigLIP 2 / CountGD++ dans le Background ; URL du dépôt.

## Vérification des citations (2026-11-15, PDF lus via alphaXiv)

**Exacts** : Rex-Omni (72,0 / 69,8 / 23,0 / 15,9 / 64,0 ; auteurs IDEA communs avec Grounding DINO) ; RF100-VL (15,7 / 5,6 / 2,1 / 1,6 ; SigLIP 2 : 7,4→9,7 et 5,7→8,3 sur RF20-VL) ; Füzesséry (20,73 / 20,96 / 15,69 ; CARPK 30,13+ vs 8,13 ; Lego 2560 → 1) ; CountQA (42,9 %, 15 modèles) ; HoloCount (71,4 / 58,1 / 48,4 ; 20,0 / 0,0 ; 96,4 / 87,2) ; PVFH-Bench (258 images ; 98,45 / 80,62 / 58,14 ; 98,84 → 28,29 ; POPE 88,84 repris d'un autre papier) ; CountGD++ (8,39 / 43,18 / 40,41) ; Chhipa (6,9 / 15,9 / 10,4) ; GroundingME (45,1 %, 25 modèles, rejet ≈ 0 %).

**Corrigés dans `paper/main.typ`** (branche `claude/review-fixes`, non commité) :
- HoloCount : 71,4 % (Qwen3.5-9B) et 20,0 % (Qwen3.5-27B) sont en mode *thinking* (57,5 % sans) ; Qwen3-VL-8B est la version Instruct. Notre run est sans raisonnement.
- CountGD++ 8,39 : obtenu avec pseudo-exemplaires + exemplaires synthétiques générés par GPT-5 ; texte seul = 16,55 (notre cadre). Gemini = `gemini-2.5-flash-image`, refus comptés 0.
- Füzesséry : les auteurs concluent « comparable aux spécialistes » ; en écartant les images à forte erreur, 16,2 et 16,8 contre 15,69.
- 8,13 sur CARPK : CountGD++ l'attribue à CounTX, Füzesséry à RCC. Le texte dit « un spécialiste » : laissé tel quel.

**Pas relu** : Sclar, PARC, Levine, Groot, Ding, Zhang 2024, Lan, VLM-RobustBench, AMBER (phrase sur rappel/précision des « no » à vérifier), MERLIM, LVLM-Count, UNICBench (lu le 2026-11-09), OmniLabel.

## Révision de C1 (2026-11-15, après lecture de RePOPE et Penquitt et al.)

C1 (« les faux positifs du VLM sont peut-être de vrais objets non annotés ») est moins grave que je ne l'avais écrit. RePOPE (réannotation des 500 images POPE) trouve que seules 1,7 % des questions « no » ont une étiquette fausse (0,3 % random, 2,6 % popular, 2,2 % adversarial) et 4,3 % sont ambiguës. L'absence d'une classe entière est donc bien vérifiée dans 94 % des cas, alors que le VLM renvoie une boîte pour 23,5 % des requêtes négatives : l'erreur d'annotation n'explique qu'une petite part de l'écart, au plus quelques points. L'argument « COCO oublie 40 % des objets » (Penquitt et al.) porte sur les instances, surtout petites ou occultées, pas sur des classes entières absentes.

En revanche, les étiquettes des requêtes **positives** sont moins fiables : 9,3 % des « yes » sont faux et 13,8 % ambigus (RePOPE). Rappel et comptages de tous les modèles sont donc mesurés contre des cibles bruitées. Le texte du papier a été ajusté dans ce sens (Results et Discussion, Limits). L'audit manuel de 100 boîtes reste utile pour chiffrer la part exacte, mais n'est plus prioritaire.
