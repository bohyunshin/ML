### 삼각형 구별하기 ###
triangle = function(vec){
  if (length(vec) != 3) return(print('3개의 각을 입력하세요.'))
  if (any(vec == 0)) return(print('0보다 큰 각을 입력하세요.'))
  if (sum(vec) != 180) return(print('세 각의 합은 180도이어야 합니다.'))
  vec = sort(vec)
  if (all(vec<90)) return(print('예각삼각형'))
  else if (vec[2] == 90) return(print('직각삼각형'))
  else if (vec[3] > 90) return(print('둔각삼각ㅎ'))
}
triangle(c(60,60,70,1))

### 각 자리수의 합을 구할 수 있나요? ###
myfunc = function(x){
  result = eval(parse(text=paste(unlist(strsplit(as.character(x),'')),collapse='+')))
  return(result)
}

### MVP를 찾아라 ###
a = '1/6/3,5/6/2,5/1/4,6/3/2,4/5/7,4/3/2,1/4/6,5/1/4,6/4/1,4/5/1'
b = c('Q','P','Q','O','P','T','Q','D','Q','Q')
c = c('W','W','W','W','W','L','L','L','L','L')
mvp = function(kda,kill,victory){
  player = c('a1','a2','a3','a4','a5','b1','b2','b3','b4','b5')
  kda_list = list()
  temp = strsplit(unlist(strsplit(kda,',')),'/')
  mvp_score = c()
  for (i in temp) mvp_score = append(mvp_score,
                                     (as.integer(i[1])*2 + as.integer(i[3]))/as.integer(i[2])
                                                )
  list_kill = list('P'=5,'Q'=4,'T'=3,'D'=2,'O'=1)
  kill_score = c()
  for (k in kill) kill_score = append(kill_score,list_kill[k])
  names(kill_score) = NULL
  kill_score = unlist(kill_score)
  list_gameresult = list('W'=1,'L'=0)
  vict_score = c()
  for (k in victory) vict_score = append(vict_score,list_gameresult[k])
  names(vict_score) = NULL
  vict_score = unlist(vict_score)
  final_score = mvp_score + kill_score + vict_score
  return(player[which.max(final_score)])
}
mvp(a,b,c)

### 넥슨 입사문제 중에서 ###
d = function(n){
  return( eval(parse(text=paste(unlist(strsplit(as.character(n),'')),collapse='+'))) + n )
}
a = c()
for (i in 1:5000) a[i] = d(i)
b = c()
for (i in 1:5000) if (! i %in% a) b = append(b,i)
sum(b)
