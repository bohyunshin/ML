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


amnrp_coord = coordinates(spTransform(amnrp, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
bird_coord = coordinates(spTransform(bird, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
fish_coord = coordinates(spTransform(fish, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
insect_coord = coordinates(spTransform(insect, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
flr_coord = coordinates(spTransform(flr, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
mml_coord = coordinates(spTransform(mml, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
bnin_coord = coordinates(spTransform(bnin, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))
tpsc_coord = coordinates(spTransform(tpsc, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))



####### using google map
library(ggmap)
library(ggplot2)
register_google(key='AIzaSyAR_GjAoBXaguhcniULpVgayu5Ph5nyrfI')
map <- get_googlemap('south seoul',
                               maptype = 'roadmap',
                               zoom = 7)
ggmap(map) + geom_point(data=data.frame(bird_coord[bird$spcs_korea == '팔색조',]), aes(x=lon, y=lat))

dir = '/Users/shinbo/Downloads/KE_SOIL_POINT/KE_SOIL_POINT.shp'
point = readOGR(dir, stringsAsFactors=FALSE)
point[which(point$MGTNO == 'ME2009E003'),]
