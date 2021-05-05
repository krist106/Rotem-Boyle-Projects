*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 01_dhs_household_legs.dta, replace




**********************
*** Using dhsid and collapse for the household file ***
**********************



* hwchazwho - height for age sd new who
* values from -600 to 600; 9995/6=height and age out of plausible limits; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwchazwho = . if hwchazwho>9994
recode hwchazwho (-199/600=0 no) (-600/-200=1 yes), gen(stuntingnewwho)
label variable stuntingnewwho "stunting as defined by new WHO"

* hwcwhzwho - weight for height sd from reference median new WHO
* values from -500 to 500; 9995/6=height and age out of plausible limits; 9997=flagged cases; 9998/9999missing and not in universe
replace hwcwhzwho = . if hwcwhzwho>9994
recode hwcwhzwho (-199/500=0 no) (-500/-200=1 yes), gen(wastingnewwho)
label variable wastingnewwho "wasting as defined by new WHO"

*recode sex (2=1 female) (1=0 male) (8=.), gen(female)
*label variable female "sex of household member"
*drop sex

replace hhage =. if hhage>96

* education
* edyears - education in completed years
* 0-27; 90-98 don't know / missing (n=36,381)
replace edyears=. if edyears>89
*replace edlevel=. if edlevel>3
*gen woedyears =.
*replace woedyears = edyears if female==1
*label variable woedyears "women's education in completed years"

gen edyears20wm =.
replace edyears20wm = edyears if sex==2 & hhage>19
label variable edyears20wm "women's age 20+ education in completed years"

gen edyears20mn =.
replace edyears20mn = edyears if sex==1 & hhage>19
label variable edyears20mn "men's age 20+ education in completed years"


* Copy variable labels before collapse 
* https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/ 
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

*collapse wealthqhh battles_tot_l1 battles_l1 battles_tot_l2 battles_l2 battles_tot_p1 ///
*battles_p1 stuntingnewwho wastingnewwho popdensity_s five_battles_l1 five_battles_l2 five_battles_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1 woedyears20 menedyears20 pipedwtr cropland pastureland, by(dhsid country year geo*)

collapse stuntingnewwho wastingnewwho edyears20wm edyears20mn, by(dhsid country year)



* Attach the saved labels after collapse - for this to work the original variable names should be kept
foreach v of var * {
        label var `v' "`l`v''"
}


** Save to a new file
save 02_dhs_household_collapse1, replace