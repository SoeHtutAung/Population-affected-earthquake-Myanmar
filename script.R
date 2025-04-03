######################
# Topic: Estimated affected pop size
# Purpose: Prioritize wards for humanitarian response in Myanmar earthquake 2025
# Author: One Tech Agency
###################### 

# load libraries
library(sf)
library(dplyr)
library(terra)
library(exactextractr)
library(tmap)

# get datasets
# ward boundaries from MIMU v9.4
# Global friction surface enumerating land-based travel speed with access to motorized transport from MAP
# population density from WorldPop https://data.worldpop.org/GIS/Population_Density/Global_2000_2020_1km/2020/MMR/mmr_pd_2020_1km.tif
# Intensity from USGS ShakeMap - Modified Mercalli Intensity Scale mean
# Damaged building list from HDX https://data.humdata.org/dataset/c0ac6ec9-feba-4f20-b4b2-651d92c6e753/resource/c702209e-20b7-49aa-81a2-22ac35a73fdb/download/skysat_20250329_080228_predictions_merged.gpkg

# load datasets
ward <- st_read("data/ward.geojson")
township <- st_read("data/township_raw.geojson")
fric <- rast("data/202001_Global_Motorized_Friction_Surface_MMR.tiff")
pop <- rast("data/mmr_pd_2020_1km_UNadj.tif")
damage <- st_read("data/skysat_20250329_080228_predictions_merged.gpkg")
intensity <- rast("data/mmi_mean.flt")

# create required datasets
## location of damaged buildings in Mandalay
damage <- damage %>% filter (damaged == 1) %>% st_centroid() # only damaged buildings are filtered

# population adjustment as 54,133,798 in 2023 by World Bank 
freq(pop, value = NA) # 1704849 NAs
## set parameters
scale_factor <- (54133798 - as.numeric(global(pop, sum, na.rm = TRUE)[1])) / as.numeric(global(pop, sum, na.rm = TRUE)[1]) 
growth_rate <- 0.007  # average population growth rate (2021-23) from Worldbank data
## apply rescaling to each raster cell
pop_23 <- pop * (1 + scale_factor)  # rescale to 2023
pop_24 <- pop_23 * (1 + growth_rate)  # estimate population for 2024
pop_24[is.na(pop_24)] <- 0  # Replace NAs with zero

# data transformation of rasters
## match extent and crs
intensity <- project(intensity, crs(pop_24))
## crop pop_24 and intensity for intersect extent
common_extent <- intersect(ext(pop_24), ext(intensity)) #get the intersecting extent
pop_24 <- crop(pop_24, common_extent)
intensity <- crop(intensity, common_extent)
## match resolution
intense <- resample(intensity, pop_24, method = "near")

# classify intensity values to category 1-10 scale
intensity_cat <- round(intense) # simple rounding intensity values to the nearest integer
# zonal statistics to get total population in each intensity category
pop_by_intensity <- zonal(pop_24, intensity_cat, fun = "sum") # total
## define intensity categories for calaulation
categories <- list(
  "pop_below7" = intensity_cat < 7,  # Less than 7
  "pop_7"   = intensity_cat == 7, # Exactly 7
  "pop_8"   = intensity_cat == 8, # Exactly 8
  "pop_9"   = intensity_cat == 9  # Exactly 9
)

##### 1. Wards in MDY AND SGG ####
# 1.1 Preparing datasets
# ward boundaries
ward_mdy <- ward %>% filter(DT == "Mandalay") # Mandalay
ward_sgg <- ward %>% filter(DT == "Sagaing") # Sagaing

# extract total population in wards
ward_pop_mdy <- exact_extract(pop_24, ward_mdy, "sum") # mandalay
ward_mdy$pop <- ward_pop_mdy # add pop to ward_mdy
ward_pop_sgg <- exact_extract(pop_24, ward_sgg, "sum") # sagaing
ward_sgg$pop <- ward_pop_sgg # add pop to ward_sgg

