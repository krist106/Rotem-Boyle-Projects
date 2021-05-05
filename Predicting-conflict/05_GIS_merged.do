*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 06.01.2020

**********************
*** Merge the GIS datasets - DHS and PRIO-GRID - into our dhs file ***

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\GIS data\all"

** convert the files with the GIS variables to stata files
clear
local myfilelist : dir . files"*.csv"
foreach file of local myfilelist {
drop _all
insheet using `file'
local outfile = subinstr("`file'",".csv","",.)
save "`outfile'", replace
}

** Append all the GIS' fils together
! dir *.dta /a-d /b >filelist.txt

file open myfile using filelist.txt, read

file read myfile line
use `line'
save master_DHS_GIS, replace

file read myfile line
while r(eof)==0 { /* while you're not at the end of the file */
	append using `line'
	file read myfile line
}
file close myfile
save master_DHS_GIS, replace

* recode missing values
replace aridity_2000 = . if aridity_2000==-9999
replace aridity_2005 = . if aridity_2005==-9999
replace aridity_2010 = . if aridity_2010==-9999
replace aridity_2015 = . if aridity_2015==-9999
replace drought_episodes = . if drought_episodes==-9999
replace global_human_footprint = . if global_human_footprint==-9999
*replace nightlights_composite = . if nightlights_composite==-9999
replace proximity_to_national_borders = . if proximity_to_national_borders==-9999
replace travel_times_2000 = . if travel_times_2000==-9999
replace travel_times_2015 = . if travel_times_2015==-9999
replace enhanced_vegetation_index_1995 = . if enhanced_vegetation_index_1995==-9999
replace enhanced_vegetation_index_2000 = . if enhanced_vegetation_index_2000==-9999
replace enhanced_vegetation_index_2005 = . if enhanced_vegetation_index_2005==-9999
replace enhanced_vegetation_index_2010 = . if enhanced_vegetation_index_2010==-9999
replace enhanced_vegetation_index_2015 = . if enhanced_vegetation_index_2015==-9999
duplicates drop dhsid, force

gen aridity =.
replace aridity = aridity_2000 if dhsyear==1997
replace aridity = aridity_2000 if dhsyear==1998
replace aridity = aridity_2000 if dhsyear==1999
replace aridity = aridity_2000 if dhsyear==2000
replace aridity = aridity_2000 if dhsyear==2001
replace aridity = aridity_2000 if dhsyear==2002
replace aridity = aridity_2005 if dhsyear==2003
replace aridity = aridity_2005 if dhsyear==2004
replace aridity = aridity_2005 if dhsyear==2005
replace aridity = aridity_2005 if dhsyear==2006
replace aridity = aridity_2005 if dhsyear==2007
replace aridity = aridity_2010 if dhsyear==2008
replace aridity = aridity_2010 if dhsyear==2009
replace aridity = aridity_2010 if dhsyear==2010
replace aridity = aridity_2010 if dhsyear==2011
replace aridity = aridity_2010 if dhsyear==2012
replace aridity = aridity_2015 if dhsyear==2013
replace aridity = aridity_2015 if dhsyear==2014
replace aridity = aridity_2015 if dhsyear==2015
replace aridity = aridity_2015 if dhsyear==2016
replace aridity = aridity_2015 if dhsyear==2017
label variable aridity "Aridity index"

gen enhanced_vegetation_index =.
replace enhanced_vegetation_index = enhanced_vegetation_index_1995 if dhsyear==1997
replace enhanced_vegetation_index = enhanced_vegetation_index_2000 if dhsyear==1998
replace enhanced_vegetation_index = enhanced_vegetation_index_2000 if dhsyear==1999
replace enhanced_vegetation_index = enhanced_vegetation_index_2000 if dhsyear==2000
replace enhanced_vegetation_index = enhanced_vegetation_index_2000 if dhsyear==2001
replace enhanced_vegetation_index = enhanced_vegetation_index_2000 if dhsyear==2002
replace enhanced_vegetation_index = enhanced_vegetation_index_2005 if dhsyear==2003
replace enhanced_vegetation_index = enhanced_vegetation_index_2005 if dhsyear==2004
replace enhanced_vegetation_index = enhanced_vegetation_index_2005 if dhsyear==2005
replace enhanced_vegetation_index = enhanced_vegetation_index_2005 if dhsyear==2006
replace enhanced_vegetation_index = enhanced_vegetation_index_2005 if dhsyear==2007
replace enhanced_vegetation_index = enhanced_vegetation_index_2010 if dhsyear==2008
replace enhanced_vegetation_index = enhanced_vegetation_index_2010 if dhsyear==2009
replace enhanced_vegetation_index = enhanced_vegetation_index_2010 if dhsyear==2010
replace enhanced_vegetation_index = enhanced_vegetation_index_2010 if dhsyear==2011
replace enhanced_vegetation_index = enhanced_vegetation_index_2010 if dhsyear==2012
replace enhanced_vegetation_index = enhanced_vegetation_index_2015 if dhsyear==2013
replace enhanced_vegetation_index = enhanced_vegetation_index_2015 if dhsyear==2014
replace enhanced_vegetation_index = enhanced_vegetation_index_2015 if dhsyear==2015
replace enhanced_vegetation_index = enhanced_vegetation_index_2015 if dhsyear==2016
replace enhanced_vegetation_index = enhanced_vegetation_index_2015 if dhsyear==2017
label variable enhanced_vegetation_index "Enhanced vegetation index"
egen enhanced_vegetation_index_s = std(enhanced_vegetation_index)
order enhanced_vegetation_index_s, a(enhanced_vegetation_index)

