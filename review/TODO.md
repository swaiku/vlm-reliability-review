# Reste à faire (2026-11-11)

## Choix à faire
- Le VLM (`lfm3-vl:2b` provisoire, sinon Qwen3.8 27b ou Gemma 4), son étiquette Ollama et sa quantification.
- Où écrire les critères de fiabilité : ouverture de la Review ou Background.

## Papier
- Ouverture de la Review, Results (tableau 3 et figure 1), Discussion, Conclusion, résumé.
- Remplir les `#todo` de Methods : tailles des sous-ensembles, versions, matériel, dates.
- Citer dans Methods > Models les sources déjà dans `refs.yml` : Gemma 3, fiches Qwen3.5, 3.6 et 3.8.
- Mettre à jour `review/feedback-and-gaps.md` avec HoloCount et PVFH-Bench.
- Installer les polices TeX Gyre pour mesurer les pages avec la vraie mise en page.
- Prévenir Raul de la fusion, et reformuler avec lui les phrases de son Background sur « les modèles que nous comparons ».

## À vérifier
- Tableau 1 : la colonne « Données » de Ramachandran, et l'attribution de Füzesséry (les 8,13 de MAE sur CARPK sont « RCC » chez lui, « CounTX » chez CountGD).
- Phrase de la section Domain shift (« même effet » pour Roboflow100-VL), chiffre de Sclar (76 points), mention « tous les VLM datent de 2025 ou avant ».

## Code (`experiments/`)
- Convertisseurs qui fabriquent les JSONL : POPE, annotations COCO, Roboflow100-VL, FSC-147.
- Robustesse au prompt (les 4 formulations de POPE) et taux de faux positifs sur les requêtes négatives.
- Wrapper CountGD, qui peut ne pas compiler sous ROCm.
- Test de fumée sur la bonne machine : Ollama utilise le GPU, format des boîtes du VLM, API de YOLO-World et de SigLIP 2.
- `uv lock` sur la machine GPU, puis installation de PyTorch ROCm.

## À ne pas pousser
- `review/notes/dataset-draft.md` reste hors du dépôt.
