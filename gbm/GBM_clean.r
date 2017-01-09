
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

trctrl = trainControl(
                     method = 'repeatedcv',
                     number = 3,
                     returnResamp='none',
                     summaryFunction = twoClassSummary,
                     allowParallel = TRUE,
                     classProbs = TRUE
                     )

grid = expand.grid(
                  n.trees=c(1000,250),
                  interaction.depth = 4,
                  shrinkage = 0.1,
                  n.minobsinnode = 10
                  )

gbm.model = train(target~.,
              method = "gbm",
              data = sub.train,
              trControl = trctrl,
              metric = "ROC",
              tuneGrid = grid
             )

plot(gbm.model) # visialusation des performances 

gbm.model

result.predicted.prob <- predict(gbm.model, sub.test , type="prob") # Prediction

result.roc <- roc(sub.test$target, result.predicted.prob$OK) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

save(gbm.model, file="gbm.model.Rdata")

result.predicted.prob.valid <- predict(gbm.model, projetValid , type="prob") # Prediction on validation subset
projetValid$Id = as.character(projetValid$Id)
validation.results = cbind(projetValid[,"Id",with=FALSE],result.predicted.prob.valid)
write.csv(validation.results, file = "validation_results.csv")