gen travel_times =.
replace travel_times = travel_times_2000 if dhsyear==1997
replace travel_times = travel_times_2000 if dhsyear==1998
replace travel_times = travel_times_2000 if dhsyear==1999
replace travel_times = travel_times_2000 if dhsyear==2000
replace travel_times = travel_times_2000 if dhsyear==2001
replace travel_times = travel_times_2000 if dhsyear==2002
replace travel_times = travel_times_2000 if dhsyear==2003
replace travel_times = travel_times_2000 if dhsyear==2004
replace travel_times = travel_times_2000 if dhsyear==2005
replace travel_times = travel_times_2000 if dhsyear==2006
replace travel_times = travel_times_2000 if dhsyear==2007
replace travel_times = travel_times_2000 if dhsyear==2008
replace travel_times = travel_times_2015 if dhsyear==2008
replace travel_times = travel_times_2015 if dhsyear==2009
replace travel_times = travel_times_2015 if dhsyear==2010
replace travel_times = travel_times_2015 if dhsyear==2011
replace travel_times = travel_times_2015 if dhsyear==2012
replace travel_times = travel_times_2015 if dhsyear==2013
replace travel_times = travel_times_2015 if dhsyear==2014
replace travel_times = travel_times_2015 if dhsyear==2015
replace travel_times = travel_times_2015 if dhsyear==2016
replace travel_times = travel_times_2015 if dhsyear==2017
label variable travel_times "Travel time to a settlement of 50,000 or more people"
egen travel_times_s = std(travel_times)
order travel_times_s, a(travel_times)

egen proximity_to_national_borders_s = std(proximity_to_national_borders)
order proximity_to_national_borders_s, a(proximity_to_national_borders)

keep dhsid enhanced_vegetation_index_s global_human_footprint proximity_to_national_borders_s travel_times_s aridity
save master_DHS_GIS, replace


** merging the GIS's variables to the DHS file
use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\04_dhs_merged.dta", replace
merge m:1 dhsid using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\gis data\all\master_DHS_GIS.dta", nogen

sort country dhsid
keep in 1/50552


save "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\05_GIS_merged", replace


cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\GIS data\spatial join - PRIO-GRID"

** convert the files with the PRIO-GRID variables to stata files
clear
local myfilelist : dir . files"*.csv"
foreach file of local myfilelist {
drop _all
insheet using `file'
local outfile = subinstr("`file'",".csv","",.)
save "`outfile'", replace
}

** Append all the PRIO-GRID fils together
! dir *.dta /a-d /b >filelist.txt

file open myfile using filelist.txt, read

file read myfile line
use `line'
save master_DHS_spatialjoin, replace

file read myfile line
while r(eof)==0 { /* while you're not at the end of the file */
	append using `line'
	file read myfile line
}
file close myfile
save master_DHS_spatialjoin, replace


* Missing values - there aren't any
* The distances to diamond and petroleum were in meter. I am converting it into kilometers. I was thinking to run a log transformation but we have many zeros (0) which log turns into missing values. Why we got zeros? Becouse some observations are located within a grid cell that contains diamonds or oil.
replace diamsec_dist = diamsec_dist/1000
egen petroleum_dist_s = std(petroleum_dist)
order petroleum_dist_s, a(petroleum_dist)

replace petroleum_dist = petroleum_dist/1000
egen diamsec_dist_s = std(diamsec_dist)
order diamsec_dist_s, a(diamsec_dist)

drop objectid join_count target_fid dhscc dhsyear dhsclust ccfips adm1fips adm1fipsna adm1salbna adm1salbco adm1dhs adm1name dhsregco dhsregna source urban_rura latnum longnum alt_gps alt_dem datum diamsec_s diamsec_y diamsec_all petroleum_s petroleum_y petroleum_all diamsec_fid petroleum_fid gid agri_ih barren_ih capdist forest_ih pasture_ih savanna_ih shrub_ih urban_ih diamsec_dist petroleum_dist

duplicates drop dhsid, force

recode excluded (0=0) (1/4=1)

save master_DHS_spatialjoin, replace

** Merging the PRIO-GRID variables to the DHS file
use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\05_GIS_merged", replace
merge m:1 dhsid using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\gis data\spatial join - prio-grid\master_DHS_spatialjoin.dta", nogen

sort country dhsid
keep in 1/50552

label variable mountains_mean "Proportion of mountainous terrain"
label variable droughtyr_spi "Drought"
label variable excluded "Number of excluded groups"
label variable diamsec_dist_s "Standardized values of distance to nearest secondary diamond resource"
label variable petroleum_dist_s "Standardized values of distance to nearest petroleum resource"
label variable travel_times_s "Standardized values of travel time to a settlement of 50,000 or more people"
label variable enhanced_vegetation_index_s "Standardized values of enhanced vegetation index"


save "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\05_GIS_merged", replace
