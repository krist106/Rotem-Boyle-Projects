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
drop if age<25

drop waves3 decoupling_3a decoupling_3b age5year marstat agefrstmar cheb currwork employment wkemploywhen wealths newsbrig tvbrig radiobrig 

drop dvaargue dvaburnfood dvagoout dvaifnosex dvanegkid dvppush dvppushfq dvpslap dvpslapfq dvptwist dvptwistfq dvppunch dvppunchfq dvpchoke dvpchokefq dvpkick dvpkickfq dvpknfthuse dvpknfthusef dvpknifeth dvpknifethfq dvpknifeuse dvpknifeusef dvpmsever dvpsex dvpsexfq dvpsexoth dvpsexothfq dvppush_di dvpslap_di dvptwist_di dvppunch_di dvpchoke_di dvpkick_di dvpsex_di dvpsexoth_di dvpknife_th_di dvpknife_att_di dvpknife1_di dvpknife_di dvujustargue dvujustburnfood dvujustgoout dvujustifnosex dvujustnegkid

* Wave 2 of Niger and Tanzania don't have data on religion. Yet somehow it was used in the models.
drop if sample==56203 | sample==56204 | sample==83404 | sample==83405 | sample==83406

*** Multinomial Logistic Regression ***

*** Note the models are without rrr
 *ib3.agefrstmar_c
* Baseline model
quietly mlogit decoupling i.educlvl i.radio i.urban c.age ib2.religion_cf i.waves2 i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store mo1

* Household
quietly mlogit decoupling i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap i.waves2 i.country [pw=popwt], base(0)
estimates store mo2

* Full - with local institutions
quietly mlogit decoupling i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap c.de2pc c.mar18pc ib2.muslimmaj i.waves2 i.country [pw=popwt], base(0)
estimates store mo3

esttab mo1 mo2 mo3 using model1106.rtf, ///
noomitted nobaselevels eform label replace one b(a2) se(2) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Baseline model" "Household" "Local institutions") 

esttab mo1 mo2 mo3 using model1106.csv, ///
noomitted nobaselevels eform label replace b(a2) se(2) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Baseline model" "Household" "Local institutions") 

*****************
** Using ipv_empowerment variable
** To be sure we are looking at the same (or as close as posible) samples we used before, lets keep the sample by the first model:
keep if model_sample==1

*To export the model as a figure, the labels should be shorter:
label define ipv_eml1 0 "Emp_no_IPV" 1 "Emp_IPV" 2 "Disemp_no_IPV" 3 "Disemp_IPV"
label values ipv_empowerment ipv_eml1

* Note that the waves2 is removed
quietly mlogit ipv_empowerment i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap i.country [pw=dvweight], base(0)
estimates store mo5

quietly mlogit ipv_empowerment i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap c.ipv_emp2pc c.mar18pc ib2.muslimmaj i.country [pw=dvweight], base(0)
estimates store mo6

esttab mo5 mo6 using model1121.rtf, ///
noomitted nobaselevels eform label replace one b(a2) se(2) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Household" "Local institutions") 

esttab mo5 mo6 using model1121.csv, ///
noomitted nobaselevels eform label replace b(a2) se(2) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Household" "Local institutions") 

coefplot ., keep(Emp_IPV:) bylabel("Empowered but experienced IPV") || ///
 ., keep( Disemp_no_IPV:) bylabel(" Disempowered and no IPV") || ///
 ., keep(Disemp_IPV:) bylabel("Disempowered and experienced IPV") ||, ///
 eform drop(_cons *country ) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
  mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span)


*****************
** Using ipv_exp variable - attitudes towards and experience of IPV
	
*To export the model as a figure, the labels should be shorter:
label define ipv_exp2 0 "Rej_no_IPV" 1 "Rej_IPV" 2 "Apr_no_IPV" 3 "Apr_IPV"
label values ipv_exp ipv_exp2

* Note that the waves2 is removed
quietly mlogit ipv_exp i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap i.country [pw=dvweight], base(0)
estimates store mo9

quietly mlogit ipv_exp i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap c.ipv_emp2pc c.mar18pc ib2.muslimmaj i.country [pw=dvweight], base(0)
estimates store mo10
	
