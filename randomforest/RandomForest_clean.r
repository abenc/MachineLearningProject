
library(data.table)
library(caret)
library(pROC)

load("../data_processed/projetDataBase.Rda")
projetTrain    = sub.projetTrain.base
projetValid    = sub.projetValid.base

set.seed(30)
split = sample(nrow(projetTrain), floor(0.1*nrow(projetTrain)))
sub.train = projetTrain[split,]
sub.test  = projetTrain[-split,]

control    = trainControl(method="repeatedcv", number=4, repeats=2)
seed       = 7
metric     = "Accuracy"
mtry       = floor(sqrt(ncol(sub.train)))
tunegrid   = expand.grid(.mtry=mtry)

rf.model = train(target~., 
                   data=sub.train,
                   method="rf",
                   metric=metric,
                   tuneGrid=tunegrid,
                   trControl=control,
                   importance=TRUE,
                   localImp=TRUE,
                   proximity=TRUE)

rf.model

result.predicted.prob <- predict(rf.model, sub.test , type="prob") # Prediction

result.roc <- roc(sub.test$target, result.predicted.prob$OK) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

result.coords <- coords(result.roc, "best", best.method="closest.topleft", ret=c("threshold", "accuracy"))
print(result.coords)#to get threshold and accuracy

save(rf.model, file="rf_model.Rdata")

result.predicted.prob.valid <- predict(rf.model, projetValid , type="prob") # Prediction on validation subset
projetValid$Id = as.character(projetValid$Id)
validation.results = cbind(projetValid[,"Id",with=FALSE],result.predicted.prob.valid)
write.csv(validation.results, file = "validation_results.csv")
