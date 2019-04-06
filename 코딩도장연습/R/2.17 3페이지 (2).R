### 자리수 출력하기 ###
myfunc = function(x){
  return(sprintf('%s자리수입니다.',nchar(as.character(x))))
}
myfunc(78288989)

### 공백을 제외한 글자수 세기 ###
count_num = function(x){
  a = paste(unlist(strsplit(x,' ')),collapse='')
  b = paste(unlist(strsplit(a,'\n')),collapse='')
  return(sprintf('%s자리 입니다.',nchar(b)))
}
a = '공백을 제외한\n글자수만을 세는 코드 테스트'
count_num(a)

### 자신을 제외한 곱셈 ###
multi = function(vec){
  result = c()
  for (i in 1:length(vec)){
    temp = vec[-i]
    result = append(result,prod(temp))
  }
  return(result)
}
multi(c(2,6,4,7))

### 농장 분할 ###
gcd <- function(x,y) {
  r <- x%%y;
  return(ifelse(r, gcd(y, r), y))
}

division_farm = function(n,m){
  print((n*m) %/% (as.numeric(gcd(m,n))^2))
}
division_farm(1980,640)

### 문자에 해당하는 아스키코드를 알아내는 코드 ###

asci = function(){
  library('gtools')
  alphabet = readline(prompt = '아스키코드를 알고 싶은 알파벳을 입력하세요: ')
  return(asc(alphabet))
}
asci()