esttab mo2 mo3 mo7 mo8 mo9 mo10 using model1130_1.csv, ///
noomitted nobaselevels eform label replace b(a2) se(2) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Household" "Local institutions" "Household" "Local institutions" "Household" "Local institutions") 

coefplot ., keep(Rej_IPV:) bylabel("Rejects IPV but experienced IPV") || ///
 ., keep(Apr_no_IPV:) bylabel("Aprrove IPV but not experienced IPV") || ///
 ., keep(Apr_IPV:) bylabel("Approve IPV and experienced IPV") ||, ///
 eform drop(_cons *country ) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
  mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span)

	*name(test2)

*esttab mo1 using model1_1.rtf, noomitted eform label wide unstack replace se(3)
*esttab mo2 using model1_2.rtf, noomitted eform label wide unstack replace se(3)
*esttab mo3 using model1_3.rtf, noomitted eform label wide unstack replace se(3)

/*
esttab mo1 mo2 mo3 using model1014.csv, ///
noomitted nobaselevels eform label wide append se(3) compress unstack  ///
constant obslast scalars("chi2 Wald chi-squared") ///
mtitles("Baseline model" "Household" "Local institutions") 
*/

* A few post estimation commands
mlogtest, combine // It computes Wald tests of the null hypothesis that two alternatives can be combained for all pairs of alternatives. In our case, it support the differences among the four decoupling categories
leastlikely decoupling educlvl radio urban age religion_cf // This helps to identify the least likely observations

mchange, at(radio=1)
mchange, dec(3) width(30)
mat R= r(table)
mat B= r(basepred)
esttab mat(R) using mchange1.rtf, title("Marginal effects") nomtitles replace 
esttab mat(B) using mchange1.rtf, title("Average Predictions") nomtitles append


mlogit decoupling i.educlvl i.media_access i.urban i.wealthq_5 i.currwork_d ib1.edugap c.age c.de2pc c.muslimpc i.waves2 i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store mo1

mlogit decoupling i.educlvl i.media_access i.urban ib3.wealthq i.currwork_d ib1.edugap c.age c.de2pc c.muslimpc i.waves2 i.country [pw=popwt], base(0)
estimates store mo2

mlogit decoupling ib1.edugap##(i.media_access i.urban i.wealthq_5 i.currwork_d c.age c.de2pc c.muslimpc) i.educlvl i.waves2 i.country [pw=popwt], base(0)
generate model_sample=e(sample)
estimates store mo3

* With religion_cf
mlogit decoupling i.educlvl i.media_access i.urban i.wealthq_5 i.currwork_d ib1.edugap c.age c.de2pc i.religion_cf c.muslimpc i.waves2 i.country [pw=popwt], base(0)
estimates store mo4

* To export the mlogit model to a Word document
*outreg2 MODEL NAME using simplfied%muslim1, word replace eform sideway label(proper) dec(3)
*Use this one:
esttab mo1 using model3.rtf, noomitted eform label wide unstack replace se(3)
esttab mo2 using model2.rtf, noomitted eform label wide unstack replace se(3)

set scheme cleanplots

*** This will predoce the figure based on the mlogit.
* Option one: significance using * ** ***
coefplot ., keep(walk_notalk:) bylabel("Walking but not talking") || ///
 ., keep(talk_nowalk:) bylabel("Not walking but talking") || ///
 ., keep(neither:) bylabel("Neither walking nor talking") ||, ///
 eform drop(_cons *country *urban *wealthq ) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
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
 , eform drop(_cons *country *urban *wealthq *educlvl *media_access *muslimpc) ///
 scheme(cleanplots) byopts(rows(1)) msize(large) ysize(40) xsize(70) xline(1) sub(,size(medium)) ///
 xtitle(Relative Risk Ratio) ///
 note("Significant coefficients are displayed in blue and nonsignificant coefficients are displayed in red")


* To calculate and plot the average marginal effects
* This should work less idelly for continuous variables (age, etc.) 
set scheme cleanplots

est restore mo3
quietly margins, dydx( educlvl radio urban religion_cf wealthq currwork_d edugap muslimmaj) post

