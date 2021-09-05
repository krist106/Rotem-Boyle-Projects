*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***      				  Walking and talking 								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 07.16.2021

******************** For paper 1  ********************


cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear

** Here we limit the file in memory to married or were married women. So in fact, we can remove all the if never_married==0 from the models below
use 02_women.dta 

keep if ever_married==1


*** Multinomial Logistic Regression ***


drop if age<25

* By religion - simplfied variables - % Muslim
mlogit decoupling ib4.religion_4c##(i.urban i.wealthq_5 i.media_access i.currwork_d c.age i.edugap i.waves2 c.muslimpc) i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store reli_m

mlogit decoupling i.educlvl i.media_access i.urban i.wealthq_5 i.currwork_d ib1.edugap c.age c.de2pc c.muslimpc i.waves2 i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store mo1

mlogit decoupling i.educlvl i.media_access i.urban ib3.wealthq i.currwork_d ib1.edugap c.age c.de2pc c.muslimpc i.waves2 i.country [pw=popwt], base(0)
estimates store mo2

* To export the mlogit model to a Word document
*outreg2 reli_m using simplfied%muslim1, word replace eform sideway label(proper) dec(3)
*Use this one:
esttab reli_m using simplfied%muslim3.rtf, eform label wide unstack replace se(3)
esttab mo1 using model1.rtf, noomitted eform label wide unstack replace se(3)
esttab mo2 using model2.rtf, noomitted eform label wide unstack replace se(3)

set scheme cleanplots

*** This will predoce the figure based on the mlogit.
* Option one: significance using * ** ***
coefplot ., keep(walk_notalk:) bylabel("Walking but not talking") || ///
 ., keep(talk_nowalk:) bylabel("Not walking but talking") || ///
 ., keep(neither:) bylabel("Neither walking nor talking") ||, ///
 eform drop(_cons *country *urban *wealthq *muslimpc ) ///
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



*table of AMEs, with a group comparison model

* for outcome0
quietly {
est restore reli_m
margins , dydx(urban) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Catholic) add
mlincom (3), rowname(ADC Urban: Protestant) add
mlincom (4), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Urban: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Urban: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(currwork_d) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Catholic) add
mlincom (3), rowname(ADC Working: Protestant) add
mlincom (4), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Working: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Working: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(media_access) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Catholic) add
mlincom (3), rowname(ADC Media: Protestant) add
mlincom (4), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Media: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Media: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(waves2) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Catholic) add
mlincom (3), rowname(ADC Wave2: Protestant) add
mlincom (4), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Wave2: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Wave2: Diff Hindu-Protestant) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(religion_4c) pr(outcome(0)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Catholic) add
mlincom (6-3), rowname(ADC age SD: Protestant) add
mlincom (8-4), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC age SD: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC age SD: Diff Hindu-Protestant) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43.4)) over(religion_4c) pr(outcome(0)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Catholic) add
mlincom (6-3), rowname(ADC % Muslim: Protestant) add
mlincom (8-4), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC % Muslim: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC % Muslim: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(wealthq_5) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add
mlincom (2), rowname(ADC WHQ5: Catholic) add
mlincom (3), rowname(ADC WHQ5: Protestant) add
mlincom (4), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC WHQ5: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC WHQ5: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(husedlvl) over(religion_4c) pr(outcome(0)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Catholic) add
mlincom (3), rowname(ADC Husb-educ primary: Protestant) add
mlincom (4), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Husb-educ primary: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Husb-educ primary: Diff Hindu-Protestant) add

mlincom (5), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (6), rowname(ADC Husb-educ secondary: Catholic) add
mlincom (7), rowname(ADC Husb-educ secondary: Protestant) add
mlincom (8), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Catholic-Muslim) add
mlincom (7-5), rowname(ADC Husb-educ secondary: Diff Protestant-Muslim) add
mlincom (8-5), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (7-6), rowname(ADC Husb-educ secondary: Diff Protestant-Catholic) add
mlincom (8-6), rowname(ADC Husb-educ secondary: Diff Hindu-Catholic) add
mlincom (8-7), rowname(ADC Husb-educ secondary: Diff Hindu-Protestant) add

