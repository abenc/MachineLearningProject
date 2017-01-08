
library(data.table)
library(randomForest)
library(corrplot)
load("projetdatascience.rda")

vec_names         = names(projetTrain)
nb_lignes         = nrow(projetTrain)
vec_taux          = rep(0,length(vec_names))
vec_factors       = rep(0,length(vec_names))
index             = 1
data.informations = data.table(
                         feature=vec_names, 
                         taux=vec_taux,
                         factors=vec_factors
                        )


for(name in data.informations$feature){
    data.informations[index,  taux := (sum( is.na(projetTrain[,name, with=FALSE])) / nb_lignes)*100] 
    data.informations[index,factors:= length(table(projetTrain[,name, with=FALSE]))]
    index=index+1
}

data.informations[taux>0]

columnsToFactor = data.informations[factors<10]$feature

projetTrain = projetTrain[,target:=ifelse(target==1,"OK","KO")] # transforming target from 1 0 to OK and KO

for (feature in columnsToFactor) {    
    if(feature != "target" ) { 
        projetValid[,feature:=as.factor(get(feature)),with=FALSE]
    }
    projetTrain[,feature:=as.factor(get(feature)),with=FALSE]
}
projetTrain$Product_Info_2 = as.factor(projetTrain$Product_Info_2)
projetValid$Product_Info_2 = as.factor(projetValid$Product_Info_2)

projetTrain = na.roughfix(projetTrain)

projetTrain[,Product_Info_2_Quali  := gsub("[0-9]","",Product_Info_2)]
projetTrain[,Product_Info_2_Quanti := gsub("[A-Z]","",Product_Info_2)]

projetTrain$Product_Info_2_Quali  = as.factor(projetTrain$Product_Info_2_Quali)
projetTrain$Product_Info_2_Quanti = as.integer(projetTrain$Product_Info_2_Quanti) 

projetValid[,Product_Info_2_Quali  := gsub("[0-9]","",Product_Info_2)]
projetValid[,Product_Info_2_Quanti := gsub("[A-Z]","",Product_Info_2)]

projetValid$Product_Info_2_Quali  = as.factor(projetValid$Product_Info_2_Quali)
projetValid$Product_Info_2_Quanti = as.integer(projetValid$Product_Info_2_Quanti) 

index = 1
for(name in data.informations$feature){
    data.informations[index,class := class(as.data.frame(projetTrain[,name,with=FALSE])[,name])]
    index=index+1
}

'%!in%' <- function(x,y)!('%in%'(x,y)) #CREATING NOT IN OPERATOR THAT RETURNS MASK 

numeric.columns         = data.informations[class=="numeric"]$feature
integer.columns         = data.informations[class=="integer"]$feature
todrop.columns          = c("Id",data.informations[taux > 17]$feature)

aggr.columns            = c(numeric.columns,integer.columns)
mask.of.columns.to.drop = aggr.columns %!in% todrop.columns #columns that are not in todrop.columns
final.columns           = aggr.columns[mask.of.columns.to.drop]

for(column in final.columns){
    projetTrain[,paste0(column,"_log") := log(get(column))]
    projetTrain[,paste0(column,"_²")   := get(column)^get(column)]
    projetTrain[,paste0(column,"exp")  := exp(get(column))]
    
    projetValid[,paste0(column,"_log") := log(get(column))]
    projetValid[,paste0(column,"_²")   := get(column)^get(column)]
    projetValid[,paste0(column,"exp")  := exp(get(column))]
}

M = cor(projetTrain[,final.columns,with=FALSE])
corrplot(M, method = "circle")

starting.point = 2 

for(i in seq(1,ncol(M))){
    
    if(starting.point < 13){ #loop meant to cover just the part under the diagonal of the matrix
        
            for(j in seq(starting.point,nrow(M))){
    
            if( abs(M[i,j]) > 0.18 ){ #if the correlation is above |0.18| we'll create a column that will multiply the correlated ones, and divide them by the correlation coefficient
                name.of.col.first  = final.columns[i]
                name.of.col.second = final.columns[j]
                coef.corr          = M[i,j]
                
                if( !(name.of.col.first =="Ht" && name.of.col.second=="Wt" ) &&
                    !(name.of.col.first=="Wt" && name.of.col.second=="BMI") ){ # We don't consider the relation between WT and BMI and Ht and Wt
                    
                    print(paste(name.of.col.first,name.of.col.second,"COEF CORR :",M[i,j]))
                    
                    first.vec        = projetTrain[,name.of.col.first,with=FALSE]
                    second.vec       = projetTrain[,name.of.col.second,with=FALSE]
                    
                    first.vec.valid  = projetValid[,name.of.col.first,with=FALSE]
                    second.vec.valid = projetValid[,name.of.col.second,with=FALSE]
                    
                    if( max(first.vec) <= 1 && max(second.vec) <= 1){
                        projetTrain[,paste0(name.of.col.first,"_",name.of.col.second)] = ( first.vec / second.vec ) / coef.corr
                        projetValid[,paste0(name.of.col.first,"_",name.of.col.second)] = ( first.vec.valid / second.vec.valid ) / coef.corr
                    }
                    else{
                        projetTrain[,paste0(name.of.col.first,"_",name.of.col.second)] = ( first.vec * second.vec ) / coef.corr
                        projetValid[,paste0(name.of.col.first,"_",name.of.col.second)] = ( first.vec.valid * second.vec.valid ) / coef.corr

                    }
                }
                
            }
        } 
        starting.point = starting.point+1
    }
}

write.csv(projetTrain, file = "data_processed/projetTrainProcessed.csv")
write.csv(projetValid, file = "data_processed/projetValidProcessed.csv")
