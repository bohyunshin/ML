library(leaflet)
setwd('~/desktop/contest/environ/script')
load('../workspace/base_workspace.RData')
load('../workspace/bird_etc.RData')

# finding prediction grid using leaflet
sel_data = data.frame(lon=127, lat=35)
colnames(bird_coord) = c('lon','lat')
leaflet() %>%
  setView(lng=128, lat=35, zoom=8) %>%
  addTiles() %>% addCircles(~lon, ~lat, data=data.frame(bird_coord), color='green') %>%
  addRectangles(lng1=127, lat1=37.7,
                lng2=128.7, lat2=38.2,
                fillOpacity=0.2, opacity = 0.2) %>%
  addRectangles(lng1=127.9, lat1=37.2,
                lng2=129, lat2=37.6,
                fillOpacity=0.2, opacity = 0.2) %>%
  addRectangles(lng1=127.7, lat1=36.4,
                lng2=129, lat2=37,
                fillOpacity=0.2, opacity = 0.2)%>%
  addRectangles(lng1=127, lat1=35,
                lng2=128.5, lat2=35.8,
                fillOpacity=0.2, opacity = 0.2) 

pred_top_grid = make_grid(127, 37.7, 128.7, 38.2)
pred_middle1_grid = make_grid(127.9, 37.2, 129, 37.6)
pred_middle2_grid = make_grid(127.7, 36.4, 129, 37)
pred_bottom_grid = make_grid(127, 35, 128.5, 35.8)
Incheon = make_grid(126.6, 37.4, 126.8, 37.6)

leaflet() %>%
  setView(lng=128, lat=35, zoom=6) %>%
  addTiles() %>%
  addRectangles(lng1=126.1, lat1=34.2,
                lng2=129.5, lat2=38.2,
                fillOpacity=0.1, opacity = 0.05)


grid_list = list(top = pred_top_grid, middle1 = pred_middle1_grid, middle2 = pred_middle2_grid, bottom = pred_bottom_grid)

'
Input: multiple grid lists for prediction
Output: leaflet incluindg rectangle grids
'
make_leaflet_bando_grid_multiple = function(grid_list, initial_point){
  leaflet_ = leaflet() %>%
    setView(lng=initial_point[1], lat=initial_point[2], zoom=9) %>%
    addTiles()
  
  for (lst in grid_list){
    for (i in 1:length(lst)){
      leaflet_ = leaflet_ %>%
        addRectangles(lng1=min(lst[[i]]$lon), lat1=min(lst[[i]]$lat),
                      lng2=max(lst[[i]]$lon), lat2=max(lst[[i]]$lat),
                      fillOpacity=0.2, opacity = 0.2)
    }
  }
  return(leaflet_)
}
pred_grid_leaflet = make_leaflet_bando_grid_multiple(grid_list, c(128, 35))
pred_grid_leaflet


#################################### make bio variables for pred_grid################################################

# stack raster individually
library(raster)
list_files = list.files("/Users/shinbo/climate_data/bio/", ".tif", full.names=TRUE)
list_stacks = list()

# crop korea only to reduce computation time!
######## AGAIN CAUTION ########
# We should download from local
# Simply loading workspace would not work
kor_area = getData('GADM',country='KOR', level=0)
for (i in 1:length(list_files)){
  list_stacks[[i]] = crop(stack(list_files[i]), kor_area)
  print(sprintf('%s finished', i))
}

extract_data_chelsa = function(list_stack, coords, multiple=T){
  # the steps to extract values for the variables you want from the coordinates:
  points <- SpatialPoints(coords, proj4string = list_stack[[1]]@crs)
  
  n = nrow(coords)
  m = length(list_stack)
  result = c()
  for (i in 1:n){
    one_row = c()
    if (multiple){
      for (st in 1:m){
        one_row = append(one_row, extract(list_stack[[st]], points[i,]))
      }
    }
    else{
      one_row = append(one_row, extract(list_stack, points[i,]))
    }
    result = rbind(result, one_row)
  }
  return(result)
}

cal_stat_in_one_grid_chelsa = function(grid, list_stack, index, multiple){
  min_lon = min(grid[[index]]$lon)
  max_lon = max(grid[[index]]$lon)
  min_lat = min(grid[[index]]$lat)
  max_lat = max(grid[[index]]$lat)
  
  lon_grid = seq(min_lon, max_lon, length.out = 5)
  lat_grid = seq(min_lat, max_lat, length.out = 5)
  
  coords_in_one_grid = c()
  for (lon in lon_grid){
    for (lat in lat_grid){
      coords_in_one_grid = rbind(coords_in_one_grid, c(lon, lat))
    }
  }
  
  coords_in_one_grid = data.frame(coords_in_one_grid)
  colnames(coords_in_one_grid) = c('lon','lat')
  
  temp = extract_data_chelsa(list_stack, coords_in_one_grid, multiple = multiple)
  if (multiple) return(apply(temp, 2, function(x) mean(x, na.rm=TRUE)))
  else return(mean(temp))
}