# 1.2 Extract population in each intensity category
# extract each intensity category in each ward of Mandalay
## make sure of crs
ward_mdy <- st_transform(ward_mdy, crs = crs(pop_24))

## extract population for each category
for (cat in names(categories)) {
  masked_pop <- pop_24 * categories[[cat]]  # Mask population by intensity
  ward_mdy[[cat]] <- exact_extract(masked_pop, ward_mdy, fun = "sum", default_value = 0)
}

# extract each intensity category in each ward of Sagaing
## make sure of crs
ward_sgg <- st_transform(ward_sgg, crs = crs(pop_24))
## extract population for each category
for (cat in names(categories)) {
  masked_pop <- pop_24 * categories[[cat]]  # Mask population by intensity
  ward_sgg[[cat]] <- exact_extract(masked_pop, ward_sgg, fun = "sum", default_value = 0)
}

# save the results
st_write(ward_mdy, "data/ward_mdy.geojson", delete_dsn = TRUE)
st_write(ward_sgg, "data/ward_sgg.geojson", delete_dsn = TRUE)

##### 2. Townships in MDY, NPT, SGG AND BGO
# 2.1 Preparing datasets ####
# ward boundaries
tsp <- township %>% filter(
  ST == "Mandalay" |
  ST == "Sagaing" |
  ST == "Nay Pyi Taw" |
  grepl("^Bago", ST)) # both east and west

# extract total population in townships
tsp_pop <- exact_extract(pop_24, tsp, "sum")
tsp$pop <- tsp_pop # add pop to ward_mdy

# 2.2 Extract population in each intensity category
# extract each intensity category in each ward of Mandalay
## make sure of crs
tsp <- st_transform(tsp, crs = crs(pop_24))
## extract population for each category
for (cat in names(categories)) {
  masked_pop <- pop_24 * categories[[cat]]  # Mask population by intensity
  tsp[[cat]] <- exact_extract(masked_pop, tsp, fun = "sum", default_value = 0)
}

# save the results
st_write(tsp, "data/township.geojson", delete_dsn = TRUE)

#### 3. Visualization ####
# prepare dataframe for Mandalay
ward_mdy_vis <- ward_mdy %>% 
  select(TS, WARD, WARD_MMR,
         pop, pop_below7, pop_7, pop_8, pop_9) %>% 
  mutate(
    extreme_pct = round(pop_9/ pop * 100, 2))

# prepare dataframe for tsps
state_name <- c("Sagaing", "Mandalay", "Nay Pyi Taw", "Bago") # create a list of states
## create a function to prepare the data for a specific state
prepare_tsp_vis <- function(state_name) {
  tsp %>%
    filter((state_name == "Bago" & grepl("^Bago", ST)) | (state_name != "Bago" & ST == state_name)) %>%
    select(DT, TS, TS_MMR, pop, pop_below7, pop_7, pop_8, pop_9) %>%
    mutate(
      vstrong_pct = round((pop_8 + pop_9) / pop * 100, 2)
    )
}
## prepare data for each state
tsp_sgg_vis <- prepare_tsp_vis("Sagaing")
tsp_mdy_vis <- prepare_tsp_vis("Mandalay")
tsp_npt_vis <- prepare_tsp_vis("Nay Pyi Taw")
tsp_bgo_vis <- prepare_tsp_vis("Bago")

# produce maps
## wards of Mandalay
tm_map_mdy <- tm_shape(ward_mdy) +
  tm_fill("extreme_pct", style = "quantile", palette = "YlOrRd") +
  tm_borders() +
  tm_layout(title = "Population in Extreme Intensity Category (Ward Level)",
            title.size = 1.5,
            legend.title.size = 1.2,
            legend.text.size = 0.8,
            legend.position = c("left", "bottom"),
            legend.outside = TRUE)

# produce tables
