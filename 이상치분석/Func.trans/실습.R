library(HighDimOut)

data(TestData)

mydata = TestData

# ordinary ABOD

abod.result = Func.ABOD(mydata[,-3],basic=T,perc=1)

mydata[order(abod.result,decreasing=F),] # abod는 값이 작을 수록 outlier라고 판단.

# Fast ABOD

# Feature Bagging

fbod.result = Func.FBOD(mydata[,-3],iter=10,k.nn=5)

mydata[order(fbod.result,decreasing=T),] # fbod는 값이 클 수록 outlier라고 판단.

# Func.SOD

sod.result = Func.SOD(mydata[,-3],k.nn=10,k.sel=5,alpha=0.8)

mydata[order(sod.result,decreasing=T),] # sod는 값이 클 수록 outlier라고 판단.

# Transform outlier scores into range 0 and 1

trans.abod = Func.trans(abod.result,method="ABOD")

trans.fbod = Func.trans(fbod.result,method="FBOD")

trans.sod = Func.trans(sod.result,method="SOD")

trans.merge = trans.abod + trans.fbod + trans.sod

mydata[order(trans.merge,decreasing=T),]


