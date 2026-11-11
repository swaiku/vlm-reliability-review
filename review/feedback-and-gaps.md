# Retour reçu et analyse des trous (2026-11-09)

## Retour (texte collé)

> méthodes et contexte un peu mélangé.
> Qwen3.5 3.6 3.8 faut mentionner
> Gemma voir aussi
>
> Identifier les trous dans les résultats en analysant les résultats des papers pour ainsi faire ça

Consigne orale : faire le tableau de résultats maintenant, pour voir quels résultats manquent et adapter l'expérience.

## Faisable ou non

| Point | Modifiable ? | État dans le dépôt |
|---|---|---|
| Méthodes et contexte mélangés | Oui, texte à nous. À préciser quel passage est visé. | Pistes : Background 2.3 définit les métriques (IoU, AP, F1) qui reviennent dans Methods > Metrics ; l'ouverture de la Review est un `#todo` qui devra expliquer la démarche (méthode de revue). |
| Mentionner Qwen3.5, 3.6, 3.8 | Oui, mais à sourcer. | Qwen3.5-9B : fiche modèle dans `refs.yml` (`qwen35card`). Qwen3.8 : fiche seulement, aucun article (`search-log.md`). Qwen3.6 : aucune trace dans le dépôt, à chercher. Les trois sont des modèles, pas des résultats de papiers. |
| Gemma | Oui, à chercher. | Aucune source ni mention dans le dépôt. |
| Tableau des résultats / trous | Oui, première version ci-dessous. | Basé sur `sources.md`, lu au niveau résumé : les listes de modèles de chaque papier ne sont pas toutes relues. |

## Tableau 1 : qui a évalué quoi (modèles évalués dans les papiers)

« — » veut dire : absent de nos notes, pas forcément absent du papier.

| Tâche | Famille ancienne (GPT-4V/4o, Gemini 1.x, LLaVA, Qwen2-VL) | Qwen2.5-VL | Qwen3-VL | Qwen3.5 / 3.6 / 3.8 | Gemma | Spécialiste comparé |
|---|---|---|---|---|---|---|
| Présence | POPE, AMBER, MERLIM, HallusionBench (GPT-4V 31,42 %) | — | — | — | — | Aucun (SigLIP 2 non comparé) |
| Présence, rejet | GroundingME (25 MLLM, liste non lue) | à lire | à lire | — | — | Aucun |
| Localisation | Ramachandran (GPT-4o, Gemini, Qwen2-VL), DetToolChain (GPT-4V, Gemini) | RF100-VL | rapport Qwen3-VL (ODinW-13, auto-rapporté) | — | — | Co-DETR (Ramachandran) ; Grounding DINO (Rex-Omni, auto-rapporté) |
| Comptage | CountQA (15 MLLM), Fuzesséry (GPT-4o, GPT-5), LVLM-Count | à lire | à lire | — | — | CountGD++ vs MLLM sur FSC-147 (non relu) |

## Tableau 2 : critère de fiabilité couvert par la littérature

| Critère | Présence | Localisation | Comptage |
|---|---|---|---|
| Exactitude | couvert (2023) | couvert, peu de modèles récents | couvert (UNICBench, CountQA) |
| Robustesse au prompt | PARC, Promptception : QCM seulement | Ramachandran : 17,69 vs 60,62 selon le prompt | aucune source |
| Négatifs / rejet | GroundingME (1 benchmark) | OmniLabel (non lu) | aucune source |
| Calibration | aucune source sur extraction | aucune source sur boîtes | Groot 2024 (modèles obsolètes) |
| VLM contre spécialiste, photos réelles, même protocole | aucune source | partiel (Ramachandran, Rex-Omni) | partiel (CountGD++ non relu) |
| Modèles 2026 (Qwen3.x, Gemma) | aucune source | aucune source indépendante | aucune source |

## Trous prioritaires (à confirmer en relisant les papiers)

1. Aucun résultat indépendant sur Qwen3-VL, Qwen3.5 ou Gemma, pour les trois tâches : c'est le trou que notre expérience comble.
2. Aucune comparaison VLM contre spécialiste au même seuil, sur les mêmes photos, pour la présence.
3. Robustesse au prompt mesurée seulement sur QCM, sauf Ramachandran.
4. Calibration : rien pour les VLM sur boîtes ou comptage.
5. Négatifs : GroundingME seul pour le rejet.

## À faire

- Relire les listes de modèles de GroundingME, CountQA, UNICBench, RF100-VL et CountGD++ pour remplir les cases « à lire ».
- Chercher Qwen3.6 et Gemma (fiches et papiers) ; ajouter les clés dans `refs.yml`.
- Décider quel passage mélange méthodes et contexte.
