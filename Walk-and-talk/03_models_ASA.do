*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***        Not Only a Policy Instrument but a Lived Reality?				***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 07.16.2021

******************** For ASA and paper  ********************


cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear

** Here we limit the file in memory to married or were married women. So in fact, we can remove all the if never_married==0 from the models below
use 02_women.dta if never_married==0


*** Multinomial Logistic Regression ***


drop if age<25

* By religion - simplfied variables - % Muslim
mlogit decoupling ib3.religion_c##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.muslimpc) i.country, base(0)
generate model_sample=e(sample)
estimates store reli_m

*summery table
*install baselinetable
baselinetable urban(cat value(1) novaluelabel countformat(%15.0gc)) ///
wealthq(cat countformat(%15.0gc)) ///
media_access(cat value(1) novaluelabel countformat(%15.0gc)) ///
currwork_d(cat value(1) novaluelabel countformat(%15.0gc)) ///
age(cts novarlabel afterheading("Age, mean (sd)")) ///
educlvl(cat countformat(%15.0gc)) ///
husedlvl(cat countformat(%15.0gc)) ///
religion_c(cat countformat(%15.0gc)) ///
muslimpc(cts novarlabel afterheading("% Muslim, mean (sd)")) ///
waves2(cat novarlabel countformat(%15.0gc)) if model_sample==1, ///
by(decoupling) exportexcel(summery_table, replace)

* To export the mlogit model to a Word document
*outreg2 reli_m using simplfied%muslim, word replace eform sideway label(proper) dec(3)

* By religion - simplfied variables - % Christian
mlogit decoupling ib3.religion_c##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.christianpc) i.country, base(0)
estimates store reli_c

***NOTE that the rrr were dropped 

set scheme cleanplots

*** This will predoce the figure based on the mlogit.
* Option one: significance using * ** ***
coefplot ., keep(walk_notalk:) bylabel("Walking but not talking") || ///
 ., keep(talk_nowalk:) bylabel("Not walking but talking") || ///
 ., keep(neither:) bylabel("Neither walking nor talking") ||, ///
 eform drop(_cons *country *urban *wealthq *educlvl *muslimpc ) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
 nooffset coeflabels(, interaction(" x ")) ///
 headings(1.religion_c#1.media_access = "{bf:Interaction Effects}") ///
  mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span)
*name(test2)

* to remove interaction effects: *religion_c#*media_access *media_access

* Option two: significance in blue, nonsignificant in red
coefplot (., if(@ll<1 & @ul>1)) (., if(@ll>1 | @ul<1)) ., keep(walk_notalk:) bylabel("Walking but not talking") || ///
 (., if(@ll<1 & @ul>1))  (., if(@ll>1 | @ul<1)) ., keep(talk_nowalk:) bylabel("Not walking but talking") || ///
 (., if(@ll<1 & @ul>1))  (., if(@ll>1 | @ul<1)) ., keep(neither:) bylabel("Neither walking nor talking") || ///
 , eform drop(_cons *country *urban *wealthq *educlvl *religion_c#*media_access *media_access *muslimpc) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
 nooffset coeflabels(, interaction(" x ")) ///
 headings(1.religion_c#1.currwork_d = "{bf:Interaction Effects}") ///
 note("Significant coefficients are displayed in blue and nonsignificant coefficients are displayed in red")


* Descriptive statistics:
tab decoupling waves2 if model_sample==1, co

tab decoupling waves2 [iweight=popwt] if model_sample==1, co // Here we use the native POPWT

tab decoupling waves2 [iweight=womwt] if model_sample==1, co // Here we use WOMWT which I created - women age 15-49 in total population


*** Religion over time
tab decoupling religion_c if model_sample==1 & waves2==1, co
tab decoupling religion_c if model_sample==1 & waves2==2, co

xtable decoupling religion_c if model_sample==1 & waves2==1, filename(religion_wave1.xlsx)
xtable decoupling religion_c if model_sample==1 & waves2==2, filename(religion_wave2.xlsx)

*************** To run margins - for predicted probabilities:

********     BY AGE  ********

* Currently working by age over religion
margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(work1) 

margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work2) 


margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of Not Walking but Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work3) 


margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work4) 


grc1leg work1 work2 work3 work4, ycommon cols(2) ysize(40) xsize(80)

* Media access by age over religion
margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(media1) 

margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media2) 


margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of Not Walking but Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media3) 


