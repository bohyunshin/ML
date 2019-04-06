### multiples of 3 and 5 ###
result = 0
for (i in 1:999){
  if (i %% 3 ==0 | i %% 5 == 0) {result = result+i}
}
print(result)

### 탭을 공백 문자로 바꾸기 ###
#현재 디렉토리가 파일이 위치한 곳이라고 가정
setwd("C:/Users/sbh0613/Desktop/source")
#string을 담은 벡터를 구분자는 sep으로 해서 하나의 이어진 string으로 
#반환하는 함수
vec_to_string = function(vec,sep){
  string = ""
  for (i in 1:length(vec)){
    if (i==1) string = paste(string,vec[1],sep='')
    else string = paste(string,vec[i],sep=sep)
  }
  return(string)
}


tab_to_4_space = function(file_name){
  lines = readLines(file_name)
  split_by_tab = strsplit(lines,'\t')
  fileconn = file("to4space.txt","w")
  for (i in 1:length(lines)){
    write(vec_to_string(split_by_tab[[i]],sep='    '),fileconn,append=T)
  }
  close(fileconn)
}
tab_to_4_space('text.txt')

### 게시판 페이징 ###

totalpage = function(m,n){
  if (n<=0) print('한페이지에 보여줄 게시물수는 1이상이어야 합니당')
  else if (m %% n == 0) return(m%/%n)
  else if (m %% n != 0) return(m%/%n + 1)
}

### special sort ###

special_sort = function(int_vec){
  post_vec = c()
  neg_vec = c()
  zero_vec = c()
  for (i in int_vec){
    if (i>0) post_vec = append(post_vec,i)
    else if (i<0) neg_vec = append(neg_vec,i)
    else zero_vec = append(zero_vec,i)
  }
  return(c(neg_vec,zero_vec,post_vec))
}

special_sort(c(-1,1,3,-2,2))

### the knights of the round table ###
#헤론의 공식을 써서 일반적인 삼각형의 넓이를 구한다.
get_radius = function(a,b,c){
  s = (a+b+c)/2
  area = sqrt(s*(s-a)*(s-b)*(s-c))
  radius = area * 2 / (a+b+c)
  return(round(radius,3))
}
get_radius(12,12,8)




