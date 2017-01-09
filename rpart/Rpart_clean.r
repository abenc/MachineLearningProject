
library(data.table)
library(rpart)
library(rpart.plot)
library(pROC)

load("../data_processed/projetDataBase.Rda")
projetTrain    = sub.projetTrain.base
projetValid    = sub.projetValid.base

set.seed(30)
split = sample(nrow(projetTrain), floor(0.8*nrow(projetTrain)))
sub.train = projetTrain[split,]
sub.test  = projetTrain[-split,]

rpart.model = rpart(target~.,data=sub.train,control=rpart.control(minsplit=5,cp=0))

rpart.model.optimal = prune(rpart.model,cp=rpart.model$cptable[which.min(rpart.model$cptable[,4]),1])

summary(rpart.model.optimal)

result.predicted.prob <- predict(rpart.model.optimal, sub.test , type="prob") # Prediction



result.roc <- roc(sub.test$target, result.predicted.prob[,"OK"]) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

result.coords <- coords(result.roc, "best", best.method="closest.topleft", ret=c("threshold", "accuracy"))
print(result.coords)#to get threshold and accuracy

save(rpart.model.optimal, file="rpart_model.Rdata")

result.predicted.prob.valid <- predict(rpart.model.optimal, projetValid , type="prob") # Prediction on validation subset
projetValid$Id = as.character(projetValid$Id)
validation.results = cbind(projetValid[,"Id",with=FALSE],result.predicted.prob.valid)
write.csv(validation.results, file = "validation_results.csv")