mlincom (9), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (10), rowname(ADC Husb-educ higher: Catholic) add
mlincom (11), rowname(ADC Husb-educ higher: Protestant) add
mlincom (12), rowname(ADC Husb-educ higher: Hindu) add
mlincom (10-9), rowname(ADC Husb-educ higher: Diff Catholic-Muslim) add
mlincom (11-9), rowname(ADC Husb-educ higher: Diff Protestant-Muslim) add
mlincom (12-9), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (11-10), rowname(ADC Husb-educ higher: Diff Protestant-Catholic) add
mlincom (12-10), rowname(ADC Husb-educ higher: Diff Hindu-Catholic) add
mlincom (12-11), rowname(ADC Husb-educ higher: Diff Hindu-Protestant) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome1
quietly {
est restore reli_m
margins , dydx(urban) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Catholic) add
mlincom (3), rowname(ADC Urban: Protestant) add
mlincom (4), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Urban: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Urban: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(currwork_d) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Catholic) add
mlincom (3), rowname(ADC Working: Protestant) add
mlincom (4), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Working: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Working: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(media_access) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Catholic) add
mlincom (3), rowname(ADC Media: Protestant) add
mlincom (4), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Media: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Media: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(waves2) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Catholic) add
mlincom (3), rowname(ADC Wave2: Protestant) add
mlincom (4), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Wave2: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Wave2: Diff Hindu-Protestant) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(religion_4c) pr(outcome(1)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Catholic) add
mlincom (6-3), rowname(ADC age SD: Protestant) add
mlincom (8-4), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC age SD: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC age SD: Diff Hindu-Protestant) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43.4)) over(religion_4c) pr(outcome(1)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Catholic) add
mlincom (6-3), rowname(ADC % Muslim: Protestant) add
mlincom (8-4), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC % Muslim: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC % Muslim: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(wealthq_5) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add
mlincom (2), rowname(ADC WHQ5: Catholic) add
mlincom (3), rowname(ADC WHQ5: Protestant) add
mlincom (4), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC WHQ5: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC WHQ5: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(husedlvl) over(religion_4c) pr(outcome(1)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Catholic) add
mlincom (3), rowname(ADC Husb-educ primary: Protestant) add
mlincom (4), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Husb-educ primary: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Husb-educ primary: Diff Hindu-Protestant) add

mlincom (5), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (6), rowname(ADC Husb-educ secondary: Catholic) add
mlincom (7), rowname(ADC Husb-educ secondary: Protestant) add
mlincom (8), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Catholic-Muslim) add
mlincom (7-5), rowname(ADC Husb-educ secondary: Diff Protestant-Muslim) add
mlincom (8-5), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (7-6), rowname(ADC Husb-educ secondary: Diff Protestant-Catholic) add
mlincom (8-6), rowname(ADC Husb-educ secondary: Diff Hindu-Catholic) add
mlincom (8-7), rowname(ADC Husb-educ secondary: Diff Hindu-Protestant) add

mlincom (9), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (10), rowname(ADC Husb-educ higher: Catholic) add
mlincom (11), rowname(ADC Husb-educ higher: Protestant) add
mlincom (12), rowname(ADC Husb-educ higher: Hindu) add
mlincom (10-9), rowname(ADC Husb-educ higher: Diff Catholic-Muslim) add
mlincom (11-9), rowname(ADC Husb-educ higher: Diff Protestant-Muslim) add
mlincom (12-9), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (11-10), rowname(ADC Husb-educ higher: Diff Protestant-Catholic) add
mlincom (12-10), rowname(ADC Husb-educ higher: Diff Hindu-Catholic) add
mlincom (12-11), rowname(ADC Husb-educ higher: Diff Hindu-Protestant) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome2
quietly {
est restore reli_m
margins , dydx(urban) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Catholic) add
mlincom (3), rowname(ADC Urban: Protestant) add
mlincom (4), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Urban: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Urban: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(currwork_d) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Catholic) add
mlincom (3), rowname(ADC Working: Protestant) add
mlincom (4), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Working: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Working: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(media_access) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Catholic) add
mlincom (3), rowname(ADC Media: Protestant) add
mlincom (4), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Media: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Media: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(waves2) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Catholic) add
mlincom (3), rowname(ADC Wave2: Protestant) add
mlincom (4), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Wave2: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Wave2: Diff Hindu-Protestant) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(religion_4c) pr(outcome(2)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Catholic) add
mlincom (6-3), rowname(ADC age SD: Protestant) add
mlincom (8-4), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC age SD: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC age SD: Diff Hindu-Protestant) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43.4)) over(religion_4c) pr(outcome(2)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Catholic) add
mlincom (6-3), rowname(ADC % Muslim: Protestant) add
mlincom (8-4), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC % Muslim: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC % Muslim: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(wealthq_5) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add
mlincom (2), rowname(ADC WHQ5: Catholic) add
mlincom (3), rowname(ADC WHQ5: Protestant) add
mlincom (4), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC WHQ5: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC WHQ5: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(husedlvl) over(religion_4c) pr(outcome(2)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Catholic) add
mlincom (3), rowname(ADC Husb-educ primary: Protestant) add
mlincom (4), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Husb-educ primary: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Husb-educ primary: Diff Hindu-Protestant) add

