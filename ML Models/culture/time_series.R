library(ggplot2)
library(forecast)
library(astsa)
library(lmtest)
library(fUnitRoots)
library(FitARMA)
library(strucchange)
library(reshape)
library(Rmisc)
library(aTSA)
library(urca)
library(devtools)
library(TSA)



url <- "https://www.openintro.org/stat/data/arbuthnot.csv"
abhutondot <- read.csv(url, header=TRUE)
nrow(abhutondot)

abhutondot_rs <- melt(abhutondot, id = c("year"))

ggplot(data = abhutondot_rs, aes(x = year)) + geom_line(aes(y = value, colour = variable)) +
  scale_colour_manual(values = c("blue", "red"))

excess_frac <- (abhutondot$boys - abhutondot$girls)/abhutondot$girls
excess_ts <- ts(excess_frac, frequency = 1, start = abhutondot$year[1])
plot(excess_ts)

urdftest_lag = floor(12*(length(excess_ts)/100)^0.25)
urdfTest(excess_ts, type = "c", lags = urdftest_lag, doplot = FALSE)

par(mfrow=c(1,2))
acf(excess_ts)
pacf(excess_ts)

df = ur.df(data$avg, type='none', lag=0)
summary(df)
adf.test(excess_ts, nlag=1)

# load data
data = read.csv('/Users/shinbo/Desktop/공모전/문화관광/data/tmp.csv')

# ACF, PACF
par(mfrow=c(1,2))
acf(diff(data$avg))
pacf(diff(data$avg))
ts.plot(sqrt(data$avg))
ts.plot(log(data$avg))


# test for stationary
adf.test(diff(log(data$avg)))
df = ur.df(diff(data$vlm), type='none', lag=0)
summary(df)

# fit ARIMA model
# compare loglikelihood without xreg
model1 = auto.arima(log(data$vlm)[1:(42-3)], xreg=c(rep(0,36),1,10,7),stepwise=FALSE,approx=FALSE, d=1)
summary(model1)
coeftest(model1)
checkresiduals(model1)
arima.pred = forecast(model1, h=3, xreg=c(7,8,8))
ts.plot(c(model1$fitted,arima.pred$mean),col='red')
par(new=T)
ts.plot(log(data$vlm),col='black')


