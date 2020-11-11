
####################################### making variables for chelsa data #######################################

#load('/Users/shinbo/Desktop/contest/environ/workspace/insect_workspace.RData')

# stack raster individually
library(raster)
list_files = list.files("/Users/shinbo/climate_data/bio/", ".tif", full.names=TRUE)
list_stacks = list()

# crop korea only to reduce computation time!
############ Caution ############
# should download korea raster ! 
# Simply loading workspace does not work
kor_area = getData('GADM',country='KOR', level=0)
for (i in 1:length(list_files)){
  list_stacks[[i]] = crop(stack(list_files[i]), kor_area)
  print(sprintf('%s finished', i))
}

# This function works for multiple stacks!
'
Input: multiple stack, coordinate to extract values
Ouput: climate value
'
extract_data_chelsa = function(list_stack, coords){
  # the steps to extract values for the variables you want from the coordinates:
  points <- SpatialPoints(coords, proj4string = list_stack[[1]]@crs)
  
  n = nrow(coords)
  m = length(list_stack)
  result = c()
  # loop for each coordinate
  for (i in 1:n){
    one_row = c()
    # loop for multiple stacks
    for (st in 1:m){
      one_row = append(one_row, extract(list_stack[[st]], points[i,]))
    }
    result = rbind(result, one_row)
  }
  return(result)
}

cal_stat_in_one_grid_chelsa = function(grid, list_stack, index){
  min_lon = min(grid[[index]]$lon)
  max_lon = max(grid[[index]]$lon)
  min_lat = min(grid[[index]]$lat)
  max_lat = max(grid[[index]]$lat)
  
  lon_grid = seq(min_lon, max_lon, length.out = 10)
  lat_grid = seq(min_lat, max_lat, length.out = 10)

  coords_in_one_grid = c()
  for (lon in lon_grid){
    for (lat in lat_grid){
      coords_in_one_grid = rbind(coords_in_one_grid, c(lon, lat))
    }
  }
  
  coords_in_one_grid = data.frame(coords_in_one_grid)
  colnames(coords_in_one_grid) = c('lon','lat')
  
  temp = extract_data_chelsa(list_stack, coords_in_one_grid)
  return(apply(temp, 2, function(x) mean(x, na.rm=TRUE)))
}

uq_bando = unique(index_grid_bando)
uq_jeju = unique(index_grid_jeju)
X_bando_ch = c()
X_jeju_ch = c()
a = 1
for (index in uq_bando){
  tmp =  cal_stat_in_one_grid_chelsa(grid_bando, list_stacks, index)
  X_bando_ch = rbind(X_bando_ch, tmp)
  print(sprintf('%s finished', a))
  a = a+1
}

a = 1
for (index in uq_jeju){
  tmp =  cal_stat_in_one_grid_chelsa(grid_jeju, list_stacks, index)
  X_jeju_ch = rbind(X_jeju_ch, tmp)
  print(sprintf('%s finished', a))
  a = a+1
}

concat_data = rbind.data.frame(X_bando_ch, X_jeju_ch)
rownames(concat_data) = NULL
colnames(concat_data) = paste('bio',1:19,sep='')
concat_data$index_grid = as.integer(c(uq_bando, uq_jeju))
concat_data$region = c(rep('b',length(uq_bando)), rep('j', length(uq_jeju)))

save.image('/Users/shinbo/Desktop/contest/environ/workspace/chelsa_bio.RData')
setwd('~/desktop/contest/environ/script_bnin')
write.csv(concat_data, '../concat_data/variables/flr/chelsa_bio.csv', row.names=F)

