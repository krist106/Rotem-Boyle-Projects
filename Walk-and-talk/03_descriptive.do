*******************************************************************************
***                                                                         ***
***                         Women's Rights –                                ***
***      				  Walking and talking 								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 07.16.2021

******************** For paper 1  ********************

*** Descriptive statistics


cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear

** Here we limit the file in memory to married or were married women. So in fact, we can remove all the if never_married==0 from the models below
use 02_women.dta 

keep if ever_married==1
drop if age<18 | age>49 | sample==56203 | sample==56204 | sample==83404 | sample==83405 | sample==83406
drop if religion_cf==1 & region==0
 
* We need a model so we can get the relevant descriptive statistics
* Household
quietly mlogit decoupling i.educlvl i.radio c.age ib3.religion_cf i.currwork_d i.urban ib3.wealthq ib1.edugap c.mar18pc ib0.mus_maj ib0.hin_maj i.waves2 i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store mo1

keep if model_sample==1

*** How many household in each cluster:
bys dhsid: gen dup_dhsid1=_N

bys idhshid: gen dup_hh=_N


*summary table
*install baselinetable
putdocx begin
baselinetable educlvl(cat countformat(%15.0gc)) ///
radio(cat value(1) novaluelabel countformat(%15.0gc)) ///
age(cts novarlabel afterheading("Age, mean (sd)")) ///
religion_cf(cat countformat(%15.0gc)) ///
currwork_d(cat value(1) novaluelabel countformat(%15.0gc)) ///
urban(cat value(1) novaluelabel countformat(%15.0gc)) ///
wealthq(cat countformat(%15.0gc)) ///
edugap(cat countformat(%15.0gc)) ///
mar18pc(cts novarlabel afterheading("% Under age 18 when married, mean (sd)")) ///
mus_maj(cat value(1) novaluelabel countformat(%15.0gc)) ///
hin_maj(cat value(1) novaluelabel countformat(%15.0gc)) ///
waves2(cat value(2) novarlabel countformat(%15.0gc)) ///
if model_sample==1 [fw=popwt], ///
by(decoupling, total) putdocxtab(summery_table)
putdocx save summery_table, replace

* With % only
putdocx begin
baselinetable educlvl(cat tab("%\%")) ///
radio(cat value(1) novaluelabel tab("%\%")) ///
age(cts novarlabel afterheading("Age, mean (sd)")) ///
religion_cf(cat tab("%\%")) ///
currwork_d(cat value(1) novaluelabel tab("%\%")) ///
urban(cat value(1) novaluelabel tab("%\%")) ///
wealthq(cat tab("%\%")) ///
edugap(cat tab("%\%")) ///
mar18pc(cts novarlabel afterheading("% Under age 18 when married, mean (sd)")) ///
mus_maj(cat value(1) novaluelabel tab("%\%")) ///
hin_maj(cat value(1) novaluelabel tab("%\%")) ///
waves2(cat value(2) novaluelabel tab("%\%")) ///
if model_sample==1 [aw=popwt], ///
by(decoupling, total) putdocxtab(summery_table)
putdocx save summery_table1, replace



*exportexcel(summery_table, replace)

* I created "only_news" to identify women who only read newspapers and don't listen to radio or watch TV
tab only_news [fw=popwt]
* only 0.92% of the sample

*For general discriptive of religion_4c
tab religion_cf [fw=popwt]

tab edugap [fw=popwt]

summarize age de2pc mar18pc [fw=popwt]
summarize age de2pc mar18pc

set scheme cleanplots

* hist of the % categories in a cluster
hist de1pc if model_sample==1, name(hist1)
hist de2pc if model_sample==1, name(hist2)
hist de3pc if model_sample==1, name(hist3)
hist de4pc if model_sample==1, name(hist4)
graph combine hist1 hist2 hist3 hist4



***Change of decoupling over time
tab decoupling [iweight=popwt]

tab decoupling country [iweight=popwt] if waves2==1 & model_sample==1, co
tab decoupling country [iweight=popwt] if waves2==2 & model_sample==1, co

tab decoupling waves2 [iweight=popwt] if model_sample==1, co
*to export:
xtable decoupling waves2 [iweight=popwt], co filename(change_wave.xlsx) 


