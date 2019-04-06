data = read.csv("C:/Users/sbh0613/Desktop/와이빅타/이상치분석/creditcardfraud/creditcard.csv")

dim(data)

table(data$Class)

table(data$Class)[2]/(table(data$Class)[1] + table(data$Class)[2])

which(data$Class == 1)[1:10]

library(abodOutlier)

start_time <- Sys.time()

abod.result = abod(data[500:550,],method="complete")

end_time <- Sys.time()

#running time

end_time - start_time

abod.result[1:5]

abod.mat = cbind(abod.result,500:550)

head(abod.mat[order(abod.result),])






