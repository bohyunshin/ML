load('/Users/shinbo/Desktop/contest/environ/workspace/base_workspace.RData')

# stack raster individually
library(raster)
list_files_fr = c(
  '~/climate_data/frost/CHELSA_fcf_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_fcf_dt_max_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_fcf_dt_mean_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_fcf_tmin_mean_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_fcf_tmin_min_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_nfd_1979-2013_V1.2.tif',
  '~/climate_data/frost/CHELSA_shc_5_1979-2013.tif'
)

make_stacks = function(list_files_, kor_area, name_){
  result = crop(stack(list_files_), kor_area)
  names(result) = paste(name_,1:12, sep='_')
  return(result)
}


# variables divded by 12 months
list_files_pet = list.files("~/climate_data/pet", ".tif", full.names=TRUE)
list_files_rh = list.files("~/climate_data/rh", ".tif", full.names=TRUE)
list_files_sdif = list.files("~/climate_data/sdif", ".tif", full.names=TRUE)
list_files_sdir = list.files("~/climate_data/sdir", ".tif", full.names=TRUE)
list_files_srad = list.files("~/climate_data/srad", ".tif", full.names=TRUE)
list_files_stot = list.files("~/climate_data/stot", ".tif", full.names=TRUE)

stacks_pet = make_stacks(list_files_pet, kor_area, 'pet')
stacks_rh = make_stacks(list_files_rh, kor_area, 'rh')
stacks_sdif = make_stacks(list_files_sdif, kor_area, 'sdif')
stacks_sdir = make_stacks(list_files_sdir, kor_area, 'sdir')
stacks_srad = make_stacks(list_files_srad, kor_area, 'srad')
stacks_stot = make_stacks(list_files_stot, kor_area, 'stot')

####################################### making variables for chelsa data #######################################
# for fcf related variables, nfd, shc
# thery are aggregated  variables

# crop korea only to reduce computation time!
kor_area = getData('GADM',country='KOR', level=0)
list_stacks_fr = list()
for (i in 1:length(list_files_fr)){
  list_stacks_fr[[i]] = crop(stack(list_files_fr[i]), kor_area)
  print(sprintf('%s finished', i))
}
fr_name = c('fcf','fcf_dt_max','fcf_dt_mean','ftf_tmin_mean','fcf_tmin_min','nfd','shc')
for (i in 1:length(list_stacks_fr)){
  names(list_stacks_fr[[i]]) = fr_name[i]
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



uq_bando = unique(index_grid_bando)
uq_jeju = unique(index_grid_jeju)
X_bando_ch = c()
X_jeju_ch = c()
a = 1
for (index in uq_bando){
  tmp =  cal_stat_in_one_grid_chelsa(grid_bando, list_stacks_fr, index)
  X_bando_ch = rbind(X_bando_ch, tmp)
  print(sprintf('%s finished', a))
  a = a+1
}
X_bando_ch = data.frame(X_bando_ch)
rownames(X_bando_ch) = NULL
colnames(X_bando_ch) = fr_name
head(X_bando_ch)

a = 1
for (index in uq_jeju){
  tmp =  cal_stat_in_one_grid_chelsa(grid_jeju, list_stacks_fr, index)
  X_jeju_ch = rbind(X_jeju_ch, tmp)
  print(sprintf('%s finished', a))
  a = a+1
}
X_bando_ch


X_jeju_ch = data.frame(X_jeju_ch)
rownames(X_jeju_ch) = NULL
colnames(X_jeju_ch) = fr_name
head(X_jeju_ch)
X_jeju_ch



####################################### making variables for chelsa data #######################################
# pet, rh, srad
# thery are monthly aggregated variables

stacks_pet
stacks_rh
stacks_srad
list_month = c(stacks_pet, stacks_rh, stacks_srad)

list_month


X_bando_ch_month = c()
X_jeju_ch_month = c()
m = length(list_month)
a = 1
for (index in uq_bando){
  one_row = c()
  for (lst in 1:m){
    tmp =  cal_stat_in_one_grid_chelsa(grid_bando, list_month[[lst]] , index, multiple=F)
    one_row = append(one_row, tmp)
  }
  X_bando_ch_month = rbind(X_bando_ch_month, one_row)
  print(sprintf('%s finished', a))
  a = a+1
}
X_bando_ch_month = data.frame(X_bando_ch_month)
rownames(X_bando_ch_month) = NULL
colnames(X_bando_ch_month) = c('pet','rh','srad')


a = 1
for (index in uq_jeju){
  one_row = c()
  for (lst in 1:m){
    tmp =  cal_stat_in_one_grid_chelsa(grid_jeju, list_month[[lst]] , index, multiple=F)
    one_row = append(one_row, tmp)
  }
  X_jeju_ch_month = rbind(X_jeju_ch_month, one_row)
  print(sprintf('%s finished', a))
  a = a+1
}
X_jeju_ch_month = data.frame(X_jeju_ch_month)
rownames(X_jeju_ch_month) = NULL
colnames(X_jeju_ch_month) = c('pet','rh','srad')
final = rbind.data.frame(X_bando_ch_month,X_jeju_ch_month)
final$index_grid = as.integer(c(uq_bando, uq_jeju))
final$region = c(rep('b',length(uq_bando)), rep('j', length(uq_jeju)))
setwd('~/desktop/contest/environ/script')
write.csv(final,  '../concat_data/variables/flr/chelsa_etc.csv', row.names=F)
save.image('../workspace/bird_etc.RData')