mlincom (5), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (6), rowname(ADC Husb-educ secondary: Catholic) add
mlincom (7), rowname(ADC Husb-educ secondary: Protestant) add
mlincom (8), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Catholic-Muslim) add
mlincom (7-5), rowname(ADC Husb-educ secondary: Diff Protestant-Muslim) add
mlincom (8-5), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (7-6), rowname(ADC Husb-educ secondary: Diff Protestant-Catholic) add
mlincom (8-6), rowname(ADC Husb-educ secondary: Diff Hindu-Catholic) add
mlincom (8-7), rowname(ADC Husb-educ secondary: Diff Hindu-Protestant) add

mlincom (9), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (10), rowname(ADC Husb-educ higher: Catholic) add
mlincom (11), rowname(ADC Husb-educ higher: Protestant) add
mlincom (12), rowname(ADC Husb-educ higher: Hindu) add
mlincom (10-9), rowname(ADC Husb-educ higher: Diff Catholic-Muslim) add
mlincom (11-9), rowname(ADC Husb-educ higher: Diff Protestant-Muslim) add
mlincom (12-9), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (11-10), rowname(ADC Husb-educ higher: Diff Protestant-Catholic) add
mlincom (12-10), rowname(ADC Husb-educ higher: Diff Hindu-Catholic) add
mlincom (12-11), rowname(ADC Husb-educ higher: Diff Hindu-Protestant) add
}

mlincom, twidth(25) title(ADC by religion)

* for outcome3
quietly {
est restore reli_m
margins , dydx(urban) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC Urban: Muslim) add clear
mlincom (2), rowname(ADC Urban: Catholic) add
mlincom (3), rowname(ADC Urban: Protestant) add
mlincom (4), rowname(ADC Urban: Hindu) add
mlincom (2-1), rowname(ADC Urban: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Urban: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Urban: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Urban: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Urban: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(currwork_d) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC Working: Muslim) add
mlincom (2), rowname(ADC Working: Catholic) add
mlincom (3), rowname(ADC Working: Protestant) add
mlincom (4), rowname(ADC Working: Hindu) add
mlincom (2-1), rowname(ADC Working: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Working: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Working: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Working: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Working: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Working: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(media_access) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC Media: Muslim) add 
mlincom (2), rowname(ADC Media: Catholic) add
mlincom (3), rowname(ADC Media: Protestant) add
mlincom (4), rowname(ADC Media: Hindu) add
mlincom (2-1), rowname(ADC Media: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Media: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Media: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Media: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Media: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(waves2) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC Wave2: Muslim) add 
mlincom (2), rowname(ADC Wave2: Catholic) add
mlincom (3), rowname(ADC Wave2: Protestant) add
mlincom (4), rowname(ADC Wave2: Hindu) add
mlincom (2-1), rowname(ADC Wave2: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Wave2: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Wave2: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Wave2: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Wave2: Diff Hindu-Protestant) add

est restore reli_m
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(religion_4c) pr(outcome(3)) post
mlincom (4-1), rowname(ADC age SD: Muslim) add
mlincom (5-2), rowname(ADC age SD: Catholic) add
mlincom (6-3), rowname(ADC age SD: Protestant) add
mlincom (8-4), rowname(ADC age SD: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC age SD: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC age SD: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC age SD: Diff Hindu-Protestant) add

