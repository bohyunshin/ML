## fitting glmm model!!
setwd("/Users/shinbo/Desktop/공모전/문화관광/")
glmm_data_17 = read.csv('data_glmm/17_glmm.csv')
glmm_data_18 = read.csv('data_glmm/18_glmm.csv')
glmm_data_19 = read.csv('data_glmm/19_glmm.csv')
glmm_data_20 = read.csv('data_glmm/20_glmm.csv')

glmm_data_17_upper = glmm_data_17[glmm_data_17$half == 'upper',-11]
glmm_data_17_lower = glmm_data_17[glmm_data_17$half == 'lower',-11]

glmm_data_18_upper = glmm_data_18[glmm_data_18$half == 'upper',-11]

glmm_data_18_lower = glmm_data_18[glmm_data_18$half == 'lower',-11]
glmm_data_18_lower = glmm_data_18_lower[-which(is.infinite(glmm_data_18_lower$vlm)),]

glmm_data_19_upper = glmm_data_19[glmm_data_19$half == 'upper',-11]
glmm_data_19_upper = glmm_data_19_upper[-which(is.infinite(glmm_data_19_upper$vlm)),]

glmm_data_19_lower = glmm_data_19[glmm_data_19$half == 'lower',-11]
glmm_data_19_lower = glmm_data_19_lower[-which(is.infinite(glmm_data_19_lower$vlm)),]

glmm_data_20_upper = glmm_data_20[glmm_data_20$half == 'upper',-11]
glmm_data_20_upper = glmm_data_20_upper[-which(is.infinite(glmm_data_20_upper$vlm)),]



library(nlme)
library(lme4)

formula = vlm ~. -v3 + (other_서울+category_미술공예참여+category_사진촬영+
                          category_악기연주+category_음악감상+sex_M+weekend_WHITE+
                          activity_활동+activity_휴식+month | v3)
model_17_upper = lmer(formula, data=glmm_data_17_upper)
model_17_lower = lmer(formula, data=glmm_data_17_lower)

model_18_upper = lmer(formula, data=glmm_data_18_upper)
model_18_lower = lmer(formula, data=glmm_data_18_lower)

model_19_upper = lmer(formula, data=glmm_data_19_upper)
model_19_lower = lmer(formula, data=glmm_data_19_lower)

model_20_upper = lmer(formula, data=glmm_data_20_upper)
anova(model_20_upper)

sum((glmm_data_20_upper$vlm - fitted(model_20_upper))^2) / dim(glmm_data_20_upper)[1]
exp(2.5)
coef(model_20_upper)
summary(model_20_upper)
fixef(model_20_upper)
ranef(model_20_upper)

coef_17_upper = data.frame(coef(model_17_upper)[[1]])
coef_17_lower = data.frame(coef(model_17_lower)[[1]])

coef_18_upper = data.frame(coef(model_18_upper)[[1]])
coef_18_lower = data.frame(coef(model_18_lower)[[1]])

coef_19_upper = data.frame(coef(model_19_upper)[[1]])
coef_19_lower = data.frame(coef(model_19_lower)[[1]])

coef_20_upper = data.frame(coef(model_20_upper)[[1]])

coef_19_lower[1,]
coef_20_upper[1,]

summary(model_19_lower)

estimate_vlm = function(gu, x, coef_mat){
  row_index = which(row.names(coef_20_upper) == gu)
  coef_gu = coef_mat[row_index,]
  return(sum(coef_gu * x))
}
estimate_vlm('강남구',c(1,1,0,1,0,0,1,1,1,0,1), coef_20_upper)
estimate_vlm('강남구',c(1,1,0,1,0,0,1,1,1,0,1), coef_19_lower)
estimate_vlm('강남구',c(1,1,0,1,0,0,1,1,1,0,1), coef_19_upper)


exp(14.5) - exp(12)

save.image('/Users/shinbo/Desktop/공모전/문화관광/workspace/workspace.RData')
