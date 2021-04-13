*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***        Not Only a Policy Instrument but a Lived Reality?				***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 06.15.2020

cd "C:\Users\Nir\Documents\Projects\2020\RIGS GRPP - Grounded decoupling\IPUMS DHS data"

use idhs_00015.dta, replace

**********************
*** Organizing the women's variables ***
**********************

keep if resident==1


* marstat - women's current marital or union status
* 10=never married; 11=unconsummated marriage; 20=married or living together; 21=married; 22=living together; 31=widowed; 32=divorced; 33=separated-not living together; 98=missing
recode marstat (11/22=1 yes) (98=.) (nonmiss=0 no), gen(marstat_d)
label variable marstat_d "currently married dummy"
order marstat_d, a(marstat)

recode marstat (11/34=0 no) (10=1 yes) (98=.), gen(never_married)
label variable never_married "never married"
order never_married, a(marstat_d)

* agefrstmar - age at first marriage
* range from 0 to 63, with niu of 479,000. As in marstat there are 450,679 who never married, it seems that the never married were classified as niu.
* Following Pierotti 2013, creating categorical variable - first married at age 15 years or younger, married between age 16 and age 19, and age 20 or older
recode agefrstmar (0/15=1) (16/19=2) (20/63=3) (99=.), gen(agefrstmar_c)
label define c_agel 1 "age 15 years or younger" 2 "between age 16 and age 19" 3 "age 20 or older"
label values agefrstmar_c c_agel
label variable agefrstmar_c "age at first marriage or cohabitation by categories"
order agefrstmar_c, a(agefrstmar)

* religion - there are several dozens categories
recode religion (1000=1) (0 2000/9000=0) (9998=.), gen(muslim)
label define musliml 1 "muslim" 0 "non muslim"
label values muslim musliml
label variable muslim "muslim"
order muslim, a(religion)

* currwork - currently working
* 0=no; 10=yes; 11=yes spontaneous; 12= yes prompted; 98=missing; 99=niu
recode currwork (0=0 no) (10/12=1 yes) (98 99 = .), gen(currwork_d)
label variable currwork_d "currently working dummy"
order currwork_d, a(currwork)

* wkemploywhen
gen employment =.
replace employment=0 if currwork_d==0
replace employment=1 if wkemploywhen==10
replace employment=2 if wkemploywhen==23
replace employment=3 if wkemploywhen==24 | wkemploywhen==25
label define employmentl 0 "doesn't work" 1 "all year" 2 "seasonally" 3 "occasionlly"
label values employment employmentl
label variable employment "woman works all year, seasonally, occasionally, or not at all"
order employment, a(currwork_d)

* educlvl - highest educational level
* 0=no education; 1=primary; 2=secondary; 3=higher; 8=missing
replace educlvl=. if educlvl==8

* edyrtotal - women's total years of education
* 0/27=years of education 96=inconsistent; 97=don't know; 98=missing
replace edyrtotal=. if edyrtotal>95

* husedlvl - partner's educational level
* 0=no education; 1=primary; 2=secondary; 3=higher; 4=other; 7=don't know; 8/9=missing and not in universe
replace husedlvl=. if husedlvl>3

* husedyrs - partner's education in total years
* 0/26=years of education; 95=other; 96=inconsistent; 97=don't know; 98/99=missing and not in universe
replace husedyrs =. if husedyrs>94

* Education gap
gen edugap = educlvl - husedlvl
recode edugap (0 = 1) (1/3 = 2) (-3/-1 = 0)
label define edugapl 0 "less" 1 "equal" 2 "more"
label values edugap edugapl
label variable edugap "woman have more education than partner"
order edugap, a(husedyrs)

