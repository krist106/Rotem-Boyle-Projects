*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***        Not Only a Policy Instrument but a Lived Reality?				***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 06.20.2020

cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear

** Here we limit the file in memory to married or were married women. So in fact, we can remove all the if never_married==0 from the models below
use 02_women.dta if never_married==0

drop religion_c
recode religion (1000=1) (2000/2999=2) (4000=3) (9998=.) (nonmiss=.), gen(religion_c)
label define reli_c 1 "Muslim" 2 "Christian" 3 "Hindu"
label values religion_c reli_c
label variable religion_c "Religion by categories"
order religion_c, after(religion)


* fix labels
label variable urban "Urban"
label define urban_l 0 "Rural" 1 "Urban"
label values urban urban_l

label define wealthq_l 1 "Household wealth - Poorest" 2 "Household wealth - Poorer" 3 "Household wealth - Middle" ///
4 "Household wealth - Richer" 5 "Household wealth - Richest"
label values wealthq wealthq_l

label define pipedwtr_l 0 "Hadn't own piped water" 1 "Had own piped water"
label values pipedwtr pipedwtr_l
label variable pipedwtr "Had own piped water"

label define media_l 0 "No media access" 1 "Has media access"
label values media_access media_l

label variable currwork_d "Currently working"
label define currwork_i 0 "Currently not working" 1 "Currently working"
label values currwork_d currwork_i

label variable age "Age"

label define c_age_l 1 "Age when married: -15" 2 "Age when married: 16-19" 3 "Age when married: +20"
label values agefrstmar_c c_age_l

label define educlvl_l 0 "Women's edu: None" 1 "Women's edu: Primary" 2 "Women's edu: Secondary" 3 "Women's edu: Higher"
label values educlvl educlvl_l

label define husedlvl_l 0 "Husb-educ none" 1 "Husb-educ primary" 2 "Husb-educ secondary" 3 "Husb-educ higher"
label values husedlvl husedlvl_l

label define edugap_l 0 "Woman has less educ" 1 "Woman have equal edu as partner" 2 "Woman has more educ"
label values edugap edugap_l

label define waves2_l 1 "First wave" 2 "Second wave"
label values waves2 waves2_l

label define decep_l 0 "walk_talk" 1 "walk_notalk" 2 "talk_nowalk" 3 "neither"
label values decoupling decep_l

*** Multinomial Logistic Regression ***


* June 2 2021: By religion


* June 10 - By religion - simplfied variables
mlogit decoupling ib3.religion_c##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2) i.country, base(0)
estimates store reli


set scheme cleanplots


** To run margins - for predicted probabilities:

* Currently working by age over religion
margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(work1) 

margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work2) 


margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work3) 


margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work4) 


grc1leg work1 work2 work3 work4, ycommon cols(2) ysize(40) xsize(80)

* Media access by age over religion
margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(media1) 

margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media2) 


margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media3) 


margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media4) 


grc1leg media1 media2 media3 media4, ycommon cols(2) ysize(40) xsize(80)


* Urban by age over religion
margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban1) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban2) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban3) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban4) 

grc1leg urban1 urban2 urban3 urban4, ycommon cols(2) ysize(40) xsize(80)




* From Tom, create MEs, using statistical significance
mgen if urban == 0, dydx(currwork_d) at(age=(20(10)60)) stub(PrGH0) stats(all) replace 
mgen if urban == 1, dydx(currwork_d) at(age=(20(10)60)) stub(PrGH1) stats(all) replace 

twoway ///
(line PrGH0d_pr2 PrGH0age if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr2 PrGH0age if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr2 PrGH1age if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr2 PrGH1age if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
, legend(order(1 3) label(1 "Rural") label(3 "Urban")) ///
ytitle("Pr(Not walking but talking | Working) -" "Pr(Not walking but talking | Not working)" , size(*.75) ) ///
xtitle("Age", size(*.75) ) ///
title("Probability of not Walking but Talking for working and non-working by Age and residency", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(urban_work7)

grc1leg urban_work5 urban_work6 urban_work7 urban_work8, ycommon cols(2)




* plot probabilities across age, by religion, for outcomes
margins, at(age=(20(5)60)) over(religion_c) pr(outcome(0))
marginsplot, name(model1) title(Walk and talk)

margins, at(age=(20(5)60)) over(religion_c) pr(outcome(1))
marginsplot, name(model2) title(Walking but not talking)

margins, at(age=(20(5)60)) over(religion_c) pr(outcome(2))
marginsplot, name(model3) title(Not walking but talking)

margins, at(age=(20(5)60)) over(religion_c) pr(outcome(3))
marginsplot, name(model4) title(Neither walking nor talking)

grc1leg model1 model2 model3 model4, ycommon cols(2) ysize(40) xsize(80)
