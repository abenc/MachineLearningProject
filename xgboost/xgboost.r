
library(data.table)
library(caret)
library(pROC)

load("../data_processed/projetDataBase.Rda")
projetTrain    = sub.projetTrain.base
projetValid    = sub.projetValid.base

set.seed(30)
split = sample(nrow(projetTrain), floor(0.5*nrow(projetTrain)))
sub.train = projetTrain[split,]
sub.test  = projetTrain[-split,]

cv.ctrl <- trainControl(method = "repeatedcv", repeats = 1,number = 3, 
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE,
                        allowParallel=T)

xgb.grid <- expand.grid(nrounds          = 1000,
                        eta              = c(0.01,0.05,0.1),
                        max_depth        = c(2,4,6,8,10,14),
                        gamma            = 1,
                        colsample_bytree = 1,    #default=1
                        min_child_weight = 1     #default=1
                        )

xgb.model <-train(target~.,
                     data=sub.train,
                     method="xgbTree",
                     trControl=cv.ctrl,
                     tuneGrid=xgb.grid,
                     verbose=T,
                     metric="Kappa",
                     nthread =4
)

plot(xgb.model)

xgb.model

result.predicted.prob <- predict(xgb.model, sub.test , type="prob") # Prediction

result.roc <- roc(sub.test$target, result.predicted.prob$OK) # Draw ROC curve.
plot(result.roc, print.thres="best", print.thres.best.method="closest.topleft")

result.coords <- coords(result.roc, "best", best.method="closest.topleft", ret=c("threshold", "accuracy"))
print(result.coords)#to get threshold and accuracy

save(xgb.model, file="xgb.Rdata")

result.predicted.prob.valid <- predict(xgb.model, projetValid , type="prob") # Prediction on validation subset
projetValid$Id = as.character(projetValid$Id)
validation.results = cbind(projetValid[,"Id",with=FALSE],result.predicted.prob.valid)
write.csv(validation.results, file = "validation_results.csv")