## for bando
## this takes huge time if number of list is many
X_bando_ch = c()
a = 1
for (lst in grid_list){
  n = length(lst)
  for (index in 1:n){
    tmp =  cal_stat_in_one_grid_chelsa(lst, list_stacks, index, multiple=T)
    X_bando_ch = rbind(X_bando_ch, tmp)
    print(sprintf('%s finished out of %s',index,n))
  }
  save.image('../workspace/making_pred_grid.RData')
}


## for incheon
incheon_ch = c()
a = 1
n = length(Incheon)
for (index in 1:n){
  tmp =  cal_stat_in_one_grid_chelsa(Incheon, list_stacks, index, multiple=F)
  incheon_ch = rbind(incheon_ch, tmp)
  print(sprintf('%s finished out of %s',index,n))
}
incheon_ch = data.frame(incheon_ch)
rownames(incheon_ch) = NULL
colnames(incheon_ch) = c(paste('bio',1:19,sep=''))

write.csv(incheon_ch, '../concat_data/pred_grid/inch_bio.csv')


#################################### make etc variables for pred_grid################################################
######### AGAIN NOTE FOR ETC VARIABLE #########
'
files should be downloaded by executing make_stacks function
Just loading workspace is not enough to extract data frmo CHELSA
After downloading data, concatenate list again to a single list
'
make_stacks = function(list_files_, kor_area, name_){
  result = crop(stack(list_files_), kor_area)
  names(result) = paste(name_,1:12, sep='_')
  return(result)
}

list_files_pet = list.files("~/climate_data/pet", ".tif", full.names=TRUE)
list_files_rh = list.files("~/climate_data/rh", ".tif", full.names=TRUE)
list_files_srad = list.files("~/climate_data/srad", ".tif", full.names=TRUE)
stacks_pet = make_stacks(list_files_pet, kor_area, 'pet')
stacks_rh = make_stacks(list_files_rh, kor_area, 'rh')
stacks_srad = make_stacks(list_files_srad, kor_area, 'srad')
list_month = c(stacks_pet, stacks_rh, stacks_srad)

## for multiple grid lists
X_bando_ch_month = c()
grid_name = names(grid_list)
m = length(list_month)
a = 1
for (grid in grid_list){
  n = length(grid)
  for (index in 1:n){
    one_row = c()
    for (lst in 1:m){
      tmp =  cal_stat_in_one_grid_chelsa(grid, list_month[[lst]] , index, multiple=F)
      one_row = append(one_row, tmp)
    }
    X_bando_ch_month = rbind(X_bando_ch_month, one_row)
    print(sprintf('%s finished out of %s', index,n))
  }
  a = a+1
}

## for incheon
X_incheon_month = c()
m = length(list_month)
n = length(Incheon)
for (index in 1:n){
  one_row = c()
  for (lst in 1:m){
    tmp =  cal_stat_in_one_grid_chelsa(Incheon, list_month[[lst]] , index, multiple=F)
    one_row = append(one_row, tmp)
  }
  X_incheon_month = rbind(X_incheon_month, one_row)
  print(sprintf('%s finished out of %s', index,n))
}

X_incheon_month = data.frame(X_incheon_month)
rownames(X_incheon_month) = NULL
colnames(X_incheon_month) = c('pet','rh','srad')
write.csv(X_incheon_month,  '../concat_data/pred_grid/inch_etc.csv')
write.csv(cbind.data.frame(incheon_ch, X_incheon_month), '../concat_data/pred_grid/inch_final.csv', row.names=F)

X_bando_ch_month = data.frame(X_bando_ch_month)
rownames(X_bando_ch_month) = NULL
colnames(X_bando_ch_month) = c('pet','rh','srad')
location = c(rep('top', length(pred_top_grid)), rep('middle1', length(pred_middle1_grid)), 
             rep('middle2', length(pred_middle2_grid)), rep('bottom', length(pred_bottom_grid)))
grid_index = c(1:length(pred_top_grid), 1:length(pred_middle1_grid), 1:length(pred_middle2_grid), 1:length(pred_bottom_grid))
X_bando_ch_month$location = location
X_bando_ch_month$grid_index = grid_index
write.csv(X_bando_ch_month, '../concat_data/pred_grid/etc.csv')


#################################### concat pred grid data ################################################
bio = read.csv('../concat_data/pred_grid/bio.csv')
etc = read.csv('../concat_data/pred_grid/etc.csv')

concat_data = 
  cbind.data.frame(
    subset(bio, select=-c(X, location, grid_index)),
    subset(etc, select=-c(X, location, grid_index)),
    subset(bio, select=c(location, grid_index))
  )
na_index = c()
for (i in 1:ncol(concat_data)){
  na_index = append(na_index, which(is.na(concat_data[,i]))  )
}
na_index = unique(na_index)
concat_data = concat_data[-na_index, ]
write.csv(concat_data, '../concat_data/pred_grid/final_test_data.csv', row.names=F)
#################################### prediction value on pred_grid ################################################
