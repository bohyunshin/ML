### 2진법으로 자연수 나타내기 ###
to_2_digit = function(x){
  r = 0
  q = 0
  result = ''
  while (TRUE){
    r = x %%2
    q = x %/%2
    if (r == 1) result = paste0('1',result)
    else result = paste0('0',result)
    if (q == 1) {
      result = paste0('1',result)
      return(result)
      break
    }
  x = q
  }
}
to_2_digit(73)

### palindrome ###
# 두 수의 곱을 행렬로 표현함.
aa <- matrix(ncol=900, nrow=900)
x <- 100:999
y <- 100:999
for(i in 1:900) { aa[i,] <- x*y[i] }

same = function(n){
  n = as.character(n)
  string_vec = unlist(strsplit(n,""))
  result = c()
  for (i in 1:length(string_vec)) result[i] = (string_vec[i] == string_vec[length(string_vec)+1-i])
  return(all(result))
}

aa1 = aa[sapply(aa,same) == 1]
max(aa1)

### 이차방정식 ###
equal = function(a,b,c){
  if (b^2-4*a*c<0){
    return(print("해가 없습니다."))
  }
  x1 = round((-b+sqrt(b^2-4*a*c))/(2*a))
  x2 = round((-b-sqrt(b^2-4*a*c))/(2*a))
  if (b^2-4*a*c == 0) sprintf('해는 %s으로 중근입니다',x1)
  if (b^2-4*a*c > 0) sprintf('해는 %s와 %s으로 서로 다른 두 근을 가집니다.',x1,x2)
}

### 1부터 20사이의 어떤 수로도 나누어 떨어지는 가장 작은 수 ###


### 어느 숫자가 중간값? ###
median_num = function(a,b,c){
  vec_num = c(a,b,c)
  vec_num = sort(vec_num)
  return(vec_num[2])
}
median_num(6,8,1)