margins, at(age=(20(10)60) media_access=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media4) 


grc1leg media1 media2 media3 media4, ycommon cols(2) ysize(40) xsize(80)


* Urban by age over religion
margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban1) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban2) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of Not Walking but Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban3) 

margins, at(age=(20(10)60) urban=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban4) 

grc1leg urban1 urban2 urban3 urban4, ycommon cols(2) ysize(40) xsize(80)



******* By % Muslim

* Urban by % Muslim
est restore reli_m
margins, at(muslimpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Urban by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(urban_muspc1) 

margins, at(muslimpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Urban by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(urban_muspc2)

margins, at(muslimpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Urban by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(urban_muspc3)

margins, at(muslimpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Urban by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(urban_muspc4)

grc1leg urban_muspc1 urban_muspc2 urban_muspc3 urban_muspc4, cols(2)
*** ycommon  *** as needed


// Create MEs, using statistical significance

est restore reli_m
mgen if religion_c == 1, dydx(urban) at(muslimpc=(0(10)100)) stub(PrGH0) stats(all) replace
mgen if religion_c == 1, dydx(urban) at(urban=(0 1) muslimpc=(0(10)100)) stub(PrGH0) stats(all) replace

est restore reli_m
mgen if religion_c == 1, dydx(urban) at(muslimpc=(0(10)100)) stub(PrGH0) stats(all) replace
mgen if religion_c == 2, dydx(urban) at(muslimpc=(0(10)100)) stub(PrGH1) stats(all) replace 
mgen if religion_c == 3, dydx(urban) at(muslimpc=(0(10)100)) stub(PrGH2) stats(all) replace 

twoway ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking and talking | Urban) -" "Pr(Walking and talking | Rural)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking and Talking" "for different Religions by Urbanity and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(urban_muspc_1)

twoway ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking but not talking | Urban) -" "Pr(Walking but not talking | Rural)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking but not Talking" "for different Religions by Urbanity and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(urban_muspc_2)

twoway ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Not walking but talking | Urban) -" "Pr(Not walking but talking | Rural)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of not Walking but Talking" "for different Religions by Urbanity and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(urban_muspc_3)

twoway ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Neither walking nor talking | Urban) -" "Pr(Neither walking nor talking | Rural)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of neither Walking nor Talking" "for different Religions by Urbanity and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(urban_muspc_4)

grc1leg urban_muspc_1 urban_muspc_2 urban_muspc_3 urban_muspc_4, cols(2)


* Currently working by % Muslim
est restore reli_m
margins, at(muslimpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Currently Working by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(work_muspc1) 

margins, at(muslimpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Currently Working by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(work_muspc2)

margins, at(muslimpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Currently Working by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(work_muspc3)

margins, at(muslimpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Currently Working by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(work_muspc4)

grc1leg work_muspc1 work_muspc2 work_muspc3 work_muspc4, cols(2)


// Create MEs, using statistical significance

est restore reli_m
mgen if religion_c == 1, dydx(currwork_d) at(muslimpc=(0(10)100)) stub(PrGH0) stats(all) replace
mgen if religion_c == 2, dydx(currwork_d) at(muslimpc=(0(10)100)) stub(PrGH1) stats(all) replace 
mgen if religion_c == 3, dydx(currwork_d) at(muslimpc=(0(10)100)) stub(PrGH2) stats(all) replace 

twoway ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking and talking | Currently working) -" "Pr(Walking and talking | Currently not working)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking and Talking" "for different Religions by Work and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(work_muspc_1)

twoway ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking but not talking | Currently working) -" "Pr(Walking but not talking | Currently not working)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking but not Talking" "for different Religions by Work and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(work_muspc_2)

twoway ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Not walking but talking | Currently working) -" "Pr(Not walking but talking | Currently not working)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of not Walking but Talking" "for different Religions by Work and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(work_muspc_3)

twoway ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Neither walking nor talking | Currently working) -" "Pr(Neither walking nor talking | Currently not working)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of neither Walking nor Talking" "for different Religions by Work and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(work_muspc_4)

grc1leg work_muspc_1 work_muspc_2 work_muspc_3 work_muspc_4, cols(2)

