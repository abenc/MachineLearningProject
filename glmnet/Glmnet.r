
library(data.table)
library(caret)
library(pROC)

load("../data_processed/projetDataBase.Rda")
projetTrain    = sub.projetTrain.base
projetValid    = sub.projetValid.base

set.seed(0)
split = sample(nrow(projetTrain), floor(0.3*nrow(projetTrain)))
sub.train = projetTrain[split,]
sub.test  = projetTrain[-split,]

lambda.grid = seq(0.005,0.006,length=5)
alpha.grid  = seq(0.43,0.6,length=5)
srchGrid    = expand.grid(.alpha=alpha.grid,.lambda=lambda.grid)
trnCtl      = trainControl(method="repeatedCV",number=5,repeats=2) # cadrage coss valisation

glmnet.model = train(target~.,data=sub.train,method="glmnet",tuneGrid=srchGrid,trControl=trnCtl,standardize=TRUE)#,maxit=1000000)

plot(glmnet.model) # visialusation des performances pour les diffï¿½rentes valeurs de alpha et beta"

glmnet.model

result.predicted.prob <- predict(glmnet.model, sub.test , type="prob") # Prediction

result.roc <- roc(sub.test$target, result.predicted.prob$OK) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

save(glmnet.model, file="workspace_glmnet.Rdata")

result.predicted.prob.valid <- predict(glmnet.model, projetValid , type="prob") # Prediction on validation subset
projetValid$Id = as.character(projetValid$Id)
validation.results = cbind(projetValid[,"Id",with=FALSE],result.predicted.prob.valid)
write.csv(validation.results, file = "validation_results.csv")
