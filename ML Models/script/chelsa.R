get_chelsa <- function(type = "bioclim", layer = 1:19, period, model_string, scenario_string, future_years,
                       output_dir)
{
  # Argument checking - fail if one of 19 layers isn't requested
  stopifnot(layer %in% 1:19, type == "bioclim", period %in% c("past", "current", "future"))
  
  if (missing(output_dir))
  {
    output_dir <- getwd()
  } else {
    dir.create(output_dir, recursive=TRUE, showWarnings=FALSE)
  }
  
  if (period == "future")
  {
    stopifnot(future_years %in% c("2041-2060", "2061-2080"), scenario_string %in% c("rcp26", "rcp45", "rcp60", "rcp85"),
              model_string %in% c("ACCESS1-0", "BNU-ESM", "CCSM4", "CESM1-BGC", "CESM1-CAM5", "CMCC-CMS", "CMCC-CM",
                                  "CNRM-CM5", "CSIRO-Mk3-6-0", "CanESM2", "FGOALS-g2", "FIO-ESM", "GFDL-CM3", "GFDL-ESM2G",
                                  "GFDL-ESM2M", "GISS-E2-H-CC", "GISS-E2-H", "GISS-E2-R-CC", "GISS-E2-R", "HadGEM2-AO", "HadGEM2-CC",
                                  "IPSL-CM5A-LR", "IPSL-CM5A-MR", "MIROC-ESM-CHEM", "MIROC-ESM", "MIROC5", "MPI-ESM-LR",
                                  "MPI-ESM-MR", "MRI-CGCM3", "MRI-ESM1", "NorESM1-M", "bcc-csm1-1", "inmcm4"))
  }
  
  
  
  
  # Check if files already exist in the folder
  # if (load_old)
  # {
  #   if (length(list.files(output_dir, pattern = "CHELSA_bio10_*.*.tif", full.names = TRUE)) > 0)
  #   {
  #     raster_stack <- raster::stack(list.files(output_dir, pattern = "CHELSA_bio10_*.*.tif", full.names = TRUE))
  #     return(raster_stack)
  #   }
  # }
  
  layerf <- sprintf("%02d", layer)
  # Check if input is correct
  stopifnot(layerf %in% sprintf("%02d", 1:19))
  
  # Fork to download bioclim data for last glacial maximum (past data)
  if (period == "past")
  {
    stopifnot(model_string %in% c("CCSM4", "CNRM-CM5", "FGOALS-g2", "IPSL-CM5A-LR",
                                  "MIROC-ESM", "MPI-ESM-P", "MRI-CGCM3"))
    
    if (missing(scenario_string))
    {
      cat("Argument scenario_string missing. Assuming pmip3 scenario", "\n")
      scenario_string <- "pmip3"
    }
    
    path <- paste0(normalizePath(output_dir), "/past/")
    dir.create(path, recursive=TRUE, showWarnings=FALSE)
    
    
    for (i in layerf) # Loop over bioclim layers
    {
      for (model_s in model_string)
      {
        # layer_url <- paste0("https://www.wsl.ch/lud/chelsa/data/pmip3/bioclim/CHELSA_PMIP_CCSM4_bio_", i, ".7z")
        
        out_layer <- glue::glue("CHELSA_PMIP_{model_s}_BIO_{i}.tif")
        layer_url <- glue::glue("https://www.wsl.ch/lud/chelsa/data/pmip3/bioclim/{out_layer}")
        file_path <- paste0(path, out_layer)
        
        if (!file.exists(file_path))
        {
          download.file(layer_url, file_path)
        }
        
        # Extract archive
        # archive::archive_extract(temporary_file, dir = output_dir)
        
      }
      
      # Delete temporary files if tmp_keep argument
      # if (!tmp_keep)
      # {
      #   fs::file_delete(temporary_file)
      # }
    }
    return(stack(list.files(path, full.names = TRUE)))
  }
  # Loop over layers - download, unzip and remove zipped file (only bioclim for now)
  if (period == "current")
  {
    path <- paste0(normalizePath(output_dir), "/current/")
    dir.create(path, recursive=TRUE, showWarnings=FALSE)
    
    for (i in layerf)
    {
      # layer_url <- paste0("https://www.wsl.ch/lud/chelsa/data/bioclim/integer/CHELSA_bio10_", i, ".tif")
      out_layer <- glue::glue("CHELSA_bio10_{i}.tif")
      layer_url <- glue::glue("https://www.wsl.ch/lud/chelsa/data/bioclim/integer/{out_layer}")
      # temporary_file <- fs::file_temp(ext = ".tif", tmp_dir = temp_dir)
      file_path <- paste0(path, out_layer)
      
      if (!file.exists(file_path))
      {
        download.file(layer_url, file_path)
      }
      # download.file(layer_url, file_path)
      
      # Extract archive
      # archive::archive_extract(temporary_file, dir = output_dir)
      
    }
    return(stack(list.files(path, full.names = TRUE)))
    
  }
  
  # Download CHELSA climate data for future years
  if (period == "future")
  {
    
    path <- paste0(normalizePath(output_dir), "/future/")
    dir.create(path, recursive=TRUE, showWarnings=FALSE)
    
    for (future_y in future_years) # Loop over the future years
    {
      for (scenario_s in scenario_string) # Loop over RCP scenarios
      {
        for (model_s in model_string) # Loop over climate models
        {
          for (i in layer) # Loop over bioclim layers
          {
            # New version of CHELSA future data comes as tif file...
            
            # layer_name <- paste0("CHELSA_bio_mon_", model_s, "_", scenario_s, "_r1i1p1_g025.nc_",
            #                      i, "_", future_y, ".tif")
            # https://www.wsl.ch/lud/chelsa/data/cmip5/2061-2080/bio/CHELSA_bio_mon_ACCESS1-0_rcp45_r1i1p1_g025.nc_1_2061-2080_V1.2.tif
            layer_name <- glue::glue("CHELSA_bio_mon_{model_s}_{scenario_s}_r1i1p1_g025.nc_{i}_{future_y}_V1.2.tif")
            
            # layer_url <- paste0("https://www.wsl.ch/lud/chelsa/data/cmip5/", future_y, "/bio/", layer_name)
            layer_url <- glue::glue("https://www.wsl.ch/lud/chelsa/data/cmip5/{future_y}/bio/{layer_name}")
            # "CHELSA_bio_mon_", model_s, "_", scenario_s, "_r1i1p1_g025.nc_",
            # i, "_", future_y, ".7z")
            # print(layer_url)
            # temporary_file <- fs::file_temp(ext = ".7z", tmp_dir = temp_dir)
            
            # file_name_out <- paste0(normalizePath(output_dir), "/", layer_name)
            file_path <- paste0(path, layer_name)
            
            if (!file.exists(file_path))
            {
              download.file(layer_url, file_path)
            }
            
            # download.file(layer_url, file_path)
            
            # Extract archive
            # archive::archive_extract(temporary_file, dir = output_dir)
            
            # if (!tmp_keep)
            # {
            #   fs::file_delete(temporary_file)
            # }
          } # Bioclim layer closing
        } # Model string closing
      } # Scenario string closing
    } # Future years closing
    return(stack(list.files(path, full.names = TRUE)))
    
  } # Period closing
}





