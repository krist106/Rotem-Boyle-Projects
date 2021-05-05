*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 02.28.2020

**********************
*** Clearing the diffrent additional datasets ***
**********************

* The V-Dem file includes dozens of variables. Here I keep the High-Level Democracy Indices, some on gender, and general ones. Also some recoding and droping of observations
cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Country_Year_V-Dem_Full+others_STATA_v9"

use V-Dem-CY-Full+Others-v9.dta, replace

* First, recode the country id to match with dhs coding. DHS on the left, v-dem on the right
* angola 24 = 104
* burundi 108 = 69
* cameroon 120 = 108
* congo democratic republic 180 = 111
* benin 204 = 52
* ethiopia 231 = 38
* ghana 288 = 7
* guinea 324 = 63
* cote d'ivoire 384 = 64
* kenya 404 = 40
* lesotho 426 = 85
* madagascar 450 = 125
* malawi 454 = 87
* mali 466 = 28
* morocco 504 = 90
* mozambique 508 = 57
* namibia 516 = 127
* niger 562 = 60
* nigeria 566 = 45
* rwanda 646 = 129
* senegal 686 = 31
* south africa 710 = 8
* zimbabwe 716 = 62
* uganda 800 = 50
* egypt 818 = 13
* tanzania 834 = 47
* burkina faso 854 = 54
* zambia 894 = 61
* Sudan 729
* Tunisia 788 

recode country_id (104=24) (69=108) (108=120) (111=180) (52=204) (38=231) (7=288) (63=324) (64=384) (40=404) (85=426) (125=450) (87=454) (28=466) (90=504) (57=508) (127=516) (60=562) (45=566) (129=646) (31=686) (8=710) (62=716) (50=800) (13=818) (47=834) (54=854) (61=894) (else = .), gen(country)
label variable country "country id"
order country, after(country_name)
*drop all other countries
drop if country==.

keep country_name country year v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_gender v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen v2x_freexp_altinf ///
e_migdppc e_migdppcln 

rename e_migdppc gdpcap
egen gdpcap_s = std(gdpcap)
label variable gdpcap_s "Standardized values of GDP per capita"
order gdpcap_s, a(gdpcap)

* as our dhs data is from 1990 onward, I am removing earlier observations
drop if year<1986

save 00_v-dem_clean, replace


** Bayesian Corruption Index 2018
** https://users.ugent.be/~sastanda/BCI/BCI.html
cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Bayesian Corruption Index"

use corruption_2018.dta, replace

* First, recode the country id to match with dhs coding. DHS on the left, iso on the right
* 
encode iso, generate(iso_new)

recode iso_new (3=24) (16=108) (41=120) (42=180) (18=204) (66=231) (74=288) (75=324) (40=384) (103=404) (118=426) (125=450) (139=454) (130=466) (123=504) (135=508) (141=516) (143=562) (144=566) (169=646) (173=686) (217=710) (219=716) (203=800) (62=818) (202=834) (19=854) (218=894) (else = .), gen(country)
label variable country "country id"
*drop all other countries
drop if country==.
label variable BCI "Bayesian Corruption Index"
destring BCI, replace
keep country year BCI

save 00_corruption_clean, replace

** Freedom House 
** Data available until 2016
*cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Freedom House"
*clear
*import excel "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Freedom House\FOTP1980-FOTP2017_Public-Data.xlsx", sheet("Data-my edits") firstrow
*rename TotalScore freedom_press
*label variable freedom_press "Freedom of the Press"
*encode freedom_press, gen(nfreedom_press)
*drop Country_name freedom_press
*rename nfreedom_press freedom_press

*save 00_freedom_of_the_press.dta, replace

** Historical Index of Ethnic Fractionalisation Dataset
* Note: 1) Cameroon and Mozambique are missing. 2) I used data from 2013 for 2014 plus
*cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Historical Index of Ethnic Fractionalisation Dataset"
*clear

*import excel "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Historical Index of Ethnic Fractionalisation Dataset\HIEF_data.xlsx", sheet("HIEF_data") firstrow
*drop E F
*label variable ethnic_fractionalisation "Historical Index of Ethnic Fractionalisation"
*drop Country_name
*keep if country < .
*save 00_ethnic_fractionalisation.dta, replace

** Political Terror Scale
*cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Political Terror Scale"
*clear

*use PTS-2019.dta, replace
*gen PTS_max = max(PTS_A, PTS_H, PTS_S)
*label variable PTS_max "Political Terror Scale"

*recode WordBank_Code_A (3=24) (12=108) (41=120) (197=180) (14=204) (56=231) (64=288) (65=324) (34=384) (89=404) (104=426) (111=450) (124=454) (116=466) (108=504) (121=508) (126=516) (127=562) (128=566) (150=646) (153=686) (196=710) (199=716) (183=800) (51=818) (182=834) (15=854) (198=894) (else = .), gen(country)
*label variable country "country id"
*rename Year year
*keep year PTS_max country

*save 00_PTS.dta, replace

** World Bank
cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\World bank\Exports of goods and services (% of GDP)"
clear
import excel exports_of_goods.xlsx, sheet("Data") firstrow
rename Exports_of_goods_and_services exports_of_goods
label variable exports_of_goods "Exports of goods and services (% of GDP)"