***This shows country level figures and change
*** ssc install asgen
by sample, sort: asgen de1_country_w1 =  de1 if waves2==1, w(popwt)
by sample, sort: asgen de1_country_w2 = de1 if waves2==2, w(popwt)

by sample, sort: asgen de2_country_w1 = de2 if waves2==1, w(popwt)
by sample, sort: asgen de2_country_w2 = de2 if waves2==2, w(popwt)

by sample, sort: asgen de3_country_w1 = de3 if waves2==1, w(popwt)
by sample, sort: asgen de3_country_w2 = de3 if waves2==2, w(popwt)

by sample, sort: asgen de4_country_w1 = de4 if waves2==1, w(popwt)
by sample, sort: asgen de4_country_w2 = de4 if waves2==2, w(popwt)


collapse (mean) de1_country_w1 de1_country_w2 de2_country_w1 de2_country_w2 de3_country_w1 de3_country_w2 de4_country_w1 de4_country_w2, by(country)

gen de1_country_di = (de1_country_w2 - de1_country_w1) * 100
gen de2_country_di = (de2_country_w2 - de2_country_w1) * 100
gen de3_country_di = (de3_country_w2 - de3_country_w1) * 100
gen de4_country_di = (de4_country_w2 - de4_country_w1) *100

set scheme plotplain
graph bar (mean) de1_country_di, blabel(bar, format(%9.3g)) by(country)

***To plot the % change between waves
graph bar (mean) de1_country_di de2_country_di de3_country_di de4_country_di, blabel(bar, position(base) format(%9.2g)) ///
title(Percent change between waves) subtitle(Total, size(medsmall)) ///
legend(rows(2) stack size(vsmall) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" 2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker")) ///
intensity(25) ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
name("firstset", replace) ///
fxsize(100) fysize(20)

graph bar (mean) de1_country_di de2_country_di de3_country_di de4_country_di, blabel(bar, position(base) format(%9.2g)) by(country) ///
legend(rows(2) stack size(vsmall) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" 2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker")) ///
intensity(25) ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
name("secondset", replace)

grc1leg firstset secondset, cols(1)

sum de1_country_di

*** Religion over time
tab decoupling religion_cf if model_sample==1 & waves2==1, co
tab decoupling religion_cf if model_sample==1 & waves2==2, co

xtable decoupling religion_cf if model_sample==1 & waves2==1, filename(religion_wave1.xlsx)
xtable decoupling religion_cf if model_sample==1 & waves2==2, filename(religion_wave2.xlsx)


************ A figure with the 4 categories of discordance, by country and wave
by sample, sort: tab de1 [iweight=popwt] if waves2==1 
tab de1 sample [iweight=popwt] if waves2==1, co

* ssc install splitvallabels
* findit grc1leg
set scheme plotplain
******CHANGE to FW
splitvallabels waves2, length(6) 
catplot decoupling waves2 [iweight=popwt] if country==50 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(bangladesh)


splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==108 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(burundi)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==120 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(cameroon)


splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==180 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(congo)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==204 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(benin)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==231 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(ethiopia)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==288 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(ghana)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==324 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(guinea)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==356 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(india)

/*splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==400, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Jordan" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(jordan) */

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==404 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(kenya)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==426 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(lesotho)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==450 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(madagascar)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==454 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(malawi)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==466 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(mali)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==508 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(mozambique)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==516 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(namibia)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==524 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(nepal)

/*
splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==562, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" 2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(niger)
*/

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==566 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(nigeria)

/*splitvallabels waves2, length(6)  
catplot decoupling waves2 if country==586, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Level of support", size(small)) ///
title("Pakistan" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(pakistan) */

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==646 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(rwanda)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==686 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(senegal)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==716 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(zimbabwe)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==800 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(uganda)

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==818 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(egypt)

/*
splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==834, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///symplacement(center) ///
title(Discordance , size(small))) name(tanzania)
*/

splitvallabels waves2, length(6)  
catplot decoupling waves2 [iweight=popwt] if country==854 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(burkina)


splitvallabels waves2, length(6) 
catplot decoupling waves2 [iweight=popwt] if country==894 & model_sample==1, ///
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
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center) ///
title(Discordance , size(small))) name(zambia)