#' Build a list of files to download
#'
#' This function constructs a set of download URLs for the requested
#' combinations of metadata variables. It currently supports download of
#' historic climatologies and future CMIP5 model predictions for both basic
#' monthly variables and bioclimatic variables. CHELSA provides historic data in
#' integer*10 format and floating point format, but only the former is available
#' using this function, for consistency with CMIP5 futures which are available
#' only in integer*10 format.
#'
#' @param variables character vector, options include "tmin", "tmax", "temp",
#'   "prec", and "bio".
#' @param layers integer vector, options include 1:12 for base variables
#'   (representing months) and 1:19 for bio (representing biovariable number).
#' @param models character vector, specify only for future data.
#' @param scenarios character vector, specify only for future data.
#' @param timeframes character vector, options include "1979-2013", "2014-2060",
#'   and "2061-2080".
#' @return a data frame of metadata for all factorial combinations of the
#'   requested variables
ch_queries <- function(variables, layers, models=NA, scenarios=NA, timeframes){
  require(dplyr)
  base_url <- "https://envidatrepo.wsl.ch/uploads/chelsa/chelsa_V1/"
  expand.grid(model = models, scenario = scenarios, timeframe = timeframes,
              variable = variables, layer = layers) %>%
    mutate(variable2 = case_when(variable == "tmin" ~ "tasmin",
                                 variable == "tmax" ~ "tasmax",
                                 variable ==
                                   "temp" ~ "tas",
                                 variable == "prec" ~ "pr",
                                 variable ==
                                   "bio" ~ "bio"),
           addendum = case_when(variable == "prec" ~ "",
                                TRUE ~ "_V1.2"),
           histdir = case_when(variable == "bio" ~ "bioclim/integer/",
                               variable == "prec" ~ "climatologies/prec/",
                               TRUE ~ paste0("climatologies/temp/integer/", variable, "/")),
           file = case_when(timeframe == "1979-2013" &  variable != "bio" ~
                              paste0(histdir, "CHELSA_", variable, "10_", str_pad(layer, 2, "left", "0"), "_land.7z"),
                            timeframe == "1979-2013" & variable == "bio" ~
                              paste0(histdir, "CHELSA_", variable, "10_", str_pad(layer, 2, "left", "0"), ".tif"),
                            TRUE ~ paste0("cmip5/", timeframe, "/", variable, "/CHELSA_",
                                          variable2, "_mon_", model, "_", scenario, "_r*i1p1_g025.nc_",
                                          layer, "_", timeframe, addendum, ".tif")),
           url = paste0(base_url, file))
}

