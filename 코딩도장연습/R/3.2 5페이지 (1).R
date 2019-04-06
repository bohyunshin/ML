### 구글 입사문제 중에서 ###
library(stringr)
vec = c()
for (i in 1:10000) vec = append(vec,str_count(as.character(i),pattern='8'))
sum(vec)

### Primary Arithmetic ###
carry_op= function(x,y){
  x = as.character(x)
  y = as.character(y)
  if (nchar(x) > nchar(y)) y = paste(paste(rep('0',nchar(x)-nchar(y)),collapse = ''),y,sep='')
  else if (nchar(y) > nchar(x)) x = paste(paste(rep('0',nchar(y)-nchar(x)),collapse=''),x,sep='')
  a = 0
  carry = 0
  for (i in 1:nchar(x)){
    if (a + as.integer(substr(x,nchar(x)+1-i,nchar(x)+1-i)) + as.integer(substr(y,nchar(y)+1-i,nchar(y)+1-i))>=10){
      a = 1
      carry = carry + 1
    }
    else a = 0
  }
  sprintf('%s carry operations',carry)
}

### 리스트 회전 ###
tornado = function(x){
  a = as.integer(x[1])
  x = x[-1]
  if (a>0) return(append(rev(rev(x)[1:a]), rev(rev(x)[a+1:length(x)])))
  else if (a<0) return(append(x[abs(a)+1:length(x)],x[1:abs(a)]))
  else return(x)
}
na.omit(tornado(c(4,'a','b','c','d','e','f','g')))

### 다음 입사문제 중에서 ###
min_distance = function(x){
  library(gtools)
  pairs_df = combinations(length(x),2,x)
  distance_vec = c()
  for (i in 1:nrow(pairs_df)) distance_vec = append(distance_vec,abs(pairs_df[i,][1]-pairs_df[i,][2]))
  print(pairs_df[which.min(distance_vec),])
}
min_distance(c(1,3,4,8,13,17,20))

