*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 00_dhs_household.dta, replace

* Drop non-residents
replace hhresident =. if hhresident==8
keep if hhresident ==1


*1. Any battles in the year of, or the year following, the DHS survey.
*2. Any battles in the year of, or the four years following, the DHS survey.
*3. The number of battles for #1.
*4. The number of battles for #2.

**********************
*** Recode Battles ***
**********************
*Removing missing data - This should be done first to prvent odd additions later on
*  replace battles_1997 = . if battles_1997==-998
* Do the same thing for each year

*With a loop
forvalues i=1997/2018 {
replace battles_`i' = . if battles_`i'==-998
}

** One year lag, total number of battles

*The long way
* gen t_battles_l1 = .
* replace t_battles_l1 = battles_1997 + battles_1998 if year==1997
* replace t_battles_l1 = battles_1998 + battles_1999 if year==1998
* replace t_battles_l1 = battles_1999 + battles_2000 if year==1999
* replace t_battles_l1 = battles_2000 + battles_2001 if year==2000
* replace t_battles_l1 = battles_2001 + battles_2002 if year==2001
* replace t_battles_l1 = battles_2002 + battles_2003 if year==2002
* replace t_battles_l1 = battles_2003 + battles_2004 if year==2003
* replace t_battles_l1 = battles_2004 + battles_2005 if year==2004
* replace t_battles_l1 = battles_2005 + battles_2006 if year==2005
* replace t_battles_l1 = battles_2006 + battles_2007 if year==2006
* replace t_battles_l1 = battles_2007 + battles_2008 if year==2007
* replace t_battles_l1 = battles_2008 + battles_2009 if year==2008
* replace t_battles_l1 = battles_2009 + battles_2010 if year==2009
* replace t_battles_l1 = battles_2010 + battles_2011 if year==2010
* replace t_battles_l1 = battles_2011 + battles_2012 if year==2011
* replace t_battles_l1 = battles_2012 + battles_2013 if year==2012
* replace t_battles_l1 = battles_2013 + battles_2014 if year==2013
* replace t_battles_l1 = battles_2014 + battles_2015 if year==2014
* replace t_battles_l1 = battles_2015 + battles_2016 if year==2015
* replace t_battles_l1 = battles_2016 + battles_2017 if year==2016
* replace t_battles_l1 = battles_2017 + battles_2018 if year==2017
* replace t_battles_l1 = . if t_battles==-998


* Creating the plus year variable
*with a loop
gen battles_tot_l1=.
forvalues i=1997/2017 {
local y=`i'+1
replace battles_tot_l1 = battles_`y' if year==`i'
}
label variable battles_tot_l1 "One year lag total number of battles"
*A safety replace as all missing data was replaced before
replace battles_tot_l1 = . if battles==-998

*Two years lag, total number of battles
*This option sum year 1 and year 2.
* gen t_battles_l2=.
* forvalues i=1997/2016 {
* local a=`i'+1
* local b=`i'+2
* replace t_battles_l2 = battles_`a' + battles_`b' if year==`i'
* }

* This lag does not sum 
gen battles_tot_l2=.
forvalues i=1997/2016 {
    local a=`i'+2
	replace battles_tot_l2 = battles_`a' if year==`i'
}
label variable battles_tot_l2 "Two years lag total number of battles"



*prior battles
gen battles_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace battles_tot_p1 = battles_`y' if year==`i'
}
label variable battles_tot_p1 "One year prior total number of battles"


** Create dichotomous variable for battles
recode battles_tot_l1 (0=0 "no battles") (1/100=1 battles), gen(battles_l1)
label variable battles_l1 "One year lag battles, dummy"

recode battles_tot_l2 (0=0 "no battles") (1/100=1 battles), gen(battles_l2)
label variable battles_l2 "Two years lag battles, dummy"

recode battles_tot_p1 (0=0 "no battles") (1/200=1 battles), gen(battles_p1)
label variable battles_p1 "One year prior battles, dummy"

recode battles_tot_l1 (0/4=0 "no battles") (5/100=1 battles), gen(five_battles_l1)
label variable five_battles_l1 "One year lag, five battles plus, dummy"

recode battles_tot_l2 (0/4=0 "no battles") (5/100=1 battles), gen(five_battles_l2)
label variable five_battles_l2 "Two years lag, five battles plus, dummy"

recode battles_tot_p1 (0/4=0 "no battles") (5/200=1 battles), gen(five_battles_p1)
label variable five_battles_p1 "One year prior, five battles plus, dummy"


* tab sample battles_l1 [aw= hhweight], row
* tab sample battles_p1 [aw= hhweight], row


*** Recode Riots ***
*Removing missing data -

forvalues i=1997/2018 {
replace riots_`i' = . if riots_`i'==-998
}

** One year lag, total number of riots
gen riots_tot_l1=.
forvalues i=1997/2017 {
local y=`i'+1
replace riots_tot_l1 = riots_`y' if year==`i'
}
label variable riots_tot_l1 "One year lag total number of riots"

*Two years lag, total number of riots
*With a loop
gen riots_tot_l2=.
forvalues i=1997/2016 {
local a=`i'+2
replace riots_tot_l2 = riots_`a' if year==`i'
}
label variable riots_tot_l2 "Two years lag total number of riots"

