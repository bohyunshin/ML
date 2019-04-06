### 완전수 구하기###
perfect_num = function(x){
  sprintf('%s 이하의 완전수를 벡터로 출력합니다.',x)
  num_per_vec = c()
  for (i in 2:x){
    num_vec = c()
    for (j in 1:(x-1)){
      if (i %% j == 0) num_vec = append(num_vec,j)
      else invisible()
    }
    if (sum(num_vec) == i) num_per_vec = append(num_per_vec,i)
    else invisible()
  }
  return(num_per_vec)
}
perfect_num(29)

### special pythagorean triplet ###
pytha = function(x){
  num_list = list()
  result = c()
  for (i in 1:500) for (j in 1:500) for (k in 1:500) if (i<j & j<k & i+j+k==1000) num_list = c(num_list,list(c(i,j,k)))
  for (i in num_list){
    if (i[1]^2 + i[2]^2 == i[3]^2){
      result = i
      break
    } 
  }
  return(result)
}
pytha(1000)

### even fibonacci numbers ###
fibo = c(1,2)
while (TRUE){
  a = fibo[length(fibo)] + fibo[length(fibo)-1]
  if (a>4000000) break
  fibo = append(fibo,a)
}
fibo_even = c()
for (i in fibo) if (i %% 2 == 0) fibo_even = append(fibo_even,i)
sum(fibo_even)

### 100까지의 자연수의 합의 제곱과 제곱의 합의 차이 ###
sum(1:100)^2 - sum((1:100)^2)

### 시저 암호 풀기 ###
cissor = function(x,n){
  text = toupper(x)
  result = ''
  for (i in strsplit(text,'')[[1]]){
    result = paste(result, LETTERS[match(i,LETTERS)+n], sep=''  )
  }
  return(result)
}
cissor('CAT',5)


