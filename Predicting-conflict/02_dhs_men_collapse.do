*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 00_dhs_men.dta, replace

keep if resident==1

**********************
*** Using dhsid and collapse for men ***
**********************


* currworkmn - currently working for men
* 0=no; 1=yes; 8=missing
* the total is 429,897 - maybe we shouldn't use it
replace currworkmn =. if currworkmn==8
label variable currworkmn "currently working men"


* wkearntype
recode wkearntypemn (0 3 =0) (1 2 =1) (8/9 =.), gen(paidcashmn)
label define paidcashl 0 "not paid in cash" 1 "paid in cash"
label values paidcashmn paidcashl
label variable paidcashmn "men paid in cash"

gen laborforcemn =.
replace laborforcemn=0 if currworkmn==0
replace laborforcemn=0 if currworkmn==1 & paidcashmn==0
replace laborforcemn=1 if currworkmn==1 & paidcashmn==1
label define laborforcemnl 0 "men unengaged in the labor force" 1 "men engaged in the labor force"
label values laborforcemn laborforcemnl
label variable laborforcemn "men engagment in the labor force"




* educlvlmn - highest educational level for men
* 0=no education; 1=primary; 2=secondary; 3=higher; 6=other; 8=missing
* the total is 441,154

recode educlvl (0=0 no) (8=.) (nonmiss=1 yes), gen(anyeducationmn)
label variable anyeducation "any education men"


* edyrtotalmn - men's total years of education
* 0/25=years of educational; 95=other; 97=don't know; 98=missing
* the total is 440,163

replace edyrtotalmn=. if edyrtotalmn>94



* Copy variable labels before collapse 
* https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/ 
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}

collapse currworkmn paidcashmn laborforcemn, by(dhsid)

* Attach the saved labels after collapse - for this to work the original variable names should be kept
foreach v of var * {
        label var `v' "`l`v''"
}



** Save into a new file
save 02_dhs_men_collapse, replace