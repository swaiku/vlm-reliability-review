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

## Important pour la fiabilité et la solidité (issu de la relecture simulée du 13 nov.)
À faire, par ordre de priorité. Les trois premiers n'ont pas besoin de nouveau run : les prédictions par requête sont dans `results/predictions/` sur la machine du run.
1. **Comptage de CountGD++ par taille de compte** (0, 1-3, 4-9, 10+), depuis `results/predictions/counting.jsonl`. Sans cela, la colonne « n/a » du tableau reste, et on ne sait pas où est son RMSE élevé. Mettre à jour résumé, Discussion et Conclusion après coup.
2. **Intervalles de confiance à 95 %** par bootstrap sur les 400 images de test (présence, F1 de localisation, MAE de comptage), depuis les réponses VLM sauvegardées. Dire si les écarts (surtout 7 points de F1 en localisation) sont significatifs.
3. **Résultats séparés sur les requêtes positives et négatives** en localisation (précision, rappel), pour voir d'où viennent les faux positifs du VLM. Même chose pour le comptage du spécialiste.
4. **Base de présence avec YOLO-World** : la présence se déduit des détections déjà calculées (un objet est présent si au moins une boîte dépasse le seuil). C'est le spécialiste naturel selon le Background. Comparer à SigLIP 2 ou justifier ce choix.
5. **Seuil de CountGD++ réglé sur « tune »** comme les deux autres spécialistes, ou noter l'asymétrie dans Methods.
6. **Robustesse au prompt** : les 4 formulations de POPE pour la présence, 2 ou 3 variantes pour la localisation et le comptage. C'est une des trois propriétés de fiabilité du Background, aujourd'hui non mesurée.
7. **Calibration / confiance** : proposer une confiance au VLM (probabilités des jetons « yes » et « no » si Ollama les expose, ou scores SigLIP 2 sur les boîtes) et mesurer l'ECE. Troisième propriété du Background, non mesurée.
8. **Contrôle avec image vide** (présence) pour voir si la réponse dépend de l'image (Lan et al.).
9. **Figure 1** : exemples qualitatifs et erreurs, ou reformuler la contribution 3.
10. **Taille et coût** : justifier `yolov8s-worldv2` face à un VLM de 27 milliards de paramètres, ou ajouter une variante plus grande ; noter le temps par requête.
11. **Un second VLM** (Gemma 4, LFM3-VL) pour ne pas conclure sur un seul modèle.
12. **Jeux hors domaine** (Roboflow100-VL, FSC-147) : pour la robustesse au décalage de domaine.

## Fin du papier
- URL GitHub et commit dans Implementation (`#todo` dans le texte).
