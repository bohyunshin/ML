### printing OXs ###
printing_ox = function(x){
  for (i in 1:as.integer(x)){
    a = paste(rep('0',x-i),collapse='')
    b = paste(rep('X',i),collapse='')
    print(paste(a,b,sep=''))
  }
}
printing_ox(6)

### 버전 비교 ###
compare_version = function(x,y){
  a = 0
  x_split = strsplit(x,'[.]')[[1]]
  y_split = strsplit(y,'[.]')[[1]]
  if (length(x_split) == 2) append(x_split,'0')
  if (length(y_split) == 2) append(y_split,'0')
  for (i in 1:3){
    if (as.integer(x_split[i]) > as.integer(y_split[i])){
      
      a = 1
      return(print(paste(x,' > ',y,sep='')))
    }
    else if (as.integer(x_split[i]) > as.integer(y_split[i])){
      
      a = 1
      return(print(paste(x,' < ',y,sep='')))
    }
  }
  if (a==0) print('둘의 버전은 같습니다.')
}
compare_version('1.2.10','1.0.10000')


### 1~1000에서 각 숫자의 개수 구하기
a = c()
b = c()
for (i in 1:1000){
  for (j in strsplit(as.character(i),'')[[1]]){
    a = append(a,j)
  }
}
# 개수 print하기
for (i in 0:9){
  sprintf('%s의 개수는 %s개 입니다.',i,sum(a == str(i)))
}

### 10~1000까지 각 숫자 분해하여 곱하기의 전체 합 구하기###

prod_vec = c()
composition_num_list = c()
for (i in 10:1000){
  for (j in strsplit(as.character(i),'')[[1]]){
    composition_num_list = append(composition_num_list,j)
  }
  prod_vec = append(prod_vec,eval(parse(text=paste(composition_num_list,collapse='*'))))
  composition_num_list = c()
}
sum(prod_vec)

### Dash Insert ###

dash_insert = function(x){
  result = ''
  for (i in 1:nchar(x)){
    if (as.integer(substr(x,i,i)) %% 2 == 1 & as.integer(substr(x,i+1,i+1)) %% 2 == 1) result = paste(result,substr(x,i,i),'-',sep='')
    else if (as.integer(substr(x,i,i)) %% 2 == 0 & as.integer(substr(x,i+1,i+1)) %% 2 == 0) result = paste(result,substr(x,i,i),'*',sep='')
    else result = paste(result,substr(x,i,i),sep='')
    if (i+1 == nchar(x)) break
  }
  return(paste(result,substr(x,nchar(x),nchar(x)),sep=''))
}
dash_insert('4546793')




