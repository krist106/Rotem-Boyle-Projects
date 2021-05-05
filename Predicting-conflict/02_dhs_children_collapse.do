*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 00_dhs_children.dta, replace



**********************
*** Using dhsid and collapse for the children file ***
**********************
* hwwhznchs - weight for height sd from reference median cdc
* values from -400 to 600; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwwhznchs = . if hwwhznchs>9996
recode hwwhznchs (-199/600=0 no) (-400/-200=1 yes), gen(wastingcdc)
label variable wastingcdc "wasting as defined by CDC"

* hwwaznchs - weight for age sd from reference median cdc
* values from -599 to 600; 9997=flagged cases; 9998/9999missing and not in universe
replace hwwaznchs = . if hwwaznchs>9996

* hwhaznchs - height for age sd from reference median cdc
* values from -600 to 600; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwhaznchs =. if hwhaznchs>9996
recode hwhaznchs (-199/600=0 no) (-600/-200=1 yes), gen(stuntingcdc)
label variable stuntingcdc "stunting as defined by CDC"

* hwhazwho - height for age st from median who
* values from -600 to 600; 9995=height out of plausible limits; 9996=age in days out of plausible limits; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwhazwho =. if hwhazwho>9994
recode hwhazwho (-199/600=0 no) (-600/-200=1 yes), gen(stuntingwho)
label variable stuntingwho "stunting as defined by the WHO"

* hwwazwho - weight for age sd from mdeian who
* values from -598 to 500; 9995=height out of plausible limits; 9996=age in days out of plausible limits; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwwazwho =. if hwwazwho>9994


* hwwhzwho - weight for height sd from median who
* values from -500 to 500; 9995=height out of plausible limits; 9996=age in days out of plausible limits; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwwhzwho =. if hwwhzwho>9994
recode hwwhzwho (-199/500=0 no) (-500/-200=1 yes), gen(wastingwho)
label variable wastingwho "wasting as defined by the WHO"

* hwbmizwho - body mass index sd who
* values from -500 to 500; 9995=height out of plausible limits; 9996=age in days out of plausible limits; 9997=flagged cases; 9998/9999=missing and not in universe
replace hwbmizwho =. if hwbmizwho>9994

* brsfedmo - duration of breastfeeding in months
* values from 0 to 60 months; 92=ever breastfed, not currently breastfee; 93=missing: not asked (child died); 94=never breastfed; 96=inconsistent; 97=don't know; 98/99=missing and not in universe
replace brsfedmo =. if brsfedmo>90

* healthcardkid - child has health card
* 10=no card; 11=no longer has card; 21=yes, card seen; 22= yes, card not seen; 23=yes, card seen from health facility; 98/98=missing and not in universe
recode healthcardkid (10/11=0 no) (21/23=1 yes) (98/99=.), gen(healthcardkid_d)
label variable healthcardkid_d "child has health card, dummy"

* Copy variable labels before collapse 
* https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/ 
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

collapse wastingwho stuntingwho, by(dhsid)

* Attach the saved labels after collapse - for this to work the original variable names should be kept
foreach v of var * {
        label var `v' "`l`v''"
}
 
* renaming the variables
* rename (hwwhznchs hwwaznchs hwhaznchs hwhazwho hwwazwho hwwhzwho hwbmizwho brsfedmo di_healthcardkid wastingcdc wastingwho stuntingcdc stuntingwho) (avghwwhznchs avghwwaznchs avghwhaznchs avghwhazwho avghwwazwho avghwwhzwho avghwbmizwho avgbrsfedmo pcthealthcardkid pctwastingcdc pctwastingwho pctstuntingcdc pctstuntingwho)
 
** Save to a new file
save 02_dhs_children_collapse, replace