#' Download CHELSA data
#'
#' Many standard palette generators use only a slice of color space, which can
#' cause a lack of differentiability in palettes used to visualize categorical
#' factors with many levels. This function attempts to overcome this by
#' generating colors using nearest-neighbor distance maximization in 3D RGB
#' space.
#'
#' @param md Variables to download (a data frame created by ch_queries).
#' @param dest Path to file folder where downloaded files should be stored
#'   (character).
#' @param skip_existing Should files that are already present in the destination
#'   be igored (logical).
#' @param method Download method, passed to downloa.file (character).
#' @param crop Spatial bounding box to crop each downloaded raster to (an extent
#'   object, or any spatial object with an extent).
ch_dl <- function(md, dest=NULL, skip_existing=TRUE, method="curl", crop=NULL){
  
  if(is.null(dest)) dest <- getwd()
  
  for(i in 1:nrow(md)){
    message(paste("File", i, "of", nrow(md), "..."))
    md$status[i] <- "incomplete"
    md$path[i] <- paste0(dest, "/", basename(md$file[i]))
    
    runs <- c("1", "2", "12")
    
    if(skip_existing){
      # previously-failed downloads have small file size
      paths <- sapply(runs, function(x) sub("\\*", x, md$path[i]))
      size <- file.size(paths)
      if(any(!is.na(size) & log(size)>10)){
        md$path[i] <- paths[!is.na(size) & log(size)>10]
        md$status[i] <- "already done"
        next()
      }
    }
    
    # run numbers vary by model. try all options.
    for(run in runs){
      url <- sub("\\*", run, md$url[i])
      path <- sub("\\*", run, md$path[i])
      r <- try(download.file(url, path, method=method, quiet=T))
      size <- file.size(path)
      if(!is.na(size) & log(size)>10){
        md$url[i] <- url
        md$path[i] <- path
        break()
      }
      file.remove(path)
    }
    
    if(class(r)=="try-error"){
      md$status[i] <- as.character(r)
      next()
    }
    if(file.exists(md$path[i])) md$status[i] <- "download completed"
    
    if(!is.null(crop) & file.exists(md$path[i])){
      require(raster)
      r <- raster(md$path[i]) %>%
        crop(crop) %>%
        writeRaster(md$path[i], overwrite=T)
      md$status[i] <- "raster cropped"
    }
  }
  return(md)
}


# generate a metadata table given a set of file paths
ch_parse <- function(paths){
  
}

# list available data
ch_datasets <- function(){
  
}