* drinkwtr - major source of drinking water.
* We can create a dummy variable to see if respondent's house had indoor piped water and use it as a proxy for material living standard - Charles 2019 had a similar item on indoor plumbing. The toilettype variables have too many categories which are non-consistence across samples, so I think it will be impossible to build a 'plumbing' variable
recode drinkwtr (1100 1110 1120 = 1 yes) (1200/6000 = 0 no) (9998=.), gen(pipedwtr)
label variable pipedwtr "had own piped water"

* radiobrig - listens to radio: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing
recode radiobrig (0/2=0 no) (10/12=1 yes) (98=.), gen(radio)
label variable radio "women listen to radio"

* newsbrig - reads newspaper: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing, 99=niu
recode newsbrig (0/2=0 no) (10/12=1 yes) (98/99=.), gen(newspaper)
label variable newspaper "women reads newspapers"

* tvbrig - watches television - bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing
recode tvbrig (0/2=0 no) (10/12=1 yes) (98=.), gen(tv)
label variable tv "women watches television"

* media access - indicates if a woman have a weekly access to radio, newspaper or tv. Pierotti 2013 used a similar variable
gen media_access = max(radio, newspaper, tv)
label variable media_access "women's media access"

*decbighh - final say on making large household purchases
* 10=woman; 20=woman and husband; 30=woman and someone else; 40=husband; 50=someone else; 51=other male; 52=other female; 60=other; 98=missing; 99=niu (n=912,611)
recode decbighh (10/30=1 yes) (40/60=0 no) (98 99 =.), gen(decbighh_d)
label variable decbighh_d "woman have a say in making large household purchases"

* decdailypur - final say on household purchases for daily needs
* the total n is 635,102 with 104,292 niu. Should not be included in the index

* decfamvisit - final say on visits to family or relatives
* 1=woman alone; 2=woman and husband; 3=woman and someone else; 4=husband; 5=someone else; 6=other; 7=family elders; 8=missing; 9=niu (n=917,400)
recode decfamvisit (1/3=1 yes) (4/7=0 no) (8 9 =.), gen(decfamvisit_d)
label variable decfamvisit_d "woman have a say on visits to family or relatives"

* decfemearn - final say on spending woman's earnings
recode decfemearn (10/30=1 yes) (40/60=0 no) (98 99 =.), gen(decfemearn_d)
label variable decfemearn_d "woman have a say on spending woman's earnings"

* decfemhcare - final say on woman's health care
* 1=woman alone; 2=woman and husband; 3=woman and someone else; 4=husband; 5=someone else; 6=other; 7=family elders; 8=missing; 9=niu (n=917,402)
recode decfemhcare (1/3=1 yes) (4/7=0 no) (8 9 =.), gen(decfmhcare_d)
label variable decfmhcare_d "woman have a say on woman's health care"


* Index variable - final say
* generate decindex1= di_decfemearn + di_decbighh + di_decfmhcare + di_decfamvisit
* label variable decindex1 "woman have a final say index"
* label define decl1 0 "never" 1 "seldom" 2 "some of the time" 3 "often" 4 "always"
* label values decindex1 decl1
* Becouse of low N in woman's earnings, this index have only 364,758 cases. The index below without woman's earnings includs 1,069,816 cases


generate decindex= decbighh_d + decfmhcare_d + decfamvisit_d
label variable decindex "woman have a final say index"
label define decl 0 "never" 1 "seldom" 2 "often" 3 "always"
label values decindex decl

recode decindex (2/3=1 yes) (0/1=0 no), gen(decindex_d)
label variable decindex_d "woman has a part in final say"

* sxcanrefuse - woman can refuse sex
* 0=no; 1=yes; 7=maybe; 8/9 are missing and not in universe

generate refusex_d=.
replace refusex_d=1 if sxcanrefuse==1
replace refusex_d=0 if sxcanrefuse==0 | sxcanrefuse==7
label variable refusex_d "woman can refuse sex dummy"
* As the total N is 488,448, I think we may wish to look also on:
* nosexothwf and nosextired
* 0=no; 1=yes; 7=don't know; 8/9 missing and not in universe

