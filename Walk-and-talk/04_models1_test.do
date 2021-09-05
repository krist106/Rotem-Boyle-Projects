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

* Set a small sample

*use 02_women.dta if ever_married==1

*drop if age <25

*mlogit decoupling ib3.religion_c##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.muslimpc) i.country, base(0)
*estimates store reli
*generate newver=e(sample)

*drop if newver ==0

*sample 2, by(decoupling religion)

*save 02_women_random_sample, replace


use 02_women_random_sample

mlogit decoupling ib3.religion_c##(i.urban ib3.wealthq i.media_access i.currwork_d c.age i.educlvl i.husedlvl i.waves2 c.muslimpc) i.country, base(0)
estimates store reli

set scheme cleanplots


* Tom, here are a couple of code lines that I addapted from your do.file

* create MEs, using statistical significance
est restore reli
mgen if urban == 0, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH0) stats(all) replace 
mgen if urban == 1, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH1) stats(all) replace 

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
xsize(20) ysize(12.5)
* name(urban_work7)
* As our mlogit target variable is decoulping (with 4 categories), I can just change the pr and rerun this code 4 times, and combine the four figures

* Here I am testing running a similar model, just when one of the variables have more categories (educlvl = education level)
est restore reli
mgen if educlvl == 0, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH0) stats(all) replace 
mgen if educlvl == 1, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH1) stats(all) replace 
mgen if educlvl == 2, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH2) stats(all) replace 
mgen if educlvl == 3, dydx(currwork_d) at(age=(25(5)50)) stub(PrGH3) stats(all) replace 

twoway ///
(line PrGH0d_pr2 PrGH0age if PrGH0pval1 , color(blue) lpattern(longdash) )   ///
(line PrGH0d_pr2 PrGH0age if PrGH0pval1 < 0.05, color(blue) lpattern(solid) ) ///
(line PrGH1d_pr2 PrGH1age if PrGH1pval1 , color(red) lpattern(longdash) )   ///
(line PrGH1d_pr2 PrGH1age if PrGH1pval1 < 0.05, color(red) lpattern(solid) ) ///
(line PrGH2d_pr2 PrGH1age if PrGH2pval1 , color(green) lpattern(longdash) )   ///
(line PrGH2d_pr2 PrGH1age if PrGH2pval1 < 0.05, color(green) lpattern(solid) ) ///
(line PrGH3d_pr2 PrGH1age if PrGH3pval1 , color(orange) lpattern(longdash) )   ///
(line PrGH3d_pr2 PrGH1age if PrGH3pval1 < 0.05, color(orange) lpattern(solid) ) ///
, legend(order(1 3 5 7) label(1 "None") label(3 "Primary") label(5 "Secondary") label(7 "Higher")) ///
ytitle("Pr(Not walking but talking | Working) -" "Pr(Not walking but talking | Not working)" , size(*.75) ) ///
xtitle("Age", size(*.75) ) ///
title("Probability of not Walking but Talking for working and non-working by Age and education", size(*.75) ) ///
note("Dashed lines indicate that the difference in the probabilities is not significant at the 0.05 level", size(*.5) ) ///
xsize(20) ysize(12.5)
* name(urban_work7)

* Is it posible to run the same kind of graph when the variable in dydx is a categorical variable (such as religion, with 3 categories)?


*table of AMEs, with a group comparison model


* Tom, I am having trouble using the mtable commend (I am not sure why, I was able to use it on the data file you sent us)

* In general, we are interested to see differences over religion. For example, by urban/rural (binary) but also by education level (four categories) and so forth
* A couple of questions: 
* Decoupling, our target variable in the mlogit model, have 4 categories. How should I refer to it here? That is, what is the right way to look at change in probabilities for each pr(outcome()) ? 
///Should it be something like mtable if decoulping==1 ... ? 
///But this doesn't account for the fact that the information is already within the model - pr(outcome)

* Is it possible to use a categorical variable inside the dydx ()? 
///mtable, dydx(educlvl) over(religion_c) post brief

* Following your example, I understand that for continuous variables like age, it is best to use SD. It is age+SD, right?
* If I understand, the mtable are best for 2 variables, not for 3. Is that right?

mtable , dydx(urban) over(religion_c) post brief