* Drop irelevant years and keep African countries
drop if year <1997 | year >2018
keep if country !=.
destring exports_of_goods , replace
sort country year
by country: mipolate exports_of_goods year, gen(iexports_of_goods)
by country: mipolate iexports_of_goods year, gen(mexports_of_goods) backward
label variable mexports_of_goods "Exports of goods and services (% of GDP)"
drop CountryName CountryCode exports_of_goods iexports_of_goods
rename mexports_of_goods exports_of_goods
save 00_exports_of_goods.dta, replace

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\World bank\GDP per capita growth (annual %)"
clear
import excel GDP_per_capita_growth.xlsx, sheet("Data") firstrow
rename GDP_per_capita_growth GDP_growth
label variable GDP_growth "GDP per capita growth (annual %)"
drop CountryName CountryCode
save 00_GDP_per_capita_growth.dta, replace

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\World bank\Imports of goods and services (% of GDP)"
clear
import excel imports_of_goods.xlsx, sheet("Data") firstrow
rename Imports_of_goods imports_of_goods
label variable imports_of_goods "Imports of goods and services (% of GDP)"

* Drop irelevant years and keep African countries
drop if year <1997 | year >2018
keep if country !=.
destring imports_of_goods , replace
sort country year
by country: mipolate imports_of_goods year, gen(iimports_of_goods)
by country: mipolate iimports_of_goods year, gen(mimports_of_goods) backward
label variable mimports_of_goods "Imports of goods and services (% of GDP)"

drop CountryName CountryCode imports_of_goods iimports_of_goods
rename mimports_of_goods imports_of_goods
save 00_imports_of_goods.dta, replace

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\World bank\Oil rents (% of GDP)"
clear
import excel Oil_rents.xlsx, sheet("Data") firstrow
label variable Oil_rents "Oil rents (% of GDP)"
drop CountryName CountryCode
save 00_oil_rents.dta, replace

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\World bank\Refugee population by country or territory of asylum"
clear
import excel refugee_population.xlsx, sheet("Data") firstrow
rename Refugee_population refugee_population
label variable refugee_population "Refugee population by country or territory of asylum"

* Drop irelevant years and keep African countries
drop if year <1997 | year >2018
keep if country !=.
destring refugee_population, replace
sort country year
by country: mipolate refugee_population year, gen(irefugee_population)
by country: mipolate irefugee_population year, gen(mrefugee_population) backward
label variable mrefugee_population "Refugee population by country or territory of asylum"

drop CountryName CountryCode refugee_population irefugee_population
rename mrefugee_population refugee_population
egen refugee_population_s = std(refugee_population)
label variable refugee_population_s "Standardized values of refugee population by country or territory of asylum"
save 00_refugee_population.dta, replace

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Military"
clear
import excel military_indicators_world_bank.xlsx, sheet("Data") firstrow
encode CountryCode, generate(country_id)
recode country_id (3=24) (15=108) (41=120) (42=180) (17=204) (71=231) (82=288) (84=324) (40=384) (120=404) (140=426) (150=450) (167=454) (157=466) (147=504) (164=508) (170=516) (172=562) (173=566) (202=646) (206=686) (262=710) (264=716) (246=800) (66=818) (245=834) (18=854) (263=894) (205=729) (242=788) (else = .), gen(country)
rename MilitaryexpenditureofGDP military_exp
rename Armedforcespersonneltotal armed_total
rename Armedforcespersonneloftot armed_per
label variable country "country id"
destring military_exp , replace
destring armed_per, replace

* Drop irelevant years and keep African countries
drop if year <1997 | year >2018
keep if country !=.

sort country year

by country: mipolate military_exp year, gen(imilitary_exp)
* To cover years that are first in a series, we should use backward
by country: mipolate imilitary_exp year, gen(mmiilitary_exp) backward
label variable mmiilitary_exp "Military expenditure (% of GDP)"

by country: mipolate armed_per year, gen(marmed_per)
label variable marmed_per "Armed forces personall (% of total labor force)"

drop CountryName CountryCode TimeCode country_id armed_total military_exp armed_per imilitary_exp
rename marmed_per armed_per
rename mmiilitary_exp military_exp
order country, a(year)
save 00_military.dta, replace


** Polity Project
*cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\Additional datasets\Polity"
*clear
*import excel p5v2018.xls, sheet("p5v2018") firstrow
*recode ccode (540=24) (516=108) (471=120) (490=180) (434=204) (529=231) (452=288) (438=324) (437=384) (501=404) (570=426) (580=450) (553=454) (432=466) (600=504) (541=508) (565=516) (436=562) (475=566) (517=646) (433=686) (560=710) (552=716) (500=800) (651=818) (510=834) (439=854) (551=894) (else = .), gen(country)
*label variable country "country id"
*order country, after(country_name)
*replace democ=. if democ<-65
*replace autoc=. if autoc<-65
*replace polity2=. if polity2<-65
*keep year country democ autoc polity2
*label variable democ "Institutionalized Democracy, PolityIV"
*label variable autoc "Institutionalized Autocracy, PolityIV"
*label variable polity2 "Combined Polity Score, PolityIV"
*save 00_polity5.dta, replace

