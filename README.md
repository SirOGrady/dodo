# Projet MMASH : Prédire le sommeil via les montres connectées 
**Problématique :** Peut-on prédire la qualité de sommeil d'un individu à partir de son comportement de la journée ?
L'objectif est de comprendre et reproduire le fonctionnement des algorithmes des montres connectées.

## Présentation du projet
Ce projet analyse le dataset MMASH (Multilevel Monitoring of Activity and Sleep in Healthy people). Nous explorons les corrélations entre l'activité physique, la variabilité cardiaque, le stress psychologique et la qualité du sommeil sur 22 sujets suivis pendant 48 heures.

## Méthodologie
1. Analyse Exploratoire & Descriptive (descriptive.qmd)

- Profils Biométriques : Analyse de l'IMC et des caractéristiques physiques.
- Chronogrammes d'activités : Visualisation des cycles de 48h (sommeil, travail, sport, écrans).
- Rythme Circadien : Évolution de la fréquence cardiaque (via les données RR) pour identifier les phases de récupération.

2. Approche Non-Supervisée (predictive.qmd)

Nous avons identifié deux profils types via un algorithme de clustering :
- Profil 1 : Individus à l'IMC normal.
- Profil 2 : Individus en surpoids mais actifs.

PCA (ACP) : Analyse des composantes principales pour isoler les facteurs influençant un score de Pittsburgh < 6 (seuil d'une bonne qualité de sommeil).

3. Apprentissage Supervisé (predictive.qmd)

Développement d'un modèle pour prédire :

- Variables cibles : Temps de sommeil, score d'énergie.
- Features : Accéléromètre, inclinomètre, nombre de pas, fréquence cardiaque.

Validation : Méthode Leave-One-Out (LOO) pour garantir que l'algorithme fonctionne sur un nouvel utilisateur inconnu.

## Dashboard Interactif (app.R)
Une application Shiny accompagne ce projet pour permettre une exploration visuelle et dynamique :

Sélection individuelle par sujet.

Visualisation des signaux cardiaques et des types d'activités.

## Installation et Utilisation
Clonez le dépôt :

```Bash
git clone https://github.com/votre-compte/projet-sommeil-mmash.git
```

Assurez-vous d'avoir les packages suivants installés dans R :
tidyverse, shiny, lubridate, ggplot2, factoextra, randomForest.

Lancez le dashboard :

```R
shiny::runApp("app.R")
```

## Résultats Clés

Clustering : L'activité physique modère l'impact de l'IMC sur l'efficacité du sommeil.

Prédiction : Le modèle Random Forest parvient à estimer le temps de sommeil avec une erreur moyenne de 49,2 minutes en validation croisée.

*Projet réalisé dans le cadre de l'UE épidémiologie et aide à la prise de décision.*