* Media access by % Muslim
est restore reli_m
margins, at(muslimpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Media Access by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(media_muspc1) 

margins, at(muslimpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Media Access by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(media_muspc2)

margins, at(muslimpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Media Access by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(media_muspc3)

margins, at(muslimpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Media Access by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(media_muspc4)

grc1leg media_muspc1 media_muspc2 media_muspc3 media_muspc4, cols(2)


// Create MEs, using statistical significance

est restore reli_m
mgen if religion_c == 1, dydx(media_access) at(muslimpc=(0(10)100)) stub(PrGH0) stats(all) replace
mgen if religion_c == 2, dydx(media_access) at(muslimpc=(0(10)100)) stub(PrGH1) stats(all) replace 
mgen if religion_c == 3, dydx(media_access) at(muslimpc=(0(10)100)) stub(PrGH2) stats(all) replace 

twoway ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr0 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr0 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr0 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking and talking | Has media access) -" "Pr(Walking and talking | No media access)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking and Talking" "for different Religions by Media Access and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(media_muspc_1)

twoway ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr1 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr1 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr1 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Walking but not talking | Has media access) -" "Pr(Walking but not talking | No media access)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of Walking but not Talking" "for different Religions by Media Access and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(media_muspc_2)

twoway ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr2 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr2 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr2 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Not walking but talking | Has media access) -" "Pr(Not walking but talking | No media access)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of not Walking but Talking" "for different Religions by Media Access and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(media_muspc_3)

twoway ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr3 PrGH0muslimpc if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr3 PrGH1muslimpc if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr3 PrGH1muslimpc if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
, legend(order(1 3 5) label(1 "Muslim") label(3 "Christian") label(5 "Hindu")) ///
ytitle("Pr(Neither walking nor talking | Has media access) -" "Pr(Neither walking nor talking | No media access)" , size(*.75) ) ///
xtitle("% Muslim", size(*.75) ) ///
title("Probability of neither Walking nor Talking" "for different Religions by Media Access and % Muslim", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5) name(media_muspc_4)

grc1leg media_muspc_1 media_muspc_2 media_muspc_3 media_muspc_4, cols(2)

* partner's education by % Muslim
est restore reli_m
margins, at(muslimpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Partner's Education by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(hused_muspc1)

margins, at(muslimpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Partner's Education by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(hused_muspc2)

margins, at(muslimpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Partner's Education by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(hused_muspc3)

margins, at(muslimpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Partner's Education by % Muslim and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Muslim", size(*.75) ) ///
ysize(40) xsize(80) name(hused_muspc4)

grc1leg hused_muspc1 hused_muspc2 hused_muspc3 hused_muspc4, cols(2)



******* By % Christian  *********

* Urban by % Christian
est restore reli_c
margins, at(christianpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Urban by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(urban_chrpc1) 

margins, at(christianpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Urban by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(urban_chrpc2)

margins, at(christianpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Urban by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(urban_chrpc3)

margins, at(christianpc=(0(10)100) urban=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Urban by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(urban_chrpc4)

grc1leg urban_chrpc1 urban_chrpc2 urban_chrpc3 urban_chrpc4, cols(2)

grc1leg urban_muspc1 urban_muspc2 urban_muspc3 urban_muspc4 urban_chrpc1 urban_chrpc2 urban_chrpc3 urban_chrpc4, cols(4)


* Currently working by % Christian
est restore reli_c
margins, at(christianpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Currently Working by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(work_chrpc1) 

margins, at(christianpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Currently Working by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(work_chrpc2)

margins, at(christianpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Currently Working by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(work_chrpc3)

margins, at(christianpc=(0(10)100) currwork_d=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Currently Working by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(work_chrpc4)

grc1leg work_chrpc1 work_chrpc2 work_chrpc3 work_chrpc4, cols(2)

grc1leg work_muspc1 work_muspc2 work_muspc3 work_muspc4 work_chrpc1 work_chrpc2 work_chrpc3 work_chrpc4, cols(4)

* Media access by % Christian
est restore reli_c
margins, at(christianpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Media Access by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(media_chrpc1) 

margins, at(christianpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Media Access by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(media_chrpc2)

margins, at(christianpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Media Access by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(media_chrpc3)

margins, at(christianpc=(0(10)100) media_access=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Media Access by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(media_chrpc4)

grc1leg media_chrpc1 media_chrpc2 media_chrpc3 media_chrpc4, cols(2)

grc1leg media_muspc1 media_muspc2 media_muspc3 media_muspc4 media_chrpc1 media_chrpc2 media_chrpc3 media_chrpc4, cols(4)


* partner's education by % Christian
est restore reli_c
margins, at(christianpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Partner's Education by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(hused_chrpc1)

margins, at(christianpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Partner's Education by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(hused_chrpc2)

margins, at(christianpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Partner's Education by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(hused_chrpc3)

margins, at(christianpc=(0(10)100) husedlvl=(0 1 2 3)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Partner's Education by % Christian and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Christian", size(*.75) ) ///
ysize(40) xsize(80) name(hused_chrpc4)

grc1leg hused_chrpc1 hused_chrpc2 hused_chrpc3 hused_chrpc4, cols(2)

grc1leg hused_muspc1 hused_muspc2 hused_muspc3 hused_muspc4 hused_chrpc1 hused_chrpc2 hused_chrpc3 hused_chrpc4, cols(4)



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



mlogit decoupling ib0.mus_chr##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2) i.country, base(0)
estimates store muslim


*table of AMEs, with a group comparison model

* for outcome0
quietly {
est restore reli_m
margins , dydx(urban) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Christian) add
mlincom (3), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(currwork_d) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Christian) add
mlincom (3), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(media_access) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Christian) add
mlincom (3), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(waves2) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Christian) add
mlincom (3), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Hindu-Christian) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+7)) over(religion_c) pr(outcome(0)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Christian) add
mlincom (6-3), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Hindu-Christian) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43)) over(religion_c) pr(outcome(0)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Christian) add
mlincom (6-3), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(wealthq) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC WHQ1: Muslim) add 
mlincom (2), rowname(ADC WHQ1: Christian) add
mlincom (3), rowname(ADC WHQ1: Hindu) add
mlincom (2-1), rowname(ADC WHQ1: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ1: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ1: Diff Hindu-Christian) add

mlincom (4), rowname(ADC WHQ2: Muslim) add 
mlincom (5), rowname(ADC WHQ2: Christian) add
mlincom (6), rowname(ADC WHQ2: Hindu) add
mlincom (5-4), rowname(ADC WHQ2: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC WHQ2: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC WHQ2: Diff Hindu-Christian) add

mlincom (7), rowname(ADC WHQ4: Muslim) add 
mlincom (8), rowname(ADC WHQ4: Christian) add
mlincom (9), rowname(ADC WHQ4: Hindu) add
mlincom (8-7), rowname(ADC WHQ4: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC WHQ4: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC WHQ4: Diff Hindu-Christian) add

mlincom (10), rowname(ADC WHQ5: Muslim) add 
mlincom (11), rowname(ADC WHQ5: Christian) add
mlincom (12), rowname(ADC WHQ5: Hindu) add
mlincom (11-10), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (12-10), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (12-11), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(husedlvl) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Christian) add
mlincom (3), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Hindu-Christian) add

mlincom (4), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (5), rowname(ADC Husb-educ secondary: Christian) add
mlincom (6), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (5-4), rowname(ADC Husb-educ secondary: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Hindu-Christian) add

mlincom (7), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (8), rowname(ADC Husb-educ higher: Christian) add
mlincom (9), rowname(ADC Husb-educ higher: Hindu) add
mlincom (8-7), rowname(ADC Husb-educ higher: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC Husb-educ higher: Diff Hindu-Christian) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome1
quietly {
est restore reli_m
margins, dydx(urban) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Christian) add
mlincom (3), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Hindu-Christian) add

est restore reli_m
margins, dydx(currwork_d) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Christian) add
mlincom (3), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(media_access) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Christian) add
mlincom (3), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(waves2) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Christian) add
mlincom (3), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Hindu-Christian) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+7)) over(religion_c) pr(outcome(1)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Christian) add
mlincom (6-3), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Hindu-Christian) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43)) over(religion_c) pr(outcome(1)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Christian) add
mlincom (6-3), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(wealthq) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC WHQ1: Muslim) add 
mlincom (2), rowname(ADC WHQ1: Christian) add
mlincom (3), rowname(ADC WHQ1: Hindu) add
mlincom (2-1), rowname(ADC WHQ1: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ1: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ1: Diff Hindu-Christian) add

