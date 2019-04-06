### 문자열을 제거한 뒤 숫자만 반환 ###
myfunc = function(x){
  result = c()
  for (i in unlist(strsplit(x,''))){
    if (! is.na(as.numeric(i))) result = append(result,i)
  }
  return(paste(result,collapse=''))
}
suppressWarnings(myfunc('1w627r00o00p00'))

### 숫자를 입력 받으면 그에 맞는 자릿수 출력 ###
a = readline(prompt = '숫자를 입력하세영')
sprintf('%s의 자리수입니다.',10^(nchar(a)-1))

### 평균 구하기 ###
mean()

### 중앙값 구하기 ###
median(c(1,2,3,4))

### 홀수와 짝수의 개수 구사기 ###
odd_even = function(vec){
  even = c()
  odd = c()
  for (i in vec){
    if (i %% 2 == 0) even = append(even,i)
    else odd = append(odd,i)
  }
  return(sprintf('홀수 %s개, 짝수 %s개',length(odd),length(even)))
}
odd_even(c(3,4,5,6,7))
