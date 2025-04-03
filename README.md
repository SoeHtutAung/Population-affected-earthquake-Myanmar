# Population estimation according to USGS MMI scale
The purpose is to support post-disaster humanitarian assistance by generate population estimation in each USGS's Modified Mercalli Intensity Scale for 2025 Myanmar earthquake. In this analysis we emphasize on Sagaing, Mandalay, Bago and Naypyitaw regions at township level. Additional anlaysis was done at ward level for Mandalay and Sagaing.

## 1. Data extraction
Following data are extracted
| Name | Description |
| ---- | ---- |
| ward.geojson </br> township.geojson | Spatial dataset from the [MIMU](https://geonode.themimu.info/layers/) |
| mmi_mean.flt </br> mmi_mean.hdr | Raster surface from [USGS](https://earthquake.usgs.gov/earthquakes/eventpage/us7000pn9s/shakemap/metadata)|
| mmr_pd_2020_1km_UNadj.tif | Population density raster surface (2020 UN adjusted) from [Worldpop](https://hub.worldpop.org/geodata/listing?id=77) |

## 2. Categorizing intensity
Modified Mercalli Intensity ([MMI](https://www.usgs.gov/programs/earthquake-hazards/modified-mercalli-intensity-scale)) scale is released by USGS and downloaded from this [link](https://earthquake.usgs.gov/earthquakes/eventpage/us7000pn9s/shakemap/metadata). For the purpose of simplification, we simply round the intensity scales into integer and categorize as 'below 7' (weak to strong), 7 (Very strong), 8 (Severe), and 9 (Violent). 
![mmi](https://github.com/user-attachments/assets/3698c6b4-2942-4c2e-8ebb-19843149642b)

## 3. Producing datasets
We rescale the population according to World Bank's estimates for 2023 and projected for 2024 using average population growth rate. Total population and population in each intensity categories are extracted using exactextractr package.