mlincom (4), rowname(ADC WHQ2: Muslim) add 
mlincom (5), rowname(ADC WHQ2: Christian) add
mlincom (6), rowname(ADC WHQ2: Hindu) add
mlincom (5-4), rowname(ADC WHQ2: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC WHQ2: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC WHQ2: Diff Hindu-Christian) add

mlincom (7), rowname(ADC WHQ4: Muslim) add 
mlincom (8), rowname(ADC WHQ4: Christian) add
mlincom (9), rowname(ADC WHQ4: Hindu) add
mlincom (8-7), rowname(ADC WHQ4: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC WHQ4: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC WHQ4: Diff Hindu-Christian) add

mlincom (10), rowname(ADC WHQ5: Muslim) add 
mlincom (11), rowname(ADC WHQ5: Christian) add
mlincom (12), rowname(ADC WHQ5: Hindu) add
mlincom (11-10), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (12-10), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (12-11), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(husedlvl) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Christian) add
mlincom (3), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Hindu-Christian) add

mlincom (4), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (5), rowname(ADC Husb-educ secondary: Christian) add
mlincom (6), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (5-4), rowname(ADC Husb-educ secondary: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Hindu-Christian) add

mlincom (7), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (8), rowname(ADC Husb-educ higher: Christian) add
mlincom (9), rowname(ADC Husb-educ higher: Hindu) add
mlincom (8-7), rowname(ADC Husb-educ higher: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC Husb-educ higher: Diff Hindu-Christian) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome2
quietly {
est restore reli_m
margins, dydx(urban) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Christian) add
mlincom (3), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Hindu-Christian) add

