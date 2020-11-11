library(nlme)
library(lme4)
setwd('/Users/shinbo/Desktop/공모전/문화관광/data_glmm')

# glmm modeling
glmm_data_19 = read.csv('19_glmm.csv')
glmm_data_20 = read.csv('20_glmm.csv')


glmm_data_19_lower = glmm_data_19[glmm_data_19$half == 'lower',-20]
dim(glmm_data_19_lower)

# exclude missing values
glmm_data_19_lower = glmm_data_19_lower[-which(is.infinite(glmm_data_19_lower$vlm)),]
dim(glmm_data_19_lower)

n_19 = dim(glmm_data_19_lower)[1]
set.seed(1)
train_index_19 = sample(1:n_19, round(n_19*0.8), replace=FALSE)
glmm_data_19_lower_train = glmm_data_19_lower[train_index_19,]
glmm_data_19_lower_test = glmm_data_19_lower[-train_index_19,]


glmm_data_20_upper = glmm_data_20[glmm_data_20$half == 'upper',-20]
glmm_data_20_upper = glmm_data_20_upper[-which(is.infinite(glmm_data_20_upper$vlm)),]
n_20 = dim(glmm_data_20_upper)[1]
set.seed(2)
train_index_20 = sample(1:n_20, round(n_20*0.8), replace=FALSE)
glmm_data_20_upper_train = glmm_data_20_upper[train_index_20,]
glmm_data_20_upper_test = glmm_data_20_upper[-train_index_20,]


formula = vlm ~. -v3 + (other_서울+
                          category_관광쇼핑+category_교통+
                          category_미술공예참여+category_사진촬영+ category_숙박+
                          category_악기연주+category_여행사+
                          category_음악감상+category_체험| v3)

formula_full = vlm ~ other_서울 + age_30 + age_40 + age_50 + age_60 + category_관광쇼핑 + 
  category_교통 + category_미술공예참여 + category_사진촬영 + 
  category_숙박 + category_악기연주 + category_여행사 + 
  category_음악감상 + category_체험 + sex_M + weekend_WHITE + 
  activity_활동 + activity_휴식 +  (other_서울+
                                  category_관광쇼핑+category_교통+
                                  category_미술공예참여+category_사진촬영+ category_숙박+
                                  category_악기연주+category_여행사+
                                  category_음악감상+category_체험| v3)

model_19_lower = lmer(formula, data=glmm_data_19_lower_train, REML=FALSE)
model_19_lower_full = lmer(formula_full, data=glmm_data_19_lower_train, REML=FALSE)


summary(model_19_lower)
summary(rePCA(model_19_lower))

model_20_upper = lmer(formula, data=glmm_data_20_upper_train, REML=FALSE)

save.image('/Users/shinbo/Desktop/공모전/문화관광/workspace/glmm_19_lower.RData')
summary(model_19_lower)


sum((fitted(model_19_lower) - glmm_data_19_lower_train$vlm)^2) / dim(glmm_data_19_lower_train)[1]

estimate_test_vlm = function(test, model){
  n = nrow(test)
  p = ncol(test)
  coef_mat = data.frame(coef(model)[[1]])
  fitted = c()
  row_names = row.names(coef_mat)
  for (i in 1:n){
    gu = test[i,p]
  
    gu_index = which(row_names == gu)
    regression_eqn = as.vector(coef_mat[gu_index,])
    test_data = test[i, 1:(p-2)]
    test_data = c(1,unlist(test_data))
    #print(test_data)
    #print(regression_eqn)
    fitted_values = sum(regression_eqn*test_data)
    fitted = append(fitted, fitted_values)
  }
  return(fitted)
}

MSE = function(pred, y, n){
  return( sum((pred-y)^2)/n )
}
a = estimate_test_vlm(glmm_data_19_lower_test, model_19_lower)
b = estimate_test_vlm(glmm_data_20_upper_test, model_20_upper)
mat_19 = data.frame(pred=a, y = glmm_data_19_lower_test$vlm)
write.csv(mat_19, '~/Desktop/공모전/문화관광/RMSLE/seoul_19.csv')



################### estimate ###################

estimate_vlm = function(gu, x, coef_mat){
  row_index = which(row.names(coef_mat) == gu)
  coef_gu = coef_mat[row_index,]
  return(sum(coef_gu * x))
}

intercept = 1
other = 1
age = c(0,0,1,0)
category = c(rep(0,5),0,1,0,0)
sex = 1
weekend = 0
activity = c(1,0)
month = 9
x = c(intercept,other, age, category, sex, weekend, activity, month)
exp(estimate_vlm('중구',x,coef(model_19_lower)[[1]]))

c(0,0,0,1,rep(0,5))
colnames(coef(model_19_lower)[[1]])

coef(model_19_lower)[[1]]