recode nosexothwf (1=1 yes) (0 7 =0 no) (8 9 =.), gen(refusex_othwf)
label variable refusex_othwf "okay to refuse sex: husband has other women"
* This variable have 1,734,297 cases

recode nosextired (1=1 yes) (0 7 =0 no) (8 9 =.), gen(refusex_tired)
label variable refusex_tired "okey to refuse sex: tired or not in mood"
* This variable have 1,251,808 cases

* A max variable identify if a woman said yes to any of the above 3 variables, leading to a combined yet dummy variable of if woman can refuse sex. The total N is 1,776,651
gen refusex = max(refusex_d, refusex_othwf, refusex_tired)
label variable refusex "woman can refuse sex, max variable"
label define refusexl 0 "no" 1 "yes"
label values refusex refusexl

* dv attitudes 
* 0=no; 1=yes; 7=don't know; 8/9 are missing and not in universe
* very few 7s, so let's skip them

* Liz, the dvapreshusb and dvapresomale have a large missing (nearly 650,000) - should we count the answers of of women only when no male was present or was not listening?
* Nir, the missing cases would probably cause us to lose all of some Wave 1 women.
generate dvujustargue=.
replace dvujustargue=1 if dvaargue==0 // note that we are reversing the coding
replace dvujustargue=0 if dvaargue==1 // note that we are reversing the coding
label variable dvujustargue "wife beating is unjustified if woman argues with him"

generate dvujustburnfood=.
replace dvujustburnfood=1 if dvaburnfood==0 // note that we are reversing the coding
replace dvujustburnfood=0 if dvaburnfood==1 // note that we are reversing the coding
label variable dvujustburnfood "wife beating is unjustified if woman burns food"

generate dvujustgoout=.
replace dvujustgoout=1 if dvagoout==0 // note that we are reversing the coding
replace dvujustgoout=0 if dvagoout==1 // note that we are reversing the coding
label variable dvujustgoout "wife beating is unjustified if woman goes out without telling him"

generate dvujustifnosex=.
replace dvujustifnosex=1 if dvaifnosex==0 // note that we are reversing the coding
replace dvujustifnosex=0 if dvaifnosex==1 // note that we are reversing the coding
label variable dvujustifnosex "wife beating is unjustified if woman refused to have sex"

generate dvujustnegkid=.
replace dvujustnegkid=1 if dvanegkid==0 // note that we are reversing the coding
replace dvujustnegkid=0 if dvanegkid==1 // note that we are reversing the coding
label variable dvujustnegkid "wife beating is unjustified if woman neglects the children"

* Recode husband or other males present during "wife beating justified" questions
generate dvanymalepres=.
replace dvanymalepres=0 if dvapreshusb==10 | dvapreshusb==22 | dvapresomale==10 | dvapresomale==22
replace dvanymalepres=1 if dvapreshusb==21 | dvapresomale==21
label variable dvanymalepres "any males presnt during `wife beating justified`questions"
label define dvanymalepresl 0 "no" 1 "yes"
label values dvanymalepres dvanymalepresl
order dvanymalepres, a(dvapresofem)

* Index variable
generate dvunjustindex=dvujustargue + dvujustburnfood + dvujustgoout + dvujustifnosex + dvujustnegkid
* Mean of this will be a true mean, ranging from 0-5, reflecting level of justification of beating within the cluster.
label variable dvunjustindex "wife beating unjustified index"
label define dvunjustindexl 0 "never" 1 "seldom" 2 "some of the time" 3 "often" 4 "very often" 5 "always"
label values dvunjustindex dvunjustindexl

recode dvunjustindex (0/2=0 no) (3/5=1 yes), gen(dvunjust_d)
label variable dvunjust_d "agree that wife beating is unjustified"

* build a new 4 cat var - coupling - if wife beating is unjustifed and woman have  0, =1 if dosn't have a final say, ... 0-4