est restore reli_m
margins, dydx(currwork_d) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Christian) add
mlincom (3), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(media_access) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Christian) add
mlincom (3), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(waves2) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Christian) add
mlincom (3), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Hindu-Christian) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+7)) over(religion_c) pr(outcome(2)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Christian) add
mlincom (6-3), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Hindu-Christian) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43)) over(religion_c) pr(outcome(2)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Christian) add
mlincom (6-3), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(wealthq) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC WHQ1: Muslim) add 
mlincom (2), rowname(ADC WHQ1: Christian) add
mlincom (3), rowname(ADC WHQ1: Hindu) add
mlincom (2-1), rowname(ADC WHQ1: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ1: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ1: Diff Hindu-Christian) add

mlincom (4), rowname(ADC WHQ2: Muslim) add 
mlincom (5), rowname(ADC WHQ2: Christian) add
mlincom (6), rowname(ADC WHQ2: Hindu) add
mlincom (5-4), rowname(ADC WHQ2: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC WHQ2: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC WHQ2: Diff Hindu-Christian) add

mlincom (7), rowname(ADC WHQ4: Muslim) add 
mlincom (8), rowname(ADC WHQ4: Christian) add
mlincom (9), rowname(ADC WHQ4: Hindu) add
mlincom (8-7), rowname(ADC WHQ4: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC WHQ4: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC WHQ4: Diff Hindu-Christian) add

mlincom (10), rowname(ADC WHQ5: Muslim) add 
mlincom (11), rowname(ADC WHQ5: Christian) add
mlincom (12), rowname(ADC WHQ5: Hindu) add
mlincom (11-10), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (12-10), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (12-11), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(husedlvl) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Christian) add
mlincom (3), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Hindu-Christian) add

mlincom (4), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (5), rowname(ADC Husb-educ secondary: Christian) add
mlincom (6), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (5-4), rowname(ADC Husb-educ secondary: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Hindu-Christian) add

mlincom (7), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (8), rowname(ADC Husb-educ higher: Christian) add
mlincom (9), rowname(ADC Husb-educ higher: Hindu) add
mlincom (8-7), rowname(ADC Husb-educ higher: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC Husb-educ higher: Diff Hindu-Christian) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome3
quietly {
est restore reli_m
margins, dydx(urban) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Christian) add
mlincom (3), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Hindu-Christian) add

est restore reli_m
margins, dydx(currwork_d) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Christian) add
mlincom (3), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(media_access) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Christian) add
mlincom (3), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(waves2) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Christian) add
mlincom (3), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Hindu-Christian) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+7)) over(religion_c) pr(outcome(3)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Christian) add
mlincom (6-3), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Hindu-Christian) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43)) over(religion_c) pr(outcome(3)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Christian) add
mlincom (6-3), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Christian-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(wealthq) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC WHQ1: Muslim) add 
mlincom (2), rowname(ADC WHQ1: Christian) add
mlincom (3), rowname(ADC WHQ1: Hindu) add
mlincom (2-1), rowname(ADC WHQ1: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ1: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ1: Diff Hindu-Christian) add

