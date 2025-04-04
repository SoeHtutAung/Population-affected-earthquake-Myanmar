# Population estimation according to USGS MMI scale
The purpose is to support post-disaster humanitarian assistance by generating population estimation according to USGS's Modified Mercalli Intensity Scale for 2025 Myanmar earthquake. In this analysis, we emphasize on Sagaing, Mandalay, Bago and Naypyitaw regions at township level. Additional anlaysis was done at ward level for Mandalay and Sagaing. Public version of the outputs could be seen in this [Canva](https://soehtutaung.my.canva.site/ota-earthquake-tsp) site.

## 1. Data extraction
Following data are extracted
| Name | Description |
| ---- | ---- |
| ward.geojson </br> township.geojson | Spatial dataset from the [MIMU](https://geonode.themimu.info/layers/) |
| mmi_mean.flt </br> mmi_mean.hdr | Raster surface from [USGS](https://earthquake.usgs.gov/earthquakes/eventpage/us7000pn9s/shakemap/metadata)|
| mmr_pd_2020_1km_UNadj.tif | Population density raster surface (2020 UN adjusted) from [Worldpop](https://hub.worldpop.org/geodata/listing?id=77)|

## 2. Categorizing intensity
Modified Mercalli Intensity ([MMI](https://www.usgs.gov/programs/earthquake-hazards/modified-mercalli-intensity-scale)) scale is released by USGS and downloaded from this [link](https://earthquake.usgs.gov/earthquakes/eventpage/us7000pn9s/shakemap/metadata). For the purpose of simplification, we simply round the intensity scales into integer and categorize as 'below 7' (weak to strong), 7 (Very strong), 8 (Severe), and 9 (Violent). 
<img src=https://github.com/user-attachments/assets/3698c6b4-2942-4c2e-8ebb-19843149642b title="mmi" width="700"> 

## 3. Producing datasets
We rescale the population according to [World Bank](https://databank.worldbank.org/reports.aspx?source=2&country=MMR)'s estimates for 2023 and projected for 2024 using average population growth rate. Total population and population in each intensity categories are extracted using exactextractr package. Proportion of population who experienced severe (MMI scale - 8) or violent (MMI scale - 9) for each township is used to display in the maps.

## 4. Results
### 4.1 Maps and datasets
Percentage of population who experienced violent intensity in wards of Mandalay <br/>
<img src=https://github.com/user-attachments/assets/06dedb61-a75d-4df7-841c-69f37a3ec717 title="ward_mdy" width="340"> 
<img src=https://github.com/user-attachments/assets/dda7a92d-b517-41c4-83b4-e7a65eb7f5a1 title="ward_mdy_tbl" width="600"> <br/>

Percentage of population who experienced severe or violent intensity in townships of Mandalay <br/>
<img src=https://github.com/user-attachments/assets/34b81666-d45f-44fa-9f2d-c2d468de1ab5 title="tsp_mdy" width="400"> 
<img src=https://github.com/user-attachments/assets/48b6eb95-664a-4bef-8c9f-60ec2e9b5a3b title="tsp_mdy_tbl" width="570"> <br/>

Percentage of population who experienced severe or violent intensity in townships of Sagaing <br/>
<img src=https://github.com/user-attachments/assets/4ce31559-17fb-4e65-a970-1d2c117eb15c title="tsp_sgg" width="400"> 
<img src=https://github.com/user-attachments/assets/9d3a0d14-3e26-4724-a5a1-f05bc20d02cf title="tsp_sgg_tbl" width="570"> <br/>

Percentage of population who experienced severe or violent intensity in townships of Nay Pyi Taw <br/>
<img src=https://github.com/user-attachments/assets/8b7a11d8-c597-4e98-a793-f53fe4ad0ac7 title="tsp_npt" width="400"> 
<img src=https://github.com/user-attachments/assets/a8d4bdf5-92c5-4c9e-83cd-57c0f877fc4d title="tsp_npt_tbl" width="570"> <br/>

Percentage of population who experienced severe or violent intensity in townships of Bago <br/>
<img src=https://github.com/user-attachments/assets/5d1289be-ffe7-494c-8332-dd6d14291c64 title="tsp_bgo" width="400"> 
<img src=https://github.com/user-attachments/assets/e5559152-39ec-46ae-8b98-fd584c665243 title="tsp_bgo_tbl" width="570"> <br/>

### 4.2 Public Website (Canva site)
The results were displayed in Canva site ([Click Here!](https://soehtutaung.my.canva.site/ota-earthquake-tsp)) using Flourish. Screenshots are as below:
<img src=https://github.com/user-attachments/assets/17e3cbc2-5b14-4d1d-a4fa-0999dfdc38a6 title="pg1" width="700"> 
<img src=https://github.com/user-attachments/assets/b5280551-bccd-4d2c-ac9b-1fcfa1693560 title="pg2" width="700"> 
<img src=https://github.com/user-attachments/assets/682bfda6-897a-4c66-8ad4-7a1d0f8b97f7 title="pg3" width="700"> 