* Our dependent variable - decoupling
generate decoupling=.
replace decoupling=3 if decindex_d==0 & dvunjust_d==0
replace decoupling=2 if decindex_d==0 & dvunjust_d==1
replace decoupling=1 if decindex_d==1 & dvunjust_d==0
replace decoupling=0 if decindex_d==1 & dvunjust_d==1
label variable decoupling "decoupling between wife beating is unjustified and having a final say"
label define decouplingl 3 "wb justified/no part in final say" 2 "wb unjustified/no part in final say" 1 "wb justified/have a part in final say" 0 "wb unjustified/have a part in final say"
label values decoupling decouplingl


recode decoupling (0=0) (3=2) (1/2 = 1), gen(decoupling_3a)
label variable decoupling_3a "decoupling - pro-decoupled"
label define dec3a 0 "wb unjustified/have a part in final say" 2 "wb justified/no part in final say" 1 "decoupled"
label values decoupling_3a dec3a

recode decoupling (0 3 = 1) (1 = 0) (2 = 2), gen(decoupling_3b)
label variable decoupling_3b "decoupling - pro-coupled"
label define dec3b 0 "wb justified/have a part in final say" 2 "wb unjustified/no part in final say" 1 "coupled"
label values decoupling_3b dec3b

* dv events
* 0=no; 1=no; 8=missing; 9=not in universe (n is approximately 350,000)
recode dveever (1=1 yes) (0=0) (8/9=.), gen(dveever_d)
label variable dveever_d "ever any emotional violence"
recode dvpslap (1=1 yes) (0=0) (8/9=.), gen(dvpslap_d)
label variable dvpslap_d "spouse ever slapped"
recode dvppush (1=1 yes) (0=0) (8/9=.), gen(dvppush_d)
label variable dvppush_d "spouse ever pushed"

generate dveventindex=dveever_d + dvpslap_d + dvppush_d
* the total of the dveventany is 411,122. Maybe we shouldn't use it
label variable dveventindex "wife beating experienced index"

* bhcpermit - barrier to woman's health care: getting permission
* 10= not a big problem; 11=no probkem at all; 12=small problem; 20=is big problem; 98/99 missing and not in universe
recode bhcpermit (10/11=0 "not a problem") (12/20=1 "a problem") (98/99=.), gen(bhcpermit_d)
label variable bhcpermit_d "getting permission is a barrier to woman's health care"

recode urban (2 = 0) (1 = 1)
label define urbanl 0 "rural" 1 "urban"
label values urban urbanl

*** Recode battles ***
* Remove missing data with a loop
forvalues i=1997/2018 {
replace battles_`i' = . if battles_`i'==-998
}

*prior battles
gen battles_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace battles_tot_p1 = battles_`y' if year==`i'
}
label variable battles_tot_p1 "One year prior total number of battles"

recode battles_tot_p1 (0=0 "no battles") (1/200=1 battles), gen(d_battles_p1)
label variable d_battles_p1 "One year prior battles, dummy"

drop battle*
rename d_battles_p1 battles_p1

*** Recode Riots ***
*Removing missing data -

forvalues i=1997/2018 {
replace riots_`i' = . if riots_`i'==-998
}

*prior riots
gen riots_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace riots_tot_p1 = riots_`y' if year==`i'
}
label variable riots_tot_p1 "One year prior total number of riots"

recode riots_tot_p1 (0=0 "no riots") (1/750=1 riots), gen(d_riots_p1)
label variable d_riots_p1 "One year prior riots, dummy"

drop riot*
rename d_riots_p1 riots_p1

*** Recode civ violence ***
*Removing missing data -

forvalues i=1997/2018 {
replace civ_violence_`i' = . if civ_violence_`i'==-998
}

*prior civ_violence
gen civ_violence_tot_p1=.
forvalues i=1998/2019 {
local y=`i'-1
replace civ_violence_tot_p1 = civ_violence_`y' if year==`i'
}
label variable civ_violence_tot_p1 "One year prior total number of acts of violence against civilians"

