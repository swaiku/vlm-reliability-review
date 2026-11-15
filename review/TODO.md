# Reste à faire (2026-11-13, après le run des spécialistes)

## Papier
- Review : `review/search-log.md` à mettre à jour (voir plus bas) pour que l'ouverture reste exacte.
- Figure 1 de Results : exemples qualitatifs et erreurs (optionnelle, `#todo` dans le texte).
- Mesurer les pages avec la vraie mise en page : installer les polices TeX Gyre (non installées ici).
- Prévenir Raul : `origin/raul` est toujours à `d37caf5`. Il doit fusionner `jeremy`, qui contient sa version du Background plus la Review, Methods et Results.

## Notes de revue à mettre à jour
- `review/search-log.md` et `review/sources.md` : ajouter les sources et recherches faites depuis le 9 novembre (HoloCount, PVFH-Bench, article de robustesse des détecteurs, deux recherches étendues). Le journal dit encore que HoloCount n'a pas été gardé, et le décompte (31 sources) ne correspond plus aux 43 entrées de `refs.yml`.
- `review/feedback-and-gaps.md` : optionnel, les informations sont dans le papier.

## À vérifier
- Comptage : l'attribution de Füzesséry (les 8,13 de MAE sur CARPK sont « RCC » chez lui, « CounTX » chez CountGD).
- Section Domain shift : la phrase sur Roboflow100-VL (« même effet »).

## Optionnel (code)
- Robustesse au prompt (les 4 formulations de POPE). Non mesurée : signalée comme limite dans Results.

## Important pour la fiabilité et la solidité (issu de la relecture simulée du 13 nov.)
Fait le 13 nov. (run des spécialistes, résultats dans le papier) : comptage de CountGD++ par taille, intervalles à 95 % par bootstrap (`src/bootstrap.py`, tous les écarts sont significatifs), positifs / négatifs en localisation, présence avec YOLO-World, seuil de CountGD++ réglé sur tune (0,35). Toutes les sorties sont en cache : les métriques se recalculent sans GPU.
Nouveau point à garder en tête : sur COCO, les comptes de 10 et plus sont peu fiables (43 des 84 requêtes ont une région « crowd » non comptée), signalé dans Results et Discussion.

Reste à faire, par ordre de priorité :
6. **Robustesse au prompt** : les 4 formulations de POPE pour la présence, 2 ou 3 variantes pour la localisation et le comptage. C'est une des trois propriétés de fiabilité du Background, aujourd'hui non mesurée.
7. **Calibration / confiance** : proposer une confiance au VLM (probabilités des jetons « yes » et « no » si Ollama les expose, ou scores SigLIP 2 sur les boîtes) et mesurer l'ECE. Troisième propriété du Background, non mesurée.
8. **Contrôle avec image vide** (présence) pour voir si la réponse dépend de l'image (Lan et al.).
9. **Figure 1** : exemples qualitatifs et erreurs, ou reformuler la contribution 3.
10. **Taille et coût** : justifier `yolov8s-worldv2` face à un VLM de 27 milliards de paramètres, ou ajouter une variante plus grande ; noter le temps par requête.
11. **Un second VLM** (Gemma 4, LFM3-VL) pour ne pas conclure sur un seul modèle.
12. **Jeux hors domaine** (Roboflow100-VL, FSC-147) : pour la robustesse au décalage de domaine.

## Fin du papier
- URL GitHub et commit dans Implementation (`#todo` dans le texte).