splitvallabels waves2, length(6) 
catplot decoupling waves2 [iweight=popwt] if model_sample==1, ///
percent(waves2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)') ) ///
ytitle("Level of support", size(small)) ///
title("Total" ///
, span size(medium)) ///
intensity(25) ///
asyvars stack ///
bar(1, color(maroon) fintensity(inten80)) ///
bar(2, color(maroon) fintensity(inten60)) ///
bar(3, color(gray) fintensity(inten40)) ///
bar(4, color(navy) fintensity(inten60)) ///
legend(rows(2) stack size(v.small) ///
order(1 "Cell 1: Support physical integrity/" "Decision maker" ///
2 "Cell 2: Accept IPV/" "Decision maker" ///
3 "Cell 3: Support physical integrity/" "Not dec. maker" ///
4 "Cell 4: Accept IPV//" "Not dec. maker") ///
symplacement(center)) ///
name(total, replace) ///
fxsize(100) fysize(20)

*grc1leg bangladesh benin burkina burundi cameroon congo egypt ethiopia ghana guinea india kenya lesotho madagascar malawi mali mozambique namibia nepal nigeria rwanda senegal uganda zambia zimbabwe, cols(5) ysize(50) xsize(40)

* sorted by walk_talk first wave
* mali guinea senegal burkina ethiopia nigeria congo uganda benin kenya cameroon burundi malawi zambia nepal mozambique ghana india lesotho zimbabwe rwanda egypt bangladesh namibia madagascar

grc1leg mali guinea senegal burkina ethiopia nigeria congo uganda benin kenya cameroon burundi malawi zambia nepal mozambique ghana india lesotho zimbabwe rwanda egypt bangladesh namibia madagascar, name("firstset", replace) cols(5) ysize(50) xsize(40)

grc1leg total firstset, cols(1) ysize(50) xsize(40)


*** For attitudes / experience of IPV
quietly mlogit ipv_exp i.educlvl i.radio c.age ib3.religion_cf i.currwork_d i.urban ib3.wealthq ib1.edugap c.mar18pc ib0.mus_maj ib0.hin_maj i.country [pw=dvweight], base(0)
generate model_sample1=e(sample)
estimates store mo2

tab ipv_exp [iweight=dvweight] if model_sample1==1

*summary table
putdocx begin
baselinetable educlvl(cat countformat(%15.0gc)) ///
radio(cat value(1) novaluelabel countformat(%15.0gc)) ///
age(cts novarlabel afterheading("Age, mean (sd)")) ///
religion_cf(cat countformat(%15.0gc)) ///
currwork_d(cat value(1) novaluelabel countformat(%15.0gc)) ///
urban(cat value(1) novaluelabel countformat(%15.0gc)) ///
wealthq(cat countformat(%15.0gc)) ///
edugap(cat countformat(%15.0gc)) ///
mar18pc(cts novarlabel afterheading("% Under age 18 when married, mean (sd)")) ///
mus_maj(cat value(1) countformat(%15.0gc)) ///
hin_maj(cat value(1) countformat(%15.0gc)) ///
if model_sample1==1 [aw=dvweight], ///
by(ipv_exp, total) putdocxtab(summery_table)
putdocx save summery_table1, replace

*exportexcel(summery_table, replace)

* With % only
putdocx begin
baselinetable educlvl(cat tab("%\%")) ///
radio(cat value(1) novaluelabel tab("%\%")) ///
age(cts novarlabel afterheading("Age, mean (sd)")) ///
religion_cf(cat tab("%\%")) ///
currwork_d(cat value(1) novaluelabel tab("%\%")) ///
urban(cat value(1) novaluelabel tab("%\%")) ///
wealthq(cat tab("%\%")) ///
edugap(cat tab("%\%")) ///
mar18pc(cts novarlabel afterheading("% Under age 18 when married, mean (sd)")) ///
mus_maj(cat value(1) tab("%\%")) ///
hin_maj(cat value(1) tab("%\%")) ///
if model_sample1==1 [aw=dvweight], ///
by(ipv_exp, total) putdocxtab(summery_table)
putdocx save summery_table1, replace

tab ipv_exp [iweight=dvweight]

