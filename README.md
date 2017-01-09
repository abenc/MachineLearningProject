# Machine learning project

## Project structure

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

La structure des fichiers gbm,glmnet,randomforest,rpart et xgboost est la même, on retrouve :
* un .ipynb qui à l'avantage de bien structurer le code et de montrer les output de chaque morceaux de code (on peut voir l'auc, la cross validation etc.)
* un .r qui est lui executable sur R studio
* un .Rdata qui est la sauvegarde du model calculé car les script mettent relativement longtemps à les generer, (il suffit de load(* .rdata) pour l'utiliser)
* un .csv qui correspond à la réponse du model au fichier de validation

# Rapport du projet Machine learning


## Data exploitation

### Data visualisations
### Data Cleaning
### Data Expanding

## Les differents algorithmes utilisés ainsi que leurs resultats
### rpart
### gbm
### randomforest
### xgboost
### glmnet