*margins, dydx(*) post

* Here all the variables listed in the margins' dydx are included
coefplot ///
(, keep(*:1._predict) label(Walk and talk)) ///
(, keep(*:2._predict) label(Walk not talk)) ///
(, keep(*:3._predict) label(Talk not walk))  ///
(, keep(*:4._predict) label(Neither))  ///
, swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) 

* To help with the readibility, the variable list is divided into two:
coefplot ///
(, keep(*:1._predict) label(Walk and talk)) ///
(, keep(*:2._predict) label(Walk not talk)) ///
(, keep(*:3._predict) label(Talk not walk))  ///
(, keep(*:4._predict) label(Neither)) ,  ///
drop (*wealthq *currwork_d *edugap *muslimmaj) ///
swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) name(AME1)

coefplot ///
(, keep(*:1._predict) label(Walk and talk)) ///
(, keep(*:2._predict) label(Walk not talk)) ///
(, keep(*:3._predict) label(Talk not walk))  ///
(, keep(*:4._predict) label(Neither)) ,  ///
drop (*educlvl *radio *urban *religion_cf) ///
swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) name(AME2)

grc1leg AME1 AME2, ycommon rows(2)
 
 * Or divided into three sub-figures
coefplot ///
(, keep(*educlvl:1._predict *radio:1._predict *urban:1._predict) label(Walk and talk)) ///
(, keep(*educlvl:2._predict *radio:2._predict *urban:2._predict) label(Walk not talk)) ///
(, keep(*educlvl:3._predict *radio:3._predict *urban:3._predict) label(Talk not walk))  ///
(, keep(*educlvl:4._predict *radio:4._predict *urban:4._predict) label(Neither)) ,  ///
 mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span) /// 
	swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) name(AME3)

coefplot ///
(, keep(*religion_cf:1._predict *wealthq:1._predict) label(Walk and talk)) ///
(, keep(*religion_cf:2._predict *wealthq:2._predict) label(Walk not talk)) ///
(, keep(*religion_cf:3._predict *wealthq:3._predict) label(Talk not walk))  ///
(, keep(*religion_cf:4._predict *wealthq:4._predict) label(Neither)) ,  ///
 mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span) ///
	swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) name(AME4)

coefplot ///
(, keep(*currwork_d:1._predict *edugap:1._predict *muslimmaj:1._predict) label(Walk and talk)) ///
(, keep(*currwork_d:2._predict *edugap:2._predict *muslimmaj:2._predict) label(Walk not talk)) ///
(, keep(*currwork_d:3._predict *edugap:3._predict *muslimmaj:3._predict) label(Talk not walk))  ///
(, keep(*currwork_d:4._predict *edugap:4._predict *muslimmaj:4._predict) label(Neither)) ,  ///
 mlabel(cond(@pval<.001, "***", ///
  cond(@pval<.01, "**",   ///
 cond(@pval<.05, "*", "")))) ///
	note("* p < .05, ** p < .01, *** p < .001", span) ///
	swapnames vertical yline(0) legend(rows(2)) ytitle (Average marginal effects) name(AME5)

grc1leg AME3 AME4 AME5, ycommon rows(3)
 

*est restore mo3
*mchange educlvl radio urban age religion_cf wealthq currwork_d edugap de2pc mar18pc muslimmaj, amount(sd) brief

*mchangeplot educlvl radio urban age, symbols (D1 D2 D3 D4) sig(.05) leftmargin(5)
 

*table of AMEs, with a group comparison model

