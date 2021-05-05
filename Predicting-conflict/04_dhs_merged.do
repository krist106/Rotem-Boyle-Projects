*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.28.2020

**********************
*** Using merge to merge the different files together ***
**********************

* dhs_women have the highst number of clusters so I think the others should be merged into it
cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 02_dhs_women_collapse.dta, replace

merge m:1 dhsid using 02_dhs_household_collapse1.dta, nogen
merge m:1 dhsid using 02_dhs_household_collapse2.dta, nogen

merge m:1 dhsid using 02_dhs_children_collapse.dta, nogen

*merge m:1 dhsid using 02_dhs_men_collapse.dta, nogen


* we are getting some empty clusters from the household and children marges. By sorting and keeping, we can eliminate it 50,552
sort marstat_d
keep in 1/50552
sort country dhsid

rename five_battles_l1 battles_five_l1
rename five_battles_l2 battles_five_l2
rename five_battles_p1 battles_five_p1

* Order the variables for easy exploration
order _all, alpha
order sample_id, first
order country, a(sample_id)
order year, a(country)
order decades, a(year)
order regions, a(decades)
order idregion_gen, a(regions)
order dhsid, a(idregion_gen)
order battles_l1, a(battles_p1)
order battles_l2, a(battles_l1)
order battles_p1, a(battles_l2)
order battles_five_l1, a(battles_p1)
order battles_five_l2, a(battles_five_l1)
order battles_five_p1, a(battles_five_l2)
order riots_l1, a(battles_five_p1)
order riots_l2, a(riots_l1)
order riots_p1, a(riots_l2)
order civ_violence_l1, a(riots_p1)
order civ_violence_l2, a(civ_violence_l1)
order civ_violence_p1, a(civ_violence_l2)

** Save to a new file
save 04_dhs_merged, replace