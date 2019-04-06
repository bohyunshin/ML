data = read.csv("C:/Users/sbh0613/Desktop/와이빅타/이상치분석/creditcardfraud/creditcard.csv",header=T)

library(HighDimOut)

table(data$Class)

which(names(data) == 'Class')

start_time = Sys.time()

sod.result = Func.SOD(data[1:10000,-31],k.nn=3,k.sel=5,alpha=0.8)

end_time = Sys.time()

#running time

end_time - start_time

sod.result.mat = cbind(sod.result,1:10000)

sod.result.mat = sod.result.mat[order(sod.result,decreasing=TRUE),]

colnames(sod.result.mat) = c("value","index")

sod.result.mat[1:10,]

fraud.index = which(data$Class == 1)[ which(data$Class == 1) <= 10000 ]

rank.vec = c()

for (i in 1:length(fraud.index)){
  
  for (j in 1:length(sod.result.mat[,"index"]) ){
    
    if (fraud.index[i] == sod.result.mat[,"index"][j]) rank.vec[i] = j
    
  }
  
}

cbind(fraud.index,rank.vec)

setwd("C:/Users/sbh0613/Desktop/와이빅타/이상치분석/creditcardfraud/")

save.image()

#SNN

start_time = Sys.time()

snn.result = Func.SNN(data[1:10000,-31],k.nn=3,k.sel=10)

end_time = Sys.time()

snn.result

data(TestData)

write.csv(TestData,file='tooutlierstudy.csv')

getwd()

load("C:/Users/sbh0613/Desktop/와이빅타/이상치분석/SOD/.RData")
head(snn.result)
dim(snn.result)

start_time - end_time
