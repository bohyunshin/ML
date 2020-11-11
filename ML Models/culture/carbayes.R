library(raster)
setwd('/Users/shinbo/Desktop/공모전/문화관광/data')
shp_dir = '/Users/shinbo/Desktop/Statistics/etc/coordinates/SIG_201703/TL_SCCO_SIG.shp'
sigungu <- shapefile(shp_dir, encoding='euc-kr')
data = read.csv('seoul_agg_data.csv')


data_dir = '/Users/shinbo/Desktop/Statistics/etc/data/result.csv'
voting = read.csv(data_dir, fileEncoding='euc-kr')
region_seoul = voting %>% filter(Sido == '서울')
sigungu2id = list()
for (i in 1:dim(region_seoul)[1]){
  sigungu2id[[region_seoul$Sigun[i]]] = region_seoul$id[i]
}
id_seoul = unlist(sigungu2id)

spdf_seoul = sigungu[sigungu$SIG_CD %in% id_seoul, ]

# make neighboring structure
W.nb = poly2nb(spdf_seoul, row.names=spdf_seoul@data$SIG_KOR_NM)
W.list <- nb2listw(W.nb, style = "B", zero.policy=T)
W <- nb2mat(W.nb, style = "B",zero.policy=T)

colnames(W) = row.names(W)

View(W)

songpa_idx = which(colnames(W) == '송파구')
gangnam_idx = which(colnames(W) == '강남구')
gwangjin_idx = which(colnames(W) == '광진구')
gangdong_idx = which(colnames(W) == '강동구')

yongsan_idx = which(colnames(W) == '용산구')
mapo_idx = which(colnames(W) == '마포구')
joong_idx = which(colnames(W) == '중구')
seongdong_idx = which(colnames(W) == '성동구')
neighbor_idx = c(mapo_idx, joong_idx, seongdong_idx)


W[songpa_idx, gangnam_idx] = W[songpa_idx, gangnam_idx] + 1
W[songpa_idx, gwangjin_idx] = W[songpa_idx, gwangjin_idx] + 1
W[songpa_idx, gangdong_idx] = W[songpa_idx, gangdong_idx] + 1

W[gangnam_idx,songpa_idx] = W[gangnam_idx,songpa_idx] + 1 
W[gwangjin_idx, songpa_idx] = W[gwangjin_idx, songpa_idx] + 1
W[gangdong_idx, songpa_idx] = W[gangdong_idx, songpa_idx] + 1


make_W = function(W, main_idx, neighbor_idx){
  W = W
  for (idx in neighbor_idx){
    W[main_idx, idx] = W[main_idx, idx] + 1
    W[idx, main_idx] = W[idx, main_idx] + 1
  }
  return(W)
}
W = make_W(W, yongsan_idx, neighbor_idx)

chain1 <- ST.CARar(formula = y ~ . -year, family = "gaussian",
                   data = data, W = W, burnin = 20000, n.sample = 220000,
                   thin = 100)
summary(chain1$samples)

library(coda)
beta.samples <- mcmc.list(chain1$samples$beta)
plot(beta.samples)

save.image('workspaceRData')