recode civ_violence_tot_p1 (0=0 "no violence against civilians") (1/350=1 "violence against civilians"), gen(d_civ_violence_p1)
label variable d_civ_violence_p1 "One year prior violence against civilians, dummy"

drop civ_violenc*
rename d_civ_violence_p1 civ_violence_p1

*A max variable for political violence
gen polviolence_p1 = max(battles_p1, riots_p1, civ_violence_p1)
label variable polviolence_p1 "exposure to political violence last year"


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

drop popdensity_*

gen popdensity_log=log(popdensity)
label variable popdensity_log "population density logged"
order popdensity_log, after(popdensity)


** Create subnational region variable with labels **

decode(country), gen(ct)
levelsof ct, local(ctstring)

foreach var of varlist geo* {
gen `var'_copy = `var'
}
* drop geo_cm2004_2011_copy
drop geo_gn1999_2012_copy geo_gn2005_2012_copy
drop geoalt_mw2010_2016_copy
drop geoalt_ng2008_2013_copy
replace geo_rw1992_2005_copy = . if year == 2005
* see that rw is ok
* drop geo_tz1991_2015_copy
*drop geo_ug2006_2011_copy
*my change:
drop geo_ug2006_2016_copy
drop geo_jo1990_2017_copy geo_jo2007_2017_copy
***drop geo_eg1988_2014_copy
drop geoalt_eg1988_2014
drop geoalt_ls2004_2014_copy
drop geo_ml1987_2012_copy
drop geo_nm1992_2013_copy
* drop geo_sn2012_2014_copy geo_sn2015_2016_copy
drop geoalt_np1996_2016_copy

foreach var of varlist geo_bd1994_2014-geo_zw1994_2015 {
decode `var', gen(`var'str)
}
* drop geo_cm2004_2011str
drop geo_gn1999_2012str geo_gn2005_2012str
drop geoalt_mw2010_2016str
drop geoalt_ng2008_2013str
replace geo_rw1992_2005str = "" if year == 2005
* drop geo_tz1991_2015str
* drop geo_ug2006_2011str
*my change:
drop geo_ug2006_2016str
drop geo_jo1990_2017str geo_jo2007_2017str
***drop geo_eg1988_2014str
*drop geo_gn1999_2012str
*drop geo_gn2005_2012str
drop geoalt_ls2004_2014str
drop geo_ml1987_2012str
drop geo_nm1992_2013str
* drop geo_sn2012_2014str geo_sn2015_2016str
drop geoalt_np1996_2016str

egen region_temp = rowmax(geo_*_copy geoalt_*_copy)
drop geo_*copy geoalt*_copy

gen subnational = country*100 + region_temp
replace subnational = country*100 if subnational == .


egen region_label_t_gen = concat(geo*str)
gen region_label_gen = ct + " " + substr(region_label_t_gen,1,30)
egen idregion_gen = group(region_label_gen)
label variable idregion_gen "Subnational region identifier - general"

sort subnational
lab def subnational_gen 1 "temp"
levelsof(idregion_gen), local(levels)

foreach l of local levels {
gen temp = ""
replace temp = region_label_gen if idregion_gen == `l'
levelsof(temp), local(templabel)
lab def reg_label_gen `l' `templabel', modify
drop temp
}
label values idregion_gen reg_label_gen
label variable region_label_gen "Full subnational region labels - general"
drop subnational
drop geo*str region_temp
drop region_label_t_gen
rename idregion_gen subnational
label variable subnational "subnational regions"
** End general region creation **

drop idhspsu caseid hhid psu strata domain hhnum clusterno drinkwtr ct region_label_gen newsbrig tvbrig radiobrig decbighh decdailypur decfamvisit decfemearn decfemhcare sxcanrefuse nosexothwf nosextired dvaargue dvaburnfood dvagoout dvaifnosex dvanegkid dveever dvppush dvpslap bhcpermit wkemploywhen