quietly { // results are summarized below
* Urban 
est restore reli
mtable, dydx(urban) over(religion_c) post brief
mlincom (3),   rowname(ADC Urban: Hindu) add clear
mlincom (2),   rowname(ADC Urban: Christian) add
mlincom (1),   rowname(ADC Urban: Muslim) add
mlincom (3-2), rowname(ADC Urban: Diff Hin-Chr) add
mlincom (3-1), rowname(ADC Urban: Diff Hin-Mus) add
mlincom (2-1), rowname(ADC Urban: Diff Chr-Mus) add
* Media
est restore reli
mtable, dydx(media_access) over(religion_c) post brief
mlincom (3),   rowname(ADC Media: Hindu) add clear
mlincom (2),   rowname(ADC Media: Christian) add
mlincom (1),   rowname(ADC Media: Muslim) add
mlincom (3-2), rowname(ADC Media: Diff Hin-Chr) add
mlincom (3-1), rowname(ADC Media: Diff Hin-Mus) add
mlincom (2-1), rowname(ADC Media: Diff Chr-Mus) add
* Waves
est restore reli
mtable, dydx(waves2) over(religion_c) post brief
mlincom (3),   rowname(ADC Wave2: Hindu) add clear
mlincom (2),   rowname(ADC Wave2: Christian) add
mlincom (1),   rowname(ADC Wave2: Muslim) add
mlincom (3-2), rowname(ADC Wave2: Diff Hin-Chr) add
mlincom (3-1), rowname(ADC Wave2: Diff Hin-Mus) add
mlincom (2-1), rowname(ADC Wave2: Diff Chr-Mus) add
* age
est restore reli
mtable, at(age=gen(age)) at(age=gen(age+7)) over(religion_c) post brief
mlincom (6-3),       rowname(ADC age SD: Hindu) add
mlincom (5-2),       rowname(ADC age SD: Christian) add 
mlincom (4-1),       rowname(ADC age SD: Muslim) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff Hin-Chr)
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff Hin-Mus)
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Chr-Mus)

* Wealth
*est restore gctab
*mtable, at(wealthq=gen(wealthq)) at(wealthq=gen(wealthq+1.15)) over(mus_chr) post brief
*mlincom (4-2),        rowname(ADC Wealth SD: Muslim) add 
*mlincom (3-1),        rowname(ADC Wealth SD: Christian) add
*mlincom (4-2)-(3-1),  rowname(ADC Wealth SD: Difference) add
* srh
*est restore gctab
*mtable, at(srh=gen(srh)) at(srh=gen(srh+1)) over(isblack) post brief
*mlincom (4-2),       rowname(ADC srh: Black) add 
*mlincom (3-1),       rowname(ADC srh: White) add
*mlincom (4-2)-(3-1), rowname(ADC srh: Difference) add
}

mlincom, twidth(25) title(ADC by religion)







* Tom, from here on is the part that I am able to run properly. I left it here just to give you an idea of what we are working on.

** To run margins - for predicted probabilities:

* Currently working by age over religion
margins, at(age=(25(5)50) currwork_d=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(work1) 

margins, at(age=(25(5)50) currwork_d=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work2) 


margins, at(age=(25(5)50) currwork_d=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work3) 


margins, at(age=(25(5)50) currwork_d=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking for Currently Working by Age and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(work4) 

grc1leg work1 work2 work3 work4, ycommon cols(2) ysize(40) xsize(80)

* Media access by age over religion
margins, at(age=(25(5)50) media_access=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
ysize(40) xsize(80) name(media1) 

margins, at(age=(25(5)50) media_access=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media2) 


margins, at(age=(25(5)50) media_access=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media3) 


margins, at(age=(25(5)50) media_access=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking by Age, Media Access and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
ysize(40) xsize(80) name(media4) 


grc1leg media1 media2 media3 media4, ycommon cols(2) ysize(40) xsize(80)


* Urban by age over religion
margins, at(age=(25(5)50) urban=(0 1)) over(religion_c) pr(outcome(0))
marginsplot, ///
title("Probabolity of Walking and Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban1) 

margins, at(age=(25(5)50) urban=(0 1)) over(religion_c) pr(outcome(1))
marginsplot, ///
title("Probabolity of Walking but not Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban2) 

margins, at(age=(25(5)50) urban=(0 1)) over(religion_c) pr(outcome(2))
marginsplot, ///
title("Probabolity of Not Walking but Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban3) 

margins, at(age=(25(5)50) urban=(0 1)) over(religion_c) pr(outcome(3))
marginsplot, ///
title("Probabolity of Neither Walking nor Talking by Age, Urban and Religion", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("Age", size(*.75) ) ///
ysize(40) xsize(80) name(urban4) 

grc1leg urban1 urban2 urban3 urban4, ycommon cols(2) ysize(40) xsize(80)







* plot probabilities across age, by religion, for outcomes
margins, at(age=(25(5)50)) over(religion_c) pr(outcome(0))
marginsplot, name(model1) title(Walk and talk)

margins, at(age=(25(5)50)) over(religion_c) pr(outcome(1))
marginsplot, name(model2) title(Walking but not talking)

margins, at(age=(25(5)50)) over(religion_c) pr(outcome(2))
marginsplot, name(model3) title(Not walking but talking)

margins, at(age=(25(5)50)) over(religion_c) pr(outcome(3))
marginsplot, name(model4) title(Neither walking nor talking)

grc1leg model1 model2 model3 model4, ycommon cols(2) ysize(40) xsize(80)



