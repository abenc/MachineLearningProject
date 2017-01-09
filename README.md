# Machine learning project

## I Project structure

```
projetML
│   README.md
│   projetdatascience.rda    # dataset initial
│
└───data_processed
│   │   projetDataBase.Rda  # dataset utilisé dans les algorithmes
│   │
│   └───csvformat
│       │   projetTrainProcessed.csv
│       │   ...
│   
└───data_processing
│   │   Data Cleaning and expanding.ipynb # script R en jupyternotebook ou je traite "projetdatascience.rda" pour generer "data_processed/projetDataBase.rda"
│   │   Data_Cleaning_and_expanding.r     # script R executable sur R studio
│   │   Exploration data python.ipynb     # essai d'exploration de données à l'aide de python
│
└───gbm
│   │  GBM_clean.ipynb # script R en jupyternotebook qui utilise les données pour decrire un modele et genere "validation_results.csv"
│   │  GBM_clean.r     # script R executable sur R studio
│   │  gbm.model.Rdata # sauvegarde du model calculé
│   │  validation_results.csv # fichier reponse du set de validation 
...
```