mlincom (4), rowname(ADC WHQ2: Muslim) add 
mlincom (5), rowname(ADC WHQ2: Christian) add
mlincom (6), rowname(ADC WHQ2: Hindu) add
mlincom (5-4), rowname(ADC WHQ2: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC WHQ2: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC WHQ2: Diff Hindu-Christian) add

mlincom (7), rowname(ADC WHQ4: Muslim) add 
mlincom (8), rowname(ADC WHQ4: Christian) add
mlincom (9), rowname(ADC WHQ4: Hindu) add
mlincom (8-7), rowname(ADC WHQ4: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC WHQ4: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC WHQ4: Diff Hindu-Christian) add

mlincom (10), rowname(ADC WHQ5: Muslim) add 
mlincom (11), rowname(ADC WHQ5: Christian) add
mlincom (12), rowname(ADC WHQ5: Hindu) add
mlincom (11-10), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (12-10), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (12-11), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m
margins , dydx(husedlvl) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Christian) add
mlincom (3), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Hindu-Christian) add

mlincom (4), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (5), rowname(ADC Husb-educ secondary: Christian) add
mlincom (6), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (5-4), rowname(ADC Husb-educ secondary: Diff Christian-Muslim) add
mlincom (6-4), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Hindu-Christian) add

mlincom (7), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (8), rowname(ADC Husb-educ higher: Christian) add
mlincom (9), rowname(ADC Husb-educ higher: Hindu) add
mlincom (8-7), rowname(ADC Husb-educ higher: Diff Christian-Muslim) add
mlincom (9-7), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (9-8), rowname(ADC Husb-educ higher: Diff Hindu-Christian) add
}

mlincom, twidth(25) title(ADC by religion)

* Interpretation for outcome "margins" : On average, for a specific religion, variable=1 have a xxx higher probability of belonging to outcomeX, compared to variable=0 (check p<0.05, two-tailed test).

* interpretation for outcome "mlincom 2-1" : The gap between variable=1 and variable=0 in belonging to outcomeX is significantly larger among x religion compared to these from y religion (value and value, respectively, 2nd difference: value, p=)."


*** Checking the wealthq as binery - 1/3 vs 4/5 and 1/4 vs 5
recode wealthq (1/4 = 0) (5=1), gen(wealthq_5)
label variable wealthq_5 "Wealthiest qualitie"
quietly mlogit decoupling ib3.religion_c##(i.urban i.wealthq_5 i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.muslimpc) i.country, base(0)
estimates store reli_m1

recode wealthq (1/3 = 0) (4/5 = 1), gen(wealthq_45)
label variable wealthq_45 "Wealthiest qualitie"
quietly mlogit decoupling ib3.religion_c##(i.urban i.wealthq_45 i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.muslimpc) i.country, base(0)
estimates store reli_m2


quietly {
est restore reli_m1
margins , dydx(wealthq_5) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add clear
mlincom (2), rowname(ADC WHQ5: Christian) add
mlincom (3), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m2
margins , dydx(wealthq_45) over(religion_c) pr(outcome(0)) post
mlincom (1), rowname(ADC WHQ45: Muslim) add 
mlincom (2), rowname(ADC WHQ45: Christian) add
mlincom (3), rowname(ADC WHQ45: Hindu) add
mlincom (2-1), rowname(ADC WHQ45: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ45: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ45: Diff Hindu-Christian) add
}
mlincom, twidth(25) title(ADC by religion)

quietly {
est restore reli_m1
margins , dydx(wealthq_5) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add clear
mlincom (2), rowname(ADC WHQ5: Christian) add
mlincom (3), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m2
margins , dydx(wealthq_45) over(religion_c) pr(outcome(1)) post
mlincom (1), rowname(ADC WHQ45: Muslim) add clear
mlincom (2), rowname(ADC WHQ45: Christian) add
mlincom (3), rowname(ADC WHQ45: Hindu) add
mlincom (2-1), rowname(ADC WHQ45: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ45: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ45: Diff Hindu-Christian) add
}
mlincom, twidth(25) title(ADC by religion)

quietly {
est restore reli_m1
margins , dydx(wealthq_5) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add clear
mlincom (2), rowname(ADC WHQ5: Christian) add
mlincom (3), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m2
margins , dydx(wealthq_45) over(religion_c) pr(outcome(2)) post
mlincom (1), rowname(ADC WHQ45: Muslim) add 
mlincom (2), rowname(ADC WHQ45: Christian) add
mlincom (3), rowname(ADC WHQ45: Hindu) add
mlincom (2-1), rowname(ADC WHQ45: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ45: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ45: Diff Hindu-Christian) add
}
mlincom, twidth(25) title(ADC by religion)