* for outcome0
quietly {
est restore mo1
margins , dydx(urban) over(edugap) pr(outcome(0)) post
mlincom (1), rowname(ADC Urban: Less educ) add clear
mlincom (2), rowname(ADC Urban: Equal edu) add
mlincom (3), rowname(ADC Urban: More educ) add
mlincom (2-1), rowname(ADC Urban: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Urban: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Urban: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(currwork_d) over(edugap) pr(outcome(0)) post
mlincom (1), rowname(ADC Working: Less educ) add
mlincom (2), rowname(ADC Working: Equal edu) add
mlincom (3), rowname(ADC Working: More educ) add
mlincom (2-1), rowname(ADC Working: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Working: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Working: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(media_access) over(edugap) pr(outcome(0)) post
mlincom (1), rowname(ADC Media: Less educ) add 
mlincom (2), rowname(ADC Media: Equal edu) add
mlincom (3), rowname(ADC Media: More educ) add
mlincom (2-1), rowname(ADC Media: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Media: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Media: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(waves2) over(edugap) pr(outcome(0)) post
mlincom (1), rowname(ADC Wave2: Less educ) add 
mlincom (2), rowname(ADC Wave2: Equal edu) add
mlincom (3), rowname(ADC Wave2: More educ) add
mlincom (2-1), rowname(ADC Wave2: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Wave2: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Wave2: Diff More educ - Equal edu) add

est restore mo1
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(edugap) pr(outcome(0)) post
mlincom (4-1), rowname(ADC age SD: Less educ) add
mlincom (5-2), rowname(ADC age SD: Equal edu) add
mlincom (6-3), rowname(ADC age SD: More educ) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff More educ - Equal edu) add


est restore mo1
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+42.6)) over(edugap) pr(outcome(0)) post
mlincom (4-1), rowname(ADC % Muslim: Less educ) add
mlincom (5-2), rowname(ADC % Muslim: Equal edu) add
mlincom (6-3), rowname(ADC % Muslim: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff More educ - Equal edu) add

est restore mo1
margins , at(de2pc=gen(de2pc)) at(de2pc=gen(de2pc+21.2)) over(edugap) pr(outcome(0)) post
mlincom (4-1), rowname(ADC % Walk not talk: Less educ) add
mlincom (5-2), rowname(ADC % Walk not talk: Equal edu) add
mlincom (6-3), rowname(ADC % Walk not talk: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Walk not talk: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Walk not talk: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Walk not talk: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(wealthq_5) over(edugap) pr(outcome(0)) post
mlincom (1), rowname(ADC WHQ5: Less educ) add
mlincom (2), rowname(ADC WHQ5: Equal edu) add
mlincom (3), rowname(ADC WHQ5: More educ) add
mlincom (2-1), rowname(ADC WHQ5: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC WHQ5: Diff More educ - Less edu) add
mlincom (3-2), rowname(ADC WHQ5: Diff More educ - Equal edu) add
}

mlincom, twidth(25) title(ADC by education gap)

* for outcome1
quietly {
est restore mo1
margins , dydx(urban) over(edugap) pr(outcome(1)) post
mlincom (1), rowname(ADC Urban: Less educ) add clear
mlincom (2), rowname(ADC Urban: Equal edu) add
mlincom (3), rowname(ADC Urban: More educ) add
mlincom (2-1), rowname(ADC Urban: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Urban: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Urban: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(currwork_d) over(edugap) pr(outcome(1)) post
mlincom (1), rowname(ADC Working: Less educ) add
mlincom (2), rowname(ADC Working: Equal edu) add
mlincom (3), rowname(ADC Working: More educ) add
mlincom (2-1), rowname(ADC Working: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Working: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Working: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(media_access) over(edugap) pr(outcome(1)) post
mlincom (1), rowname(ADC Media: Less educ) add 
mlincom (2), rowname(ADC Media: Equal edu) add
mlincom (3), rowname(ADC Media: More educ) add
mlincom (2-1), rowname(ADC Media: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Media: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Media: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(waves2) over(edugap) pr(outcome(1)) post
mlincom (1), rowname(ADC Wave2: Less educ) add 
mlincom (2), rowname(ADC Wave2: Equal edu) add
mlincom (3), rowname(ADC Wave2: More educ) add
mlincom (2-1), rowname(ADC Wave2: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Wave2: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Wave2: Diff More educ - Equal edu) add

est restore mo1
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(edugap) pr(outcome(1)) post
mlincom (4-1), rowname(ADC age SD: Less educ) add
mlincom (5-2), rowname(ADC age SD: Equal edu) add
mlincom (6-3), rowname(ADC age SD: More educ) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff More educ - Equal edu) add


est restore mo1
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+42.6)) over(edugap) pr(outcome(1)) post
mlincom (4-1), rowname(ADC % Muslim: Less educ) add
mlincom (5-2), rowname(ADC % Muslim: Equal edu) add
mlincom (6-3), rowname(ADC % Muslim: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff More educ - Equal edu) add

est restore mo1
margins , at(de2pc=gen(de2pc)) at(de2pc=gen(de2pc+21.2)) over(edugap) pr(outcome(1)) post
mlincom (4-1), rowname(ADC % Walk not talk: Less educ) add
mlincom (5-2), rowname(ADC % Walk not talk: Equal edu) add
mlincom (6-3), rowname(ADC % Walk not talk: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Walk not talk: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Walk not talk: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Walk not talk: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(wealthq_5) over(edugap) pr(outcome(1)) post
mlincom (1), rowname(ADC WHQ5: Less educ) add
mlincom (2), rowname(ADC WHQ5: Equal edu) add
mlincom (3), rowname(ADC WHQ5: More educ) add
mlincom (2-1), rowname(ADC WHQ5: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC WHQ5: Diff More educ - Less edu) add
mlincom (3-2), rowname(ADC WHQ5: Diff More educ - Equal edu) add
}

mlincom, twidth(25) title(ADC by education gap)

* for outcome2
quietly {
est restore mo1
margins , dydx(urban) over(edugap) pr(outcome(2)) post
mlincom (1), rowname(ADC Urban: Less educ) add clear
mlincom (2), rowname(ADC Urban: Equal edu) add
mlincom (3), rowname(ADC Urban: More educ) add
mlincom (2-1), rowname(ADC Urban: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Urban: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Urban: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(currwork_d) over(edugap) pr(outcome(2)) post
mlincom (1), rowname(ADC Working: Less educ) add
mlincom (2), rowname(ADC Working: Equal edu) add
mlincom (3), rowname(ADC Working: More educ) add
mlincom (2-1), rowname(ADC Working: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Working: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Working: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(media_access) over(edugap) pr(outcome(2)) post
mlincom (1), rowname(ADC Media: Less educ) add 
mlincom (2), rowname(ADC Media: Equal edu) add
mlincom (3), rowname(ADC Media: More educ) add
mlincom (2-1), rowname(ADC Media: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Media: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Media: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(waves2) over(edugap) pr(outcome(2)) post
mlincom (1), rowname(ADC Wave2: Less educ) add 
mlincom (2), rowname(ADC Wave2: Equal edu) add
mlincom (3), rowname(ADC Wave2: More educ) add
mlincom (2-1), rowname(ADC Wave2: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Wave2: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Wave2: Diff More educ - Equal edu) add

est restore mo1
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(edugap) pr(outcome(2)) post
mlincom (4-1), rowname(ADC age SD: Less educ) add
mlincom (5-2), rowname(ADC age SD: Equal edu) add
mlincom (6-3), rowname(ADC age SD: More educ) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff More educ - Equal edu) add


est restore mo1
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+42.6)) over(edugap) pr(outcome(2)) post
mlincom (4-1), rowname(ADC % Muslim: Less educ) add
mlincom (5-2), rowname(ADC % Muslim: Equal edu) add
mlincom (6-3), rowname(ADC % Muslim: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff More educ - Equal edu) add

est restore mo1
margins , at(de2pc=gen(de2pc)) at(de2pc=gen(de2pc+21.2)) over(edugap) pr(outcome(2)) post
mlincom (4-1), rowname(ADC % Walk not talk: Less educ) add
mlincom (5-2), rowname(ADC % Walk not talk: Equal edu) add
mlincom (6-3), rowname(ADC % Walk not talk: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Walk not talk: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Walk not talk: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Walk not talk: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(wealthq_5) over(edugap) pr(outcome(2)) post
mlincom (1), rowname(ADC WHQ5: Less educ) add
mlincom (2), rowname(ADC WHQ5: Equal edu) add
mlincom (3), rowname(ADC WHQ5: More educ) add
mlincom (2-1), rowname(ADC WHQ5: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC WHQ5: Diff More educ - Less edu) add
mlincom (3-2), rowname(ADC WHQ5: Diff More educ - Equal edu) add
}

mlincom, twidth(25) title(ADC by education gap)

* for outcome3
quietly {
est restore mo1
margins , dydx(urban) over(edugap) pr(outcome(3)) post
mlincom (1), rowname(ADC Urban: Less educ) add clear
mlincom (2), rowname(ADC Urban: Equal edu) add
mlincom (3), rowname(ADC Urban: More educ) add
mlincom (2-1), rowname(ADC Urban: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Urban: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Urban: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(currwork_d) over(edugap) pr(outcome(3)) post
mlincom (1), rowname(ADC Working: Less educ) add
mlincom (2), rowname(ADC Working: Equal edu) add
mlincom (3), rowname(ADC Working: More educ) add
mlincom (2-1), rowname(ADC Working: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Working: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Working: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(media_access) over(edugap) pr(outcome(3)) post
mlincom (1), rowname(ADC Media: Less educ) add 
mlincom (2), rowname(ADC Media: Equal edu) add
mlincom (3), rowname(ADC Media: More educ) add
mlincom (2-1), rowname(ADC Media: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Media: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Media: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(waves2) over(edugap) pr(outcome(3)) post
mlincom (1), rowname(ADC Wave2: Less educ) add 
mlincom (2), rowname(ADC Wave2: Equal edu) add
mlincom (3), rowname(ADC Wave2: More educ) add
mlincom (2-1), rowname(ADC Wave2: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC Wave2: Diff More educ - Less educ) add
mlincom (3-2), rowname(ADC Wave2: Diff More educ - Equal edu) add

est restore mo1
margins , at(age=gen(age)) at(age=gen(age+6.9)) over(edugap) pr(outcome(3)) post
mlincom (4-1), rowname(ADC age SD: Less educ) add
mlincom (5-2), rowname(ADC age SD: Equal edu) add
mlincom (6-3), rowname(ADC age SD: More educ) add
mlincom (5-2)-(4-1), rowname(ADC age SD: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC age SD: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC age SD: Diff More educ - Equal edu) add


est restore mo1
margins , at(muslimpc=gen(muslimpc)) at(muslimpc=gen(muslimpc+42.6)) over(edugap) pr(outcome(3)) post
mlincom (4-1), rowname(ADC % Muslim: Less educ) add
mlincom (5-2), rowname(ADC % Muslim: Equal edu) add
mlincom (6-3), rowname(ADC % Muslim: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Muslim: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Muslim: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Muslim: Diff More educ - Equal edu) add

est restore mo1
margins , at(de2pc=gen(de2pc)) at(de2pc=gen(de2pc+21.2)) over(edugap) pr(outcome(3)) post
mlincom (4-1), rowname(ADC % Walk not talk: Less educ) add
mlincom (5-2), rowname(ADC % Walk not talk: Equal edu) add
mlincom (6-3), rowname(ADC % Walk not talk: More educ) add
mlincom (5-2)-(4-1), rowname(ADC % Walk not talk: Diff Equal edu - Less educ) add
mlincom (6-3)-(4-1), rowname(ADC % Walk not talk: Diff More educ - Less edu) add
mlincom (6-3)-(5-2), rowname(ADC % Walk not talk: Diff More educ - Equal edu) add

est restore mo1
margins , dydx(wealthq_5) over(edugap) pr(outcome(3)) post
mlincom (1), rowname(ADC WHQ5: Less educ) add
mlincom (2), rowname(ADC WHQ5: Equal edu) add
mlincom (3), rowname(ADC WHQ5: More educ) add
mlincom (2-1), rowname(ADC WHQ5: Diff Equal edu - Less educ) add
mlincom (3-1), rowname(ADC WHQ5: Diff More educ - Less edu) add
mlincom (3-2), rowname(ADC WHQ5: Diff More educ - Equal edu) add
}

mlincom, twidth(25) title(ADC by education gap)

* Interpretation for outcome "margins" : On average, for a specific religion, variable=1 have a xxx higher probability of belonging to outcomeX, compared to variable=0 (check p<0.05, two-tailed test).

* interpretation for outcome "mlincom 2-1" : The gap between variable=1 and variable=0 in belonging to outcomeX is significantly larger among x religion compared to these from y religion (value and value, respectively, 2nd difference: value, p=)."



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

******* 

*** Probebly not needed:
/*

set scheme cleanplots

* Urban by % Walk and talk
est restore mo3
margins, at(de2pc=(0(10)100) urban=(0 1)) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Urban by % Walk and Talk", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc1) 

margins, at(de2pc=(0(10)100) urban=(0 1)) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Urban by % Walk and Talk", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc2)

margins, at(de2pc=(0(10)100) urban=(0 1)) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Urban by % Walk and Talk", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc3)

margins, at(de2pc=(0(10)100) urban=(0 1)) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Urban by % Walk and Talk", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc4)

grc1leg urban_de2pc1 urban_de2pc2 urban_de2pc3 urban_de2pc4, cols(2)
*** ycommon  *** as needed


* Urban by % Walk and talk
est restore mo3
margins, at(de2pc=(0(10)100) urban=(0 1)) over(muslimmaj) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Urban by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc5) 

margins, at(de2pc=(0(10)100) urban=(0 1)) over(muslimmaj) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Urban by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc6)

margins, at(de2pc=(0(10)100) urban=(0 1)) over(muslimmaj) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Urban by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc7)

margins, at(de2pc=(0(10)100) urban=(0 1)) over(muslimmaj) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Urban by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(urban_de2pc8)

grc1leg urban_de2pc5 urban_de2pc6 urban_de2pc7 urban_de2pc8, cols(2)
*** ycommon  *** as needed

* Radio by % Walk and talk
est restore mo3
margins, at(de2pc=(0(10)100) radio=(0 1)) over(muslimmaj) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Radio by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(radio_de2pc1) 

margins, at(de2pc=(0(10)100) radio=(0 1)) over(muslimmaj) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Radio by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(radio_de2pc2)

margins, at(de2pc=(0(10)100) radio=(0 1)) over(muslimmaj) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Radio by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(radio_de2pc3)

margins, at(de2pc=(0(10)100) radio=(0 1)) over(muslimmaj) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Radio by % Walk and Talk and Muslim majority", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(radio_de2pc4)

grc1leg radio_de2pc1 radio_de2pc2 radio_de2pc3 radio_de2pc4, cols(2)
*** ycommon  *** as needed


* Radio by % Walk and talk
est restore mo3
margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc1) 

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc2)

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc3)

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc4)

grc1leg work_de2pc1 work_de2pc2 work_de2pc3 work_de2pc4, cols(2)
*** ycommon  *** as needed


* Radio by % Walk and talk
est restore mo3
margins, at(currwork_d=(0 1)) over(edugap) pr(outcome(0))
marginsplot, ///
title("Probability of Walking and Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Walk and Talk)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80)

 name(work_de2pc1) 

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(1))
marginsplot, ///
title("Probability of Walking but not Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Walking but not Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc2)

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(2))
marginsplot, ///
title("Probability of not Walking but Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Not Walking but Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc3)

margins, at(de2pc=(0(10)100) currwork_d=(0 1)) over(edugap) pr(outcome(3))
marginsplot, ///
title("Probability of Neither Walking nor Talking" "for Currently Working by Education Gap", size(*.75)) ///
ytitle("Pr(Neither Walking nor Talking)", size(*.75)) ///
xtitle("% Walk not talk", size(*.75) ) ///
ysize(40) xsize(80) name(work_de2pc4)

grc1leg work_de2pc1 work_de2pc2 work_de2pc3 work_de2pc4, cols(2)

margins, at(currwork_d=(0 1)) over(edugap)


quietly mlogit decoupling c.mar18pc##(i.educlvl i.radio i.urban c.age ib2.religion_cf ib3.wealthq i.currwork_d ib1.edugap c.de2pc ib2.muslimmaj) i.waves2 i.country [pw=popwt], base(0)
estimates store mo4

est restore mo3
margins, at(mar18pc=(0(10)100) currwork_d=(0 1))
marginsplot, name(test1)

est restore mo4
margins, at(mar18pc=(0(10)100) currwork_d=(0 1))
marginsplot, name(test2)

*/
