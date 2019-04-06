### 메모리공간을 동적으로 사용하여 데이터 관리하기 ###
myname = readline(prompt = "enter name: ")

number = as.integer(readline(prompt = "정수의 개수를 입력해주세요"))
sum = 0
for (i in 1:number){
  sum = sum + as.integer(readline(prompt = sprintf("%s번째 정수를 입력하세요", i)))
}

sprintf("합계는 %s 입니다",sum)
sprintf("평균은 %s 입니다.",sum/number)

### 3이 나타나는 시간을 전부 합하면? ###
result = 0
for (hour in 0:23){
  for (minute in 0:59){
   if (lapply(strsplit(as.character(hour), ''), function(x) any(x == '3'))[[1]] | lapply(strsplit(as.character(minute), ''), function(x) any(x == '3'))[[1]]){
     result = result + 60 
   }
  }
}
result

### CamelCase를 Pothole_case로 바꾸기 ###

to_pothole = function(x){
  result = ''
  for (i in strsplit(x,'')[[1]]){
    if (unlist(gregexpr("[A-Z]", i)) == 1) i = paste("_",tolower(i),sep='')
    else if (! is.na(as.numeric(i))) i = paste("_",i,sep='')
    result = paste(result,i,sep='')
  }
  return(result)
}
to_pothole('numGoat30')

### Duplicate Numbers ###
# load string r package
library(stringr)

is_duplicate = function(x){
  result = c()
  for (i in 0:9){
    result = append(result,str_count(x,as.character(i)) == 1)
  }
  return(all(result))
}
is_duplicate('0123456789999')

### 가성비 최대화 ###


