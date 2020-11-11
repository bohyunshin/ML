rm(list=ls())
library(dplyr)
library(rgdal)
library(raster)
library(sp)
library(leaflet)

shp_birds = '/Users/shinbo/Desktop/contest/environ/tbl_ntee_birds/tbl_ntee_birds.shp'
bird = readOGR(shp_birds, stringsAsFactors=FALSE)
bird_coord = coordinates(spTransform(bird, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")))

bird = data.frame(bird)
bird_coord = data.frame(bird_coord)
colnames(bird_coord) = c('lon','lat')
bird$lon = bird_coord$lon
bird$lat = bird_coord$lat

############################################ make bando, jeju data separately ############################################

is_in_jeju = function(data){
  result = c()
  for (i in 1:nrow(data)){
    lon = data[i,][1]
    lat = data[i,][2]
    if (126.1 <= lon & lon <= 127 & 33.2 <= lat & lat <= 33.6){
      result = append(result, i)
    }
  }
  return(result)
}

jeju_bird_index = is_in_jeju(bird_coord)
bando_bird_index = setdiff(1:dim(bird)[1], jeju_bird_index)

bird_bando = bird[bando_bird_index, c('examin_beg','spcs_korea','indvd_qy','partclr_ma','examin_tim', 'lon','lat') ]
bird_jeju = bird[jeju_bird_index, c('examin_beg','spcs_korea','indvd_qy','partclr_ma','examin_tim', 'lon','lat')]
bird_coord_bando = bird_coord[bando_bird_index, ]
bird_coord_jeju = bird_coord[jeju_bird_index, ]


############################################ define whole grid ############################################

###################### whole region ######################
# make 1km by 1km grid
# bottom left: c(126.1,34.2)
# bottom right: c(129.1,34.2)
# top left: c(126.1,38.2)
# top right: c(129.1,38.2)


'
Input: bottom/left, bottom/right, top/left, top/right points
Ouput: 1km * 1km grid for designated area
'
make_grid = function(start_lon, start_lat, end_lon, end_lat){
  # make 1km by 1km grid
  lons = c(start_lon)
  lats = c(start_lat)
  
  # lon grid
  lon = 0
  while (lon < end_lon){
    lon = lons[length(lons)]
    lons = append(lons, lon+0.01)
    lon = lon+0.01
  }
  
  # lat grid
  lat = 0
  while (lat < end_lat){
    lat = lats[length(lats)]
    lats = append(lats, lat+0.015)
    lat = lat+0.015
  }
  
  grid = list()
  index = 1
  for (j in 1:(length(lats)-1)){
    for (i in 1:(length(lons)-1)){
      grid_lon = lons[i:(i+1)]
      grid_lat = lats[j:(j+1)]
      grid[[index]] = data.frame(lon=grid_lon, lat=grid_lat)
      index = index + 1
    }
  }
  return(grid)
}

'
Input: bottom/left, bottom/right, top/left, top/right points for all grids
Ouput: leaflet for all grids
'
make_leaflet_bando_grid = function(grid_list, initial_point){
  leaflet_ = leaflet() %>%
    setView(lng=initial_point[1], lat=initial_point[2], zoom=9) %>%
    addTiles()
  
  for (i in 1:length(grid_list)){
    leaflet_ = leaflet_ %>%
      addRectangles(lng1=min(grid_list[[i]]$lon), lat1=min(grid_list[[i]]$lat),
                    lng2=max(grid_list[[i]]$lon), lat2=max(grid_list[[i]]$lat),
                    fillOpacity=0.2, opacity = 0.2)
    if (i %% 1000 == 0) print(i)
  }
  return(leaflet_)
}

grid_bando = make_grid(126.1, 34.2, 129.1, 38.2)
# this takes huge time
leaflet_bando_grid = make_leaflet_bando_grid(grid_bando, c(127.5, 34.2))

###################### jeju only ######################

grid_jeju = make_grid(126.1, 33.2, 127, 33.6)
leaflet_jeju_grid = make_leaflet_bando_grid(grid_jeju, c(126.1,33.2))
leaflet_jeju_grid
############################################ define observed grid ############################################

'
Input: whole grid list and observed coordinates
Ouput: index of grid indicating where a coordinate belongs to
'
make_bando_observed_grid_index = function(grid_list, data_coord){

  which_grid = function(lon, lat, grid_list){
    for (i in 1:length(grid_list)){
      min_lon = min(grid_list[[i]]$lon)
      max_lon = max(grid_list[[i]]$lon)
      min_lat = min(grid_list[[i]]$lat)
      max_lat = max(grid_list[[i]]$lat)
      if (min_lat <= lat & lat <= max_lat & min_lon <= lon & lon <= max_lon){
        return(i)
      }
    }
  }
  index_grid = c()
  for (i in 1:nrow(data_coord)){
    lon = data_coord$lon[i]
    lat = data_coord$lat[i]
    index_grid = append(index_grid, which_grid(lon, lat, grid_list))
    if (i %% 1000 == 0) print(i)
  }
  return(index_grid)
}


#### make observed grid function separately for whole bando ###

'
Input: bottom/left, bottom/right, top/left, top/right points
Ouput: 1km * 1km grid for designated area
This function is similar to make_bando_observed_grid_index but
it can reduce computation time more efficiently
'
func_temp = function(grid_list, data_coord, lon_list, lat_list){
  
  which_grid = function(lon, lat, index){
      min_lon = min(grid_list[[index]]$lon)
      max_lon = max(grid_list[[index]]$lon)
      min_lat = min(grid_list[[index]]$lat)
      max_lat = max(grid_list[[index]]$lat)
      if (min_lat <= lat & lat <= max_lat & min_lon <= lon & lon <= max_lon){
        return(index)
      }
  }
  
  index_grid = c()
  n = nrow(data_coord)
  for (i in 1:n){
    lon = data_coord[i,]$lon
    lat = data_coord[i,]$lat
    
    lat_max = lat_list[which(lat_list - lat > 0)[1]]
    lat_min = lat_max - 0.015
    look_up_index = (length(lon_list)-1) * ((lat_min - 34.2) / 0.015)
    m = length(grid_list)
    for (j in (look_up_index+1):m){
      index_grid = append(index_grid, which_grid(lon, lat, j))
    }
    if (i %% 1000 == 0) print(i)
  }
  return(index_grid)
}

lon_list = c()
lat_list = c()
for (i in 1:length(grid_bando)){
  lon_list = append(lon_list, grid_bando[[i]]$lon)
  lat_list = append(lat_list, grid_bando[[i]]$lat)
}
lon_list = unique(lon_list)
lat_list = unique(lat_list)

index_grid_bando = func_temp(grid_bando, bird_bando, lon_list, lat_list)
save.image('/Users/shinbo/Desktop/contest/environ/workspace/workspace.RData')
bird_bando$index_grid = index_grid_bando


# function for make leaflet observed grid
'
Input: index of grid for each coordinate, whole grid list, initial point
Ouput: leaflet for observed grid
'
make_leaflet_bando_observed_grid = function(index_grid, grid_list, initial_point){
  observed_grid = unique(index_grid)
  leaflet_ = leaflet() %>%
    setView(lng=initial_point[1], lat=initial_point[2], zoom=9) %>%
    addTiles()
  for (i in observed_grid){
    leaflet_ = leaflet_ %>%
      addRectangles(lng1=min(grid_list[[i]]$lon), lat1=min(grid_list[[i]]$lat),
                    lng2=max(grid_list[[i]]$lon), lat2=max(grid_list[[i]]$lat),
                    fillOpacity=0.2, opacity = 0.2)
    if (i %% 1000 == 0) print(i)
  }
  return(leaflet_)
}

index_grid_jeju = make_bando_observed_grid_index(grid_jeju, bird_coord_jeju)
bird_jeju$index_grid = index_grid_jeju

leafleft_observed_grid_jeju = make_leaflet_bando_observed_grid(index_grid_jeju, grid_jeju, c(126.1,33.2))
leafleft_observed_grid_jeju

leafleft_observed_grid_bando = make_leaflet_bando_observed_grid(index_grid_bando, grid_bando, c(127.5, 34.2))
leafleft_observed_grid_bando


############################################ concat bando, jeju result ############################################


'
Input: baseline leaflet, species name
Output: baseline leaflet + species observation location circle
'
make_leaflet_species = function(df, leaflet_, bird_name){
  sel_data = df %>% filter(spcs_korea == bird_name)
  result = leaflet_ %>% addCircles(~lon, ~lat, data=sel_data)
  return(result)
}

ex = make_leaflet_species(bird_jeju, leafleft_observed_grid_jeju, '박새')
ex



####################################### making variables #######################################
'
In this part, worldclim data will be extracted.
For documentation, this part will be kept
'

# downloading the bioclimatic variables from worldclim at a resolution of 30 seconds (.5 minutes)
r <- getData("worldclim", var="bio", res=0.5, lon=c(125,128), lat=c(32,34))
# lets also get the elevational data associated with the climate data
alt <- getData("worldclim", var="alt", res=.5, lon=c(125,128), lat=c(32,34))


extract_alt_clim = function(r, alt, coords){
  # the steps to extract values for the variables you want from the coordinates:
  points <- SpatialPoints(coords, proj4string = r@crs)
  # getting temp and precip for the points
  clim <- extract(r, points)
  # getting the 30s altitude for the points
  altS <- extract(alt, points)
  # bind it all into one dataframe
  climate <- cbind.data.frame(coords, altS, clim)
  return(climate)
}

cal_stat_in_one_grid = function(grid, r, alt, index){
  min_lon = min(grid[[index]]$lon)
  max_lon = max(grid[[index]]$lon)
  min_lat = min(grid[[index]]$lat)
  max_lat = max(grid[[index]]$lat)
  
  lon_grid = seq(min_lon, max_lon, 0.001)
  lat_grid = seq(min_lat, max_lat, 0.001)
  coords_in_one_grid = c()
  for (lon in lon_grid){
    for (lat in lat_grid){
      coords_in_one_grid = rbind(coords_in_one_grid, c(lon, lat))
    }
  }
  
  coords_in_one_grid = data.frame(coords_in_one_grid)
  colnames(coords_in_one_grid) = c('lon','lat')
  points <- SpatialPoints(coords_in_one_grid, proj4string = r@crs)
  # getting temp and precip for the points
  clim <- extract(r, points)
  # getting the 30s altitude for the points
  altS <- extract(alt, points)
  # bind it all into one dataframe
  climate <- cbind.data.frame(coords_in_one_grid, altS, clim)
  return(apply(climate, 2, function(x) mean(x, na.rm=TRUE)))
}

X_bando = c()
a = 1
uq = unique(index_grid_bando)
for (index in uq){
  temp = cal_stat_in_one_grid(grid_bando, r, alt, index)
  X_bando = rbind(X_bando,temp)
  print(sprintf('%s finished out of %s', a, length(uq)))
  a = a + 1
}

X_bando = data.frame(X_bando)
X_bando$grid_index = uq
X_bando$region = 'b'
rownames(X_bando) = NULL

# check grid near river or sea
which(is.na(X_bando$altS))
X_bando = X_bando[-which(is.na(X_bando$altS)), ]