drop geo*

merge m:m dhsid using "C:\Users\Nir\Documents\Projects\2020\RIGS GRPP - Grounded decoupling\IPUMS DHS data\GIS data\master_DHS_GIS.dta", nogen
keep in 1/1926470

order decoupling, a(dvweight)
order decoupling_3a, a(decoupling)
order decoupling_3b, a(decoupling_3a)

generate travel_times_c=.
replace travel_times_c=0 if travel_times==0
replace travel_times_c=1 if travel_times <= 50 & travel_times > 0
replace travel_times_c=2 if travel_times <= 100 & travel_times > 50
replace travel_times_c=3 if travel_times <= 250 & travel_times > 100
replace travel_times_c=4 if travel_times <= 500 & travel_times > 250
replace travel_times_c=5 if travel_times > 500 & travel_times !=.
label define ttl 0 "0 hours" 1 "0-50 hours" 2 "50-100 hours" 3 "100-250 hours" 4 "250-500 hours" 5 "500+ hours"
label values travel_times_c ttl
label variable travel_times_c "Travel time to a settlement of 50,000 or more people, categories"

recode sample (5005 5006 10802 12003 18001 20402 20403 23102 23103 28804 28805 32402 35603 40003 40004 40404 40405 40006 42601 42602 45003 45402 45403 45404 46603 46604  50802 51601 51603 52402 52403 52404 56203 56603 56604 58603 64602 64603 64604 68604 68605 68606 68607 68608 68609 71603 71604 71605 80003 80004 80005 81805 81806 83404 83405 85403 89404 = 0 "previous waves") (nonmiss=1 "last wave"), gen(last_wave)
label variable last_wave "last wave"
order last_wave, a(samplestr)


* Regions of the African Union
* North egypt 818; marocco 504; tunisia 788; 
* Southern angola 24; lesotho 426; malawi 454; mozambique 508; namibia 516; south africa 710; zambia 894; zimbabwe 716
* East ethiopia 231; kenya 404; madagascar 450; rwanda 646; sudan 729; tanzania 834; uganda 800
* West benin 204; burkina faso 854; cote d'ivoire 384; ghana 288; guinea 324; mali 466; niger 562; nigeria 566; senegal 686
* Central burundi 108; cameroon 120; congo democratic republic 180; 
* South Asia Afghanistan 4; Bangladesh 50; India 356; Nepal 524; Pakistan 586; 
* Myanmar 104; Jordan 400. As Jordan doesn't enter into our decoupling variable, I leave it out. Myanmar is added to South Asia.

recode country (818 504 788 = 1 "North Africa") (24 426 454 508 516 710 894 716 = 2 "Southern Africa") (231 404 450 646 729 834 800 = 3 "East Africa") (204 854 384 288 324 466 562 566 686 = 4 "West Africa") (108 120 180 = 5 "Central Africa") (4 50 356 524 586 104 = 6 "South Asia") (nonmiss=.), gen(regions)
label variable regions "Supranational regions"
order regions, a(last_wave)
order subnational, a(country)
* recode year (1986/1996 = 1 "1986 to 1996") (1997/2007 = 2 "1997 to 2007") (2008/2017 = 3 "2008 to 2017"), gen(decades)
* label variable decades "decades of sample"

merge m:m dhsid using "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\gis data\spatial join - prio-grid\master_DHS_spatialjoin.dta", nogen
keep in 1/1926470

label variable capdist "Distance to capital city"
gen capdist_log = log(capdist)
label variable capdist_log "Logged distance to capital city"

drop gid mountains_mean agri_ih barren_ih droughtyr_spi excluded forest_ih pasture_ih savanna_ih shrub_ih urban_ih diamsec_dist diamsec_dist_s petroleum_dist petroleum_dist_s

order capdist, a(urban)
order capdist_log, a(capdist)

** Save to a new file
save 02_women, replace
