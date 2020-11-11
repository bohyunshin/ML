load('/Users/shinbo/Desktop/contest/environ/workspace/workspace3.RData')

library(raster)
alt <- getData("worldclim", var="alt", res=.5, lon=c(120, 130), lat=c(30, 38))

cal_alt_in_one_grid = function(grid, alt, index){
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
  # getting the 30s altitude for the points
  altS <- extract(alt, points)
  # bind it all into one dataframe
  climate <- cbind.data.frame(coords_in_one_grid, altS)
  return(apply(climate, 2, function(x) mean(x, na.rm=TRUE)))
}

X_bando_alt = c()
a = 1
uq_bando = unique(index_grid_bando)
for (index in uq_bando){
  temp = cal_alt_in_one_grid(grid_bando, alt, index)
  X_bando_alt = rbind(X_bando_alt,temp)
  print(sprintf('%s finished out of %s', a, length(uq_bando)))
  a = a + 1
}
X_bando_alt = data.frame(X_bando_alt)
rownames(X_bando_alt) = NULL
colnames(X_bando_alt) = c('lon','lat','alt')


X_jeju_alt = c()
a = 1
uq_jeju = unique(index_grid_jeju)
for (index in uq_jeju){
  temp = cal_alt_in_one_grid(grid_jeju, alt, index)
  X_jeju_alt = rbind(X_jeju_alt,temp)
  print(sprintf('%s finished out of %s', a, length(uq_jeju)))
  a = a + 1
}

X_jeju_alt = data.frame(X_jeju_alt)
rownames(X_jeju_alt) = NULL
colnames(X_jeju_alt) = c('lon','lat','alt')

X_alt = rbind.data.frame(X_bando_alt, X_jeju_alt)
rownames(X_alt) = NULL
colnames(X_alt) = c('lon','lat','alt')
X_alt$index_grid = as.integer(c(uq_bando, uq_jeju))
X_alt$region = c(rep('b',length(uq_bando)), rep('j', length(uq_jeju)))
head(X_alt)
write.csv(X_alt,  '../concat_data/variables/flr/worldclim_alt.csv', row.names=F)


X_bando_alt = c()
a = 1
uq_bando = unique(index_grid_bando)
for (index in uq_bando){
  temp = cal_alt_in_one_grid(grid_bando, alt, index)
  X_bando_alt = rbind(X_bando_alt,temp)
  print(sprintf('%s finished out of %s', a, length(uq_bando)))
  a = a + 1
}
X_bando_alt = data.frame(X_bando_alt)
rownames(X_bando_alt) = NULL
colnames(X_bando_alt) = c('lon','lat','alt')
