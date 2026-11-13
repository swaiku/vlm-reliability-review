# Reste à faire (2026-11-13)

## Papier
- Review : `review/search-log.md` à mettre à jour (voir plus bas) pour que l'ouverture reste exacte.
- Figure 1 de Results : exemples qualitatifs et erreurs (optionnelle, `#todo` dans le texte).
- Results : comptage par taille pour CountGD++ (colonne « n/a » du tableau 2), au prochain run.
- Mesurer les pages avec la vraie mise en page : installer les polices TeX Gyre (non installées ici).
- Prévenir Raul : `origin/raul` est toujours à `d37caf5`. Il doit fusionner `jeremy`, qui contient sa version du Background plus la Review, Methods et Results.

## Notes de revue à mettre à jour
- `review/search-log.md` et `review/sources.md` : ajouter les sources et recherches faites depuis le 9 novembre (HoloCount, PVFH-Bench, article de robustesse des détecteurs, deux recherches étendues). Le journal dit encore que HoloCount n'a pas été gardé, et le décompte (31 sources) ne correspond plus aux 43 entrées de `refs.yml`.
- `review/feedback-and-gaps.md` : optionnel, les informations sont dans le papier.

## À vérifier
- Comptage : l'attribution de Füzesséry (les 8,13 de MAE sur CARPK sont « RCC » chez lui, « CounTX » chez CountGD).
- Section Domain shift : la phrase sur Roboflow100-VL (« même effet »).

## Optionnel (code)
- Robustesse au prompt (les 4 formulations de POPE) et taux de faux positifs par tâche. Non mesurés : ils sont signalés comme limites dans Results.

## Git
- Non commités : Methods complétée, retrait des jeux hors domaine, README, ce fichier. Rien de poussé depuis le run (`343c7db`).
