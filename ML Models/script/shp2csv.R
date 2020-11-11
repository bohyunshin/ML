library(raster)
library(ggplot2)
library(rgeos)
library(viridis)
library(dplyr)

shp_amnrp = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_amnrp/tbl_ntee_amnrp.shp'
shp_birds = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_birds/tbl_ntee_birds.shp'
shp_fishes = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_fishes'
shp_insect = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_insect'
shp_flr = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_flr'
shp_mml = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_mml'
shp_bnin = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_bnin'
shp_vtn = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_vtn'
shp_tpsc = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_tpsc/tbl_ntee_tpsc.shp' # 지질 정보
shp_sonamoo = '/Users/shinbo/Desktop/contest/environ/sonamoo/TB_FGDI_IM5000_11.shp'


shp_point = '/Users/shinbo/Desktop/contest/environ/KE_FLORAFAUNA_POINT'

library(sp)
library(rgdal)
library(foreign)

amnrp = readOGR(shp_amnrp, stringsAsFactors=FALSE)
bird = readOGR(shp_birds, stringsAsFactors=FALSE)
fish = readOGR(shp_fishes, stringsAsFactors=FALSE)
insect = readOGR(shp_insect, stringsAsFactors=FALSE)
flr = readOGR(shp_flr, stringsAsFactors=FALSE)
mml = readOGR(shp_mml, stringsAsFactors=FALSE)
bnin = readOGR(shp_bnin, stringsAsFactors=FALSE)
tpsc = readOGR(shp_tpsc, stringsAsFactors=FALSE)
#sonamoo = readOGR(shp_sonamoo, stringsAsFactors=FALSE)
dim(amnrp)
dim(bird)
dim(fish)

sort(table(fish$spcs_korea))

dim(flr)
sort(table(bird$spcs_korea), decreasing=T)
dim(mml)
dim(bnin)
dim(tpsc)
head(insect)
sort(table(insect$fml_korean), decreasing=T)
sort(table(bnin$spcs_korea),decreasing = T)
sort(table(amnrp$spcs_korea))
sort(table(amnrp$spcs_korea), decreasing=T)[1:10]
head(flr@coords)
head(flr_coord)
head(bird@coords)
head(bird_coord)
head(fish@coords)
head(bnin@coords)
head(bnin)

amnrp_coord = coordinates(spTransform(amnrp, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
bird_coord = coordinates(spTransform(bird, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
fish_coord = coordinates(spTransform(fish, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
insect_coord = coordinates(spTransform(insect, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
flr_coord = coordinates(spTransform(flr, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
mml_coord = coordinates(spTransform(mml, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
bnin_coord = coordinates(spTransform(bnin, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
tpsc_coord = coordinates(spTransform(tpsc, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
#sonamoo_coord = coordinates(spTransform(sonamoo, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))

insect@coords

# check for species 적색목록
specs = read.csv('../concat_data/species.csv', fileEncoding = 'euc-kr')

map_specs_category = function(data){
  spec = unique(data$spcs_korea)
  result = data.frame()
  for (s in spec){
    temp = which(specs$국명 == s)
    if (! is.null(temp)){
      result = rbind.data.frame(result, specs[temp,])
    }
  }
  return(result)
}

bird_cat = map_specs_category(bird)
flr_cat = map_specs_category(flr)
bnin_cat = map_specs_category(bnin)
insect_cat = map_specs_category(insect)
concat_category = rbind.data.frame(bird_cat, flr_cat, bnin_cat, insect_cat)

write.csv(concat_category, '../concat_data/species_concat.csv')

save.image('../workspace/base_workspace.RData')