est restore reli_m
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+43.4)) over(religion_4c) pr(outcome(3)) post
mlincom (4-1), rowname(ADC % Muslim: Muslim) add
mlincom (5-2), rowname(ADC % Muslim: Catholic) add
mlincom (6-3), rowname(ADC % Muslim: Protestant) add
mlincom (8-4), rowname(ADC % Muslim: Hindu) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Catholic-Muslim) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff Protestant-Muslim) add
mlincom (8-4)-(4-1), rowname(ADC % Muslim: Diff Hindu-Muslim) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff Protestant-Catholic) add
mlincom (8-4)-(5-2), rowname(ADC % Muslim: Diff Hindu-Catholic) add
mlincom (8-4)-(6-3), rowname(ADC % Muslim: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(wealthq_5) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC WHQ5: Muslim) add
mlincom (2), rowname(ADC WHQ5: Catholic) add
mlincom (3), rowname(ADC WHQ5: Protestant) add
mlincom (4), rowname(ADC WHQ5: Hindu) add
mlincom (2-1), rowname(ADC WHQ5: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC WHQ5: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC WHQ5: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC WHQ5: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC WHQ5: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC WHQ5: Diff Hindu-Protestant) add

est restore reli_m
margins , dydx(husedlvl) over(religion_4c) pr(outcome(3)) post
mlincom (1), rowname(ADC Husb-educ primary: Muslim) add 
mlincom (2), rowname(ADC Husb-educ primary: Catholic) add
mlincom (3), rowname(ADC Husb-educ primary: Protestant) add
mlincom (4), rowname(ADC Husb-educ primary: Hindu) add
mlincom (2-1), rowname(ADC Husb-educ primary: Diff Catholic-Muslim) add
mlincom (3-1), rowname(ADC Husb-educ primary: Diff Protestant-Muslim) add
mlincom (4-1), rowname(ADC Husb-educ primary: Diff Hindu-Muslim) add
mlincom (3-2), rowname(ADC Husb-educ primary: Diff Protestant-Catholic) add
mlincom (4-2), rowname(ADC Husb-educ primary: Diff Hindu-Catholic) add
mlincom (4-3), rowname(ADC Husb-educ primary: Diff Hindu-Protestant) add

mlincom (5), rowname(ADC Husb-educ secondary: Muslim) add 
mlincom (6), rowname(ADC Husb-educ secondary: Catholic) add
mlincom (7), rowname(ADC Husb-educ secondary: Protestant) add
mlincom (8), rowname(ADC Husb-educ secondary: Hindu) add
mlincom (6-5), rowname(ADC Husb-educ secondary: Diff Catholic-Muslim) add
mlincom (7-5), rowname(ADC Husb-educ secondary: Diff Protestant-Muslim) add
mlincom (8-5), rowname(ADC Husb-educ secondary: Diff Hindu-Muslim) add
mlincom (7-6), rowname(ADC Husb-educ secondary: Diff Protestant-Catholic) add
mlincom (8-6), rowname(ADC Husb-educ secondary: Diff Hindu-Catholic) add
mlincom (8-7), rowname(ADC Husb-educ secondary: Diff Hindu-Protestant) add

mlincom (9), rowname(ADC Husb-educ higher: Muslim) add 
mlincom (10), rowname(ADC Husb-educ higher: Catholic) add
mlincom (11), rowname(ADC Husb-educ higher: Protestant) add
mlincom (12), rowname(ADC Husb-educ higher: Hindu) add
mlincom (10-9), rowname(ADC Husb-educ higher: Diff Catholic-Muslim) add
mlincom (11-9), rowname(ADC Husb-educ higher: Diff Protestant-Muslim) add
mlincom (12-9), rowname(ADC Husb-educ higher: Diff Hindu-Muslim) add
mlincom (11-10), rowname(ADC Husb-educ higher: Diff Protestant-Catholic) add
mlincom (12-10), rowname(ADC Husb-educ higher: Diff Hindu-Catholic) add
mlincom (12-11), rowname(ADC Husb-educ higher: Diff Hindu-Protestant) add
}

mlincom, twidth(25) title(ADC by religion)

* Interpretation for outcome "margins" : On average, for a specific religion, variable=1 have a xxx higher probability of belonging to outcomeX, compared to variable=0 (check p<0.05, two-tailed test).

* interpretation for outcome "mlincom 2-1" : The gap between variable=1 and variable=0 in belonging to outcomeX is significantly larger among x religion compared to these from y religion (value and value, respectively, 2nd difference: value, p=)."


/*
*** If using the normal wealthhq

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

*/

*************** To run margins - for predicted probabilities:

** We ran these and didn't see much evidence of interaction effects

********     BY AGE  ********

* Currently working by age over religion

/*margins, at(age=(20(10)60) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
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


// Create marginal effects, using statistical significance
* Interaction with percent Muslim

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
*/