*prior riots
gen riots_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace riots_tot_p1 = riots_`y' if year==`i'
}
label variable riots_tot_p1 "One year prior total number of riots"


** Create dichotomous variable for riots
recode riots_tot_l1 (0=0 "no riots") (1/200=1 riots), gen(riots_l1)
label variable riots_l1 "One year lag riots, dummy"

recode riots_tot_l2 (0=0 "no riots") (1/200=1 riots), gen(riots_l2)
label variable riots_l2 "Two years lag riots, dummy"

recode riots_tot_p1 (0=0 "no riots") (1/750=1 riots), gen(riots_p1)
label variable riots_p1 "One year prior riots, dummy"


*** Recode civ violence ***
*Removing missing data -

forvalues i=1997/2018 {
replace civ_violence_`i' = . if civ_violence_`i'==-998
}

** One year lag, total number of civ_violence
gen civ_violence_tot_l1=.
forvalues i=1997/2017 {
local y=`i'+1
replace civ_violence_tot_l1 = civ_violence_`y' if year==`i'
}
label variable civ_violence_tot_l1 "One year lag total number of acts of violence against civilians"

*Two years lag, total number of civ_violence
*With a loop
gen civ_violence_tot_l2=.
forvalues i=1997/2016 {
local a=`i'+2
replace civ_violence_tot_l2 = civ_violence_`a' if year==`i'
}
label variable civ_violence_tot_l2 "Two years lag total number of acts of violence against civilians"

*prior civ_violence
gen civ_violence_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace civ_violence_tot_p1 = civ_violence_`y' if year==`i'
}
label variable civ_violence_tot_p1 "One year prior total number of acts of violence against civilians"


** Create dichotomous variable for civ_violence
recode civ_violence_tot_l1 (0=0 "no violence against civilians") (1/100=1 "violence against civilians"), gen(civ_violence_l1)
label variable civ_violence_l1 "One year lag violence against civilians, dummy"

recode civ_violence_tot_l2 (0=0 "No violence against civilians") (1/100=1 "violence against civilians"), gen(civ_violence_l2)
label variable civ_violence_l2 "Two year lag violence against civilians, dummy"

recode civ_violence_tot_p1 (0=0 "No violence against civilians") (1/350=1 "violence against civilians"), gen(civ_violence_p1)
label variable civ_violence_p1 "One year prior violence against civilians, dummy"


** Organizing the popdensity variable
replace popdensity = popdensity_2000 if year==1997
replace popdensity = popdensity_2000 if year==1998
replace popdensity = popdensity_2000 if year==1999
replace popdensity = popdensity_2000 if year==2000
replace popdensity = popdensity_2000 if year==2001
replace popdensity = popdensity_2000 if year==2002
replace popdensity = popdensity_2005 if year==2003
replace popdensity = popdensity_2005 if year==2004
replace popdensity = popdensity_2005 if year==2005
replace popdensity = popdensity_2005 if year==2006
replace popdensity = popdensity_2005 if year==2007
replace popdensity = popdensity_2010 if year==2008
replace popdensity = popdensity_2010 if year==2009
replace popdensity = popdensity_2010 if year==2010
replace popdensity = popdensity_2010 if year==2011
replace popdensity = popdensity_2010 if year==2012
replace popdensity = popdensity_2015 if year==2013
replace popdensity = popdensity_2015 if year==2014
replace popdensity = popdensity_2015 if year==2015
replace popdensity = popdensity_2015 if year==2016
replace popdensity = popdensity_2015 if year==2017
replace popdensity = . if popdensity==-998

* gen popdensity_log=log(popdensity)
* label variable popdensity_log "population density logged"
* order popdensity_log, after(popdensity)

egen popdensity_s = std(popdensity)

**we end up not using ndvi, so this can be removed
*rename ndvi_00 keep_ndvi_00
*drop ndvi*
*rename keep_ndvi_00 ndvi_00
*replace ndvi_00 =. if ndvi_00==-998

drop popdensity_2* battles_1* battles_2* riots_1* riots_2* civ_violence_1* civ_violence_2* battles riots civ_violence battles_tot_l1 battles_tot_l2 battles_tot_p1 riots_tot_l1 riots_tot_l2 riots_tot_p1 civ_violence_tot_l1 civ_violence_tot_l2 civ_violence_tot_p1 popdensity

* 1 observation per household
bysort idhshid: gen hhnvals1 = _n == 1 if country !=818
bysort hhid: gen hhnvals2 = _n == 1 if sample==81802
bysort hhid: gen hhnvals3 = _n == 1 if sample==81803
bysort hhid: gen hhnvals4 = _n == 1 if sample==81804
bysort hhid: gen hhnvals5 = _n == 1 if sample==81805
bysort hhid: gen hhnvals6 = _n == 1 if sample==81806
bysort hhid: gen hhnvals7 = _n == 1 if sample==81807
gen hhnvalsmax = max(hhnvals1, hhnvals2, hhnvals3, hhnvals4, hhnvals5, hhnvals6, hhnvals7)
drop hhnvals1 hhnvals2 hhnvals3 hhnvals4 hhnvals5 hhnvals6 hhnvals7

sort sample idhshid

** Save into a new file
save 01_dhs_household_lags, replace