quietly {
est restore reli_m1
margins , dydx(wealthq_5) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add clear
mlincom (2), rowname(ADC WHQ5: Christian) add
mlincom (3), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Hindu-Christian) add

est restore reli_m2
margins , dydx(wealthq_45) over(religion_c) pr(outcome(3)) post
mlincom (1), rowname(ADC WHQ45: Muslim) add 
mlincom (2), rowname(ADC WHQ45: Christian) add
mlincom (3), rowname(ADC WHQ45: Hindu) add
mlincom (2-1), rowname(ADC WHQ45: Diff Christian-Muslim) add
mlincom (3-1), rowname(ADC WHQ45: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ45: Diff Hindu-Christian) add
}
mlincom, twidth(25) title(ADC by religion)


************ A figure with the 4 categories of discordance, by country and wave

* ssc install splitvallabels
* findit grc1leg
set scheme plotplain

*label define waves_1 1 "First wave" 2 "Second wave"
*label values waves2 waves_1


splitvallabels waves2, length(6) 
catplot decoupling waves2 if country==50, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Bangladesh" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(bangladesh)


splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==108, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Burundi" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(burundi)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==120, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Cameroon" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(cameroon)


splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==180, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Congo Democratoc Republic" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(congo)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==204, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Benin" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(benin)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==231, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Ethiopia" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(ethiopia)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==288, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Ghana" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(ghana)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==324, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Guinea" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(guinea)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==356, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("India" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(india)

*splitvallabels waves2, length(6)  
*catplot decoupling waves2 if country==400, ///
*percent(waves2) ///
*var1opts(label(labsize(small))) ///
*var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
*ytitle("Level of support", size(small)) ///
*title("Jordan" ///
*, span size(medium)) ///
*intensity(25) ///
*asyvars stack ///
*bar(1, color(maroon) fintensity(inten80)) ///
*bar(2, color(maroon) fintensity(inten60)) ///
*bar(3, color(gray) fintensity(inten40)) ///
*bar(4, color(navy) fintensity(inten60)) ///
*legend(rows(2) stack size(small) ///
*order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
*3 "Supports gender equity/Not empowered in household" ///
*4 "Rejects gender equity/Not empowered in household") ///
*symplacement(center) ///
*title(Discordance , size(small))) name(jordan)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==404, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Kenya" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(kenya)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==426, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Lesotho" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(lesotho)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==450, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Madagascar" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(madagascar)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==454, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Malawi" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(malawi)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==466, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Mali" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(mali)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==508, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Mozambique" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(mozambique)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==516, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Namibia" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(namibia)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==524, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Nepal" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(nepal)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==562, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Niger" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(niger)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==566, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Nigeria" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(nigeria)

*splitvallabels waves2, length(6)  
*catplot decoupling waves2 if country==586, ///
*percent(waves2) ///
*var1opts(label(labsize(small))) ///
*var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
*ytitle("Level of support", size(small)) ///
*title("Pakistan" ///
*, span size(medium)) ///
*intensity(25) ///
*asyvars stack ///
*bar(1, color(maroon) fintensity(inten80)) ///
*bar(2, color(maroon) fintensity(inten60)) ///
*bar(3, color(gray) fintensity(inten40)) ///
*bar(4, color(navy) fintensity(inten60)) ///
*legend(rows(2) stack size(small) ///
*order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
*3 "Supports gender equity/Not empowered in household" ///
*4 "Rejects gender equity/Not empowered in household") ///
*symplacement(center) ///
*title(Discordance , size(small))) name(pakistan)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==646, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Rwanda" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(rwanda)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==686, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Senegal" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(senegal)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==716, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Zimbabwe" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(zimbabwe)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==800, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Uganda" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(uganda)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==818, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Egypt" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(egypt)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==834, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Tanzania" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(tanzania)

splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==854, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Burkina Faso" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(burkina)


splitvallabels waves2, length(6) 
catplot decoupling waves2 if country==894, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)') ) ///
ytitle("Level of support", size(small)) ///
title("Zambia" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(zambia)

grc1leg bangladesh benin burkina burundi cameroon congo egypt ethiopia ghana guinea india kenya lesotho madagascar malawi mali mozambique namibia nepal niger nigeria rwanda senegal tanzania uganda zambia zimbabwe, cols(7)
