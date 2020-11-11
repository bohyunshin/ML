library(raster)
library(leaflet)
library(dplyr)
setwd('../concat_data/pred_grid')

## bnin
df_prob = read.csv('insect/df_prob.csv')
df_pred = read.csv('insect/df_pred.csv')
prob_ratio = list()

# identify number of column
# ncol(df_prob)
# > 39
cols = colnames(df_pred)[1:37]
for (n in cols){
  temp = subset(df_pred, select = c(n))
  prob_ratio[[n]] = mean( temp[,1] )
}

# make continuous, discrete palette.
#pal = colorNumeric(palette='Greens', domain=df_prob$두갈래하루살이)
#pal = colorBin("Blues", domain=df_prob$두갈래하루살이, 6, pretty = FALSE)

grid_list = list(top = pred_top_grid, middle1 = pred_middle1_grid, middle2 = pred_middle2_grid, bottom = pred_bottom_grid)
n = c('top','middle1','middle2','bottom')

'
Input: prediction grid_list, value of interest
Output: leaflet for prediction grid_list colored by value
'

make_leaflet_bando_grid_multiple = function(grid_list, initial_point, specs, multiple, df_prob){
  pal = colorNumeric(palette='Greens', domain=df_prob[,specs])
  leaflet_ = leaflet() %>%
    setView(lng=initial_point[1], lat=initial_point[2], zoom=9) %>%
    addTiles()
  indx = 1
  if (multiple){
    for (lst in grid_list){
      for (i in 1:length(lst)){
        temp = df_prob %>% filter(location == n[indx] & grid_index == i)
        leaflet_ = leaflet_ %>%
          addRectangles(lng1=min(lst[[i]]$lon), lat1=min(lst[[i]]$lat),
                        lng2=max(lst[[i]]$lon), lat2=max(lst[[i]]$lat),
                         color = pal(temp[,specs]))
      }
      indx = indx + 1
    }
  }
  else{
    for (i in 1:length(grid_list)){
      temp = df_prob %>% filter(location == n[indx] & grid_index == i)
      leaflet_ = leaflet_ %>%
        addRectangles(lng1=min(grid_list[[i]]$lon), lat1=min(grid_list[[i]]$lat),
                      lng2=max(grid_list[[i]]$lon), lat2=max(grid_list[[i]]$lat),
                      color = pal(temp[,specs]))
    }
  }
  return(leaflet_)
}
a = make_leaflet_bando_grid_multiple(grid_list, c(127, 38), '검거세미밤나방', multiple=T, df_prob)
a
b = make_leaflet_bando_grid_multiple(grid_list, c(127, 38), '꼽등이', multiple=T, df_prob)
b

save.image('final_prediction_workspace.RData')
