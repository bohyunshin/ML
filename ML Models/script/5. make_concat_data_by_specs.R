load('/Users/shinbo/Desktop/contest/environ/workspace/bio.RData')
library(dplyr)

bio = read.csv('../concat_data/variables/chelsa_bio.csv')
etc = read.csv('../concat_data/variables/chelsa_etc.csv')
alt = read.csv('../concat_data/variables/worldclim_alt.csv')

concat_data = 
cbind.data.frame(
subset(bio, select=-c(index_grid, region)),
subset(etc, select=-c(index_grid, region)),
subset(alt, select=-c(index_grid, region)),
subset(bio, select=c(index_grid, region))
)

na_index = c()
for (i in 1:ncol(concat_data)){
  na_index = append(na_index, which(is.na(concat_data[,i])))
}
concat_data = concat_data[-unique(na_index),]

bird_bando$index_grid = index_grid_bando
bird_jeju$index_grid = index_grid_jeju
bird_total = rbind.data.frame(bird_bando, bird_jeju)

make_data_species = function(spc, bird_data, whole_observed_grid, left_merge_mat){
  spc_data = bird_data %>% filter(spcs_korea == spc)
  tmp1 = data.frame(index_grid = unique(spc_data$index_grid), y= rep(1, length(unique(spc_data$index_grid))))
  unobserved_grid = setdiff(whole_observed_grid, unique(spc_data$index_grid))
  tmp2 = data.frame(index_grid = unobserved_grid, y= rep(0,length(unobserved_grid)))
  y = data.frame(rbind(tmp1,tmp2))
  y$index_grid = as.integer(y$index_grid)
  concat_mat = merge(left_merge_mat,y,id = 'index_grid')
  return(concat_mat)
}

test = make_data_species()
first = '노랑부리백로, 황새, 노랑부리저어새, 저어새, 혹고니, 흰꼬리수리, 참수리, 검독수리, 매, 두루미, 넓적부리도요, 청다리도요사촌, 크낙새'
first = unlist(strsplit(first,', '))
second = '큰덤불해오라기, 붉은해오라기, 먹황새, 흑기러기, 큰기러기, 흰이마기러기, 개리, 큰고니, 고니, 가창오리, 붉은가슴흰죽지, 호사비오리, 물수리, 벌매, 솔개, 참매, 조롱이, 털발말똥가리, 큰말똥가리, 말똥가리, 항라머리검독수리, 흰죽지수리, 독수리, 잿빛개구리매, 알락개구리매, 개구리매, 새홀리기, 쇠황조롱이, 비둘기조롱이, 검은목두루미, 시베리아흰두루미, 흑두루미, 재두루미, 뜸부기, 느시, 검은머리물떼새, 흰목물떼새, 알락꼬리마도요, 검은머리갈매기, 적호갈매기, 뿔쇠오리, 수리부엉이, 긴점박이올빼미, 올빼미, 까막딱따구리, 팔색조, 뿔종다리, 삼광조'
second = unlist(strsplit(second, ', '))


write_csv_by_proportion = function(concat_data, which_kind, spcs){
  y = concat_data$y
  if (spcs %in% first){
    if (mean(y) < 0.005) write.csv(concat_data, paste('../concat_data/', which_kind, '/first/~0.5%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.005 <= mean(y) & mean(y) < 0.02) write.csv(concat_data, paste('../concat_data/', which_kind, '/first/0.5%~2%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.02 <= mean(y) & mean(y) < 0.05) write.csv(concat_data, paste('../concat_data/', which_kind, '/first/2%~5%/',spcs,'.csv', sep=''), row.names=F)
    else write.csv(concat_data, paste('../concat_data/', which_kind, '/first/5%~/',spcs,'.csv', sep=''), row.names=F)
  }
  else if (spcs %in% second){
    if (mean(y) < 0.005) write.csv(concat_data, paste('../concat_data/', which_kind, '/second/~0.5%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.005 <= mean(y) & mean(y) < 0.02) write.csv(concat_data, paste('../concat_data/', which_kind, '/second/0.5%~2%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.02 <= mean(y) & mean(y) < 0.05) write.csv(concat_data, paste('../concat_data/', which_kind, '/second/2%~5%/',spcs,'.csv', sep=''), row.names=F)
    else write.csv(concat_data, paste('../concat_data/', which_kind, '/second/5%~/',spcs,'.csv', sep=''), row.names=F)
  }
  else {
    if (mean(y) < 0.005) write.csv(concat_data, paste('../concat_data/', which_kind, '/etc/~0.5%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.005 <= mean(y) & mean(y) < 0.02) write.csv(concat_data, paste('../concat_data/', which_kind, '/etc/0.5%~2%/',spcs,'.csv', sep=''), row.names=F)
    else if (0.02 <= mean(y) & mean(y) < 0.05) write.csv(concat_data, paste('../concat_data/', which_kind, '/etc/2%~5%/',spcs,'.csv', sep=''), row.names=F)
    else write.csv(concat_data, paste('../concat_data/', which_kind, '/etc/5%~/',spcs,'.csv', sep=''), row.names=F)
  }
}

spcs_kor = unique(bird_total$spcs_korea)
for (bird_name in spcs_kor){
  tmp = make_data_species(bird_name, bird_total, c(index_grid_bando, index_grid_jeju), concat_data)
  write_csv_by_proportion(tmp, 'bird', bird_name)
}

