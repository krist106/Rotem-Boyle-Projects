*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

**********************
*** Merge the additional datasets into our dhs file ***
**********************

use "C:\Users\Nir\Documents\Projects\2020\Early_warning\DHS data\05_GIS_merged.dta", replace

merge m:1 country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\Country_Year_V-Dem_Full+others_STATA_v9\00_v-dem_clean.dta", nogen

rename marstat_d married
* After merging, the number of observations jumps a bit.
* To fix it, we can keep only the first 55,529 observations.
sort married
keep in 1/50552
sort country dhsid

drop country_name e_migdppcln

merge m:1 country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\Bayesian Corruption Index\00_corruption_clean.dta", nogen
sort married
keep in 1/50552
sort country dhsid


*merge m:1 country year using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Freedom House\00_freedom_of_the_press.dta", nogen
*sort married
*keep in 1/50552
*sort country dhsid


*merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Historical Index of Ethnic Fractionalisation Dataset\00_ethnic_fractionalisation.dta", nogen
*sort married
*keep in 1/50552
*sort country dhsid

*merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Political Terror Scale\00_PTS.dta", nogen
*sort married
*keep in 1/50552
*sort country dhsid

*merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Polity\00_polity5.dta", nogen
*sort married
*keep in 1/50552
*sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\World bank\Exports of goods and services (% of GDP)\00_exports_of_goods.dta", nogen
sort married
keep in 1/50552
sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\World bank\GDP per capita growth (annual %)\00_GDP_per_capita_growth.dta", nogen
sort married
keep in 1/50552
sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\World bank\Imports of goods and services (% of GDP)\00_imports_of_goods.dta", nogen
sort married
keep in 1/50552
sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\World bank\Oil rents (% of GDP)\00_oil_rents.dta", nogen
sort married
keep in 1/50552
sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\World bank\Refugee population by country or territory of asylum\00_refugee_population.dta", nogen
sort married
keep in 1/50552
sort country dhsid

merge m:m country year using "C:\Users\Nir\Documents\Projects\2020\Early_warning\Additional datasets\Military\00_military.dta", nogen
sort married
keep in 1/50552
sort country dhsid

drop married gdpcap refugee_population

order tv, a(media_access)
order radio, a(tv)
order newspapers, a(radio)
order pastureland, a(cropland)


** Save to a new file
save 06_additional_datasets_merged, replace
