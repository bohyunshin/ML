library(raster)
library(ggplot2)
library(rgeos)
library(viridis)
library(dplyr)

shp_dir = '/Users/shinbo/Desktop/Statistics/etc/coordinates/SIG_201703/TL_SCCO_SIG.shp'
sigungu <- shapefile(shp_dir, encoding='euc-kr')

data_dir = '/Users/shinbo/Desktop/공모전/문화관광/data_agg/seoul_20.csv'
seoul_20 = read.csv(data_dir)
data_dir = '/Users/shinbo/Desktop/공모전/문화관광/data_agg/seoul_19.csv'
seoul_19 = read.csv(data_dir)
data_dir = '/Users/shinbo/Desktop/공모전/문화관광/data_agg/daej_20.csv'
dae_20 = read.csv(data_dir)
data_dir = '/Users/shinbo/Desktop/공모전/문화관광/data_agg/daej_19.csv'
dae_19 = read.csv(data_dir)

# to make sigungu2id!!!
data_dir = '/Users/shinbo/Desktop/Statistics/etc/data/result.csv'
voting = read.csv(data_dir, fileEncoding='euc-kr')
seoul = voting %>% filter(Sido == '서울')
dae = voting %>% filter(Sido == '대전')

seoulgu2id = list()
daegu2id = list()

for (i in 1:nrow(seoul)){
  seoulgu2id[[seoul$Sigun[i]]] = seoul$id[i]
}

for (i in 1:nrow(dae)){
  daegu2id[[dae$Sigun[[i]]]] = dae$id[i]
}

seoul_sp = sigungu[ sigungu$SIG_CD %in% unlist(seoulgu2id), ]
dae_sp = sigungu[ sigungu$SIG_CD %in% unlist(daegu2id), ]

seoul_sp_fortify = fortify(seoul_sp, region="SIG_CD")
dae_sp_fortify = fortify(dae_sp, region="SIG_CD")

range_seoul = c(range(log(seoul_20$vlm)), range(log(seoul_19$vlm)))
range_dae = c(range(log(dae_20$vlm)), range(log(dae_19$vlm)))

make_map = function(seoul_20, seoulgu2id, seoul_sp_fortify,name, range){
  a = c()
  for (i in 1:nrow(seoul_20)){
    tmp = seoulgu2id[[ seoul_20$v3[i]  ]]
    a[i] = tmp
  }
  seoul_20$id = a
  seoul_20$log_vlm = log(seoul_20$vlm) 
  seoul_20_merge = merge(seoul_sp_fortify, seoul_20, by='id')
  
  
  p = ggplot() + geom_polygon(data=seoul_20_merge, aes(x=long, y=lat, group=group, fill=log_vlm))
  p = p  + scale_fill_gradient(low='white', high='#004ea2', limits = c(min(range), max(range)) ) + theme_void() + guides(fill=F)
  ggsave(name)
  
}

make_map(seoul_19, seoulgu2id, seoul_sp_fortify,'/Users/shinbo/Desktop/공모전/문화관광/image/seoul_19_.png',range_seoul)
make_map(seoul_20, seoulgu2id, seoul_sp_fortify, '/Users/shinbo/Desktop/공모전/문화관광/image/seoul_20_.png',range_seoul)
make_map(dae_19, daegu2id, dae_sp_fortify, '/Users/shinbo/Desktop/공모전/문화관광/image/dae_19_.png',range_dae)
make_map(dae_20, daegu2id, dae_sp_fortify, '/Users/shinbo/Desktop/공모전/문화관광/image/dae_20_.png',range_dae)


################################################################################


sigungu_fortify = fortify(sigungu, region="SIG_CD")

# corresponding sigungu

sejong_idx = which(payment$v3 == '.')
payment[sejong_idx, 2] = '세종특별자치시'
specific = setdiff(sigungu$SIG_KOR_NM, payment$v3)

si = c()
for (i in specific){
  si = append(si, substr(i, start=1, stop=3))
}

sigungu2payment = list()
for (s in 1:length(payment$v3)){
  sigungu2payment[[ payment$v3[s] ]] = c(payment$lower[s], payment$upper[s])
}

temp = c()

for (s in si){
  temp = rbind(temp, sigungu2payment[[s]])
}

concat_df = as.data.frame(cbind(si, specific, temp))

idx = ! payment$v3 %in% c('수원시','성남시','안양시','고양시','용인시','청주시','천안시',
                          '전주시','포항시','창원시')
payment = payment[idx,]
colnames(concat_df) = colnames(payment)

final_df = rbind(payment, concat_df)
final_df


# to make sigungu2id!!!
data_dir = '/Users/shinbo/Desktop/Statistics/etc/data/result.csv'
voting = read.csv(data_dir, fileEncoding='euc-kr')

convert_name = function(x){
  if (x %in% c('수원시','성남시','안양시','안산시','고양시','용인시')) return('경기')
  else if (x == '천안시') return('충남')
  else if (x == '청주시') return('충북')
  else if (x == '전주시') return('전북')
  else if (x == '창원시') return('경남')
  else if (x == '포항시') return('경북')
  
  return(x)
}

final_df$v2 = unlist(sapply(final_df$v2, convert_name))
final_df$v3 = unlist(sapply(final_df$v3, function(x) gsub(" ", "", x, fixed=TRUE)))
dim(final_df)

sigungu2id = list()
for (s in 1:dim(voting)[1]){
  sigungu2id[[ paste(voting$Sido[s], voting$Sigun[s]) ]] = voting$id[s]
}


sigungu[sigungu$SIG_KOR_NM == '철원군',]
sigungu2id[['강원 철원군']] = 42780


id = c()
key = paste(final_df$v2, final_df$v3)

# 안산시하고 미추홀구는 제외한다.
setdiff(key, names(sigungu2id))
final_df = final_df[which(key %in% names(sigungu2id)), ]

for (s in 1:dim(final_df)[1]){
 id = append(id, sigungu2id[[ key[s] ]]) 
}
# 인천 남구가 빈다.
# 근데 얘는 애초에 payment 데이터에서도 없었음.
setdiff(sigungu$SIG_CD, id)
sigungu[sigungu$SIG_CD == '28170',]
final_df$id = id


payment_merge = merge(sigungu_fortify, final_df, by='id')
payment_merge$upper = log(as.numeric(payment_merge$upper))
payment_merge$lower = log(as.numeric(payment_merge$lower))

p_lower = ggplot() + geom_polygon(data=payment_merge, aes(x=long, y=lat, group=group, fill=lower))
p_upper = ggplot() + geom_polygon(data=payment_merge, aes(x=long, y=lat, group=group, fill=upper))
p_lower  + scale_fill_gradient(low='white', high='#004ea2') + theme_void() + guides(fill=F)
p_upper  + scale_fill_gradient(low='white', high='#004ea2') + theme_void() + guides(fill=F)
