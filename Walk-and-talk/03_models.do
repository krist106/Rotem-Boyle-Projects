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


correlate urban muslim never_married agefrstmar_c educlvl pipedwtr media_access polviolence_p1 global_human_footprint travel_times

pwcorr urban muslim never_married agefrstmar_c educlvl pipedwtr media_access polviolence_p1 global_human_footprint travel_times, print(.05) star(.01)

correlate radio newspaper tv

correlate urban travel_times_c

correlate wealthq global_human_footprint urban

* exporting tables to excel
*tab2xl sample decoupling if waves2!=. [aw=perweight] using testfile, col(1) row(1)
*tab sample decoupling if waves2!=. [aw=perweight], r
*xtable

* There is some correlation between tv and newspaper, but not huge

*** Multinomial Logistic Regression ***


* Liz tries some models

quietly mlogit decoupling urban ib3.wealthq pipedwtr radio tv i.employment age i.agefrstmar_c i.educlvl waves2 i.country [pw=perweight], rrr base(0)
estimates store model1A
outreg2 model1A using 1A_decoupling_old.xls, replace eform

quietly mlogit decoupling urban ib3.wealthq pipedwtr radio tv i.employment age i.agefrstmar_c i.educlvl i.husedlvl ib1.edugap muslim waves2 i.country [pw=perweight], rrr base(0)
estimates store model1B
outreg2 model1B using 1B_decoupling_old.xls, replace eform

*About 660K cases with decoupling and waves2 variables.
*Lose 20K cases with pipedwtr, radio, TV, women's education (most are probably pipedwtr)
*Lose another 30k with employment. See note above; can probably recode this differently to regain some of these cases.
*Lose 44k with husedlvl (may lose a country or two, check on this)
*Lose 65K to religion--all of Pakistan (which is more than 96% Muslim), a lot of Rwanda, Egypt, Tanzania, and Niger. Can we get back some of the missing cases from the latter countries?

quietly mlogit decoupling_new urban ib3.wealthq pipedwtr media_access currwork age i.agefrstmar_c i.educlvl waves2 i.country [pw=perweight], rrr base(0)
estimates store model2A
outreg2 model2A using 2A_decoupling_new.xls, replace eform

quietly mlogit decoupling_new urban ib3.wealthq pipedwtr media_access currwork age i.agefrstmar_c i.educlvl i.husedlvl ib1.edugap ib0.religion3 waves2 i.country [pw=perweight], rrr base(0)
estimates store model2B
outreg2 model2B using 2B_decoupling_new.xls, replace eform

*** In some countries it seems that only married women were surveyed - Afghanistan, Bangladesh, Jordan, Pakistan, Egypt. Pierotti noted that because of that she didn't run a comparison across countries but only within countries. I confirmed it by using tab ever_married country

*Makes no difference. We only have ever_married women in the sample because of the decision-making variable in decoupling. Those questions are only asked of ever-married women. 

* when using both ever_married and agefrstmar_c, the former is omitted because of collinearity
* adding i. before var shows the categories within the model
* rrr = relative-risk ratios
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0, rrr base(3)
estimates store model_full

* export to excel:
* outreg2 using test1.xls, replace(or append) eform

* This model looks only on ipums samples from the recent wave in a given country
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model2

* With country fixed effects
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model3

* With country fixed effects - battles, riots, civ_violence
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model3

mlogit decoupling_3b urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 i.country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store model3

estimates stats model_full model2 model3

mlogit decoupling urban radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model_no_GIS

mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model_no_violence

mlogit decoupling urban radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store model_clean

estimates stats model_full model_no_GIS model_no_violence model_clean

* Regions
mlogit decoupling urban radio newspaper tv i.educlvl i.husedlvl muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(3)


*** To export - decoupling
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0, rrr base(3)
estimates store full_model

*without global human footprint and newspapers
mlogit decoupling urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0, rrr base(3)
estimates store full_model1

* This model looks only on ipums samples from the recent wave in a given country
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store recent_wave

* without global human footprint and newspapers
mlogit decoupling urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store recent_wave1

* With country fixed effects
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store recent_wave_country_effect

* without global human footprint and newspapers
mlogit decoupling urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store recent_wave_country_effect1

* With country fixed effects - battles, riots, civ_violence
mlogit decoupling urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store wave_country_split_violence

* without global human footprint and newspapers
mlogit decoupling urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store wave_country_split_violenc1

* With a country fixed effect but no GIS or violence
mlogit decoupling urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store no_GIS_no_violence

* without global human footprint and newspapers
mlogit decoupling urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(3)
estimates store no_GIS_no_violence1

* Regions
mlogit decoupling urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(3)
estimates store regions

* without global human footprint and newspapers
mlogit decoupling urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(3)
estimates store regions1

outreg2 [full_model full_model1 recent_wave recent_wave1 recent_wave_country_effect recent_wave_country_effect1 wave_country_split_violence wave_country_split_violenc1 no_GIS_no_violence no_GIS_no_violence1 regions regions1] using decoupling.xls, replace eform



*** To export - decoupling - pro-decoupled
mlogit decoupling_3a urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0, rrr base(1)
estimates store full_model

*without global human footprint and newspapers
mlogit decoupling_3a urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0, rrr base(1)
estimates store full_model1

* This model looks only on ipums samples from the recent wave in a given country
mlogit decoupling_3a urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave

* without global human footprint and newspapers
mlogit decoupling_3a urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave1

* With country fixed effects
mlogit decoupling_3a urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave_country_effect

* without global human footprint and newspapers
mlogit decoupling_3a urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave_country_effect1

* With country fixed effects - battles, riots, civ_violence
mlogit decoupling_3a urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store wave_country_split_violence

* without global human footprint and newspapers
mlogit decoupling_3a urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store wave_country_split_violenc1

* With a country fixed effect but no GIS or violence
mlogit decoupling_3a urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store no_GIS_no_violence

* without global human footprint and newspapers
mlogit decoupling_3a urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store no_GIS_no_violence1

* Regions
mlogit decoupling_3a urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions

* without global human footprint and newspapers
mlogit decoupling_3a urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions1

* without global human footprint and newspapers + violence
mlogit decoupling_3a urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions1_violence

outreg2 [full_model full_model1 recent_wave recent_wave1 recent_wave_country_effect recent_wave_country_effect1 wave_country_split_violence wave_country_split_violenc1 no_GIS_no_violence no_GIS_no_violence1 regions regions1 regions1_violence] using decoupling_3a.xls, replace eform



*** To export - decoupling - pro-coupled
mlogit decoupling_3b urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0, rrr base(1)
estimates store full_model

*without global human footprint and newspapers
mlogit decoupling_3b urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0, rrr base(1)
estimates store full_model1

* This model looks only on ipums samples from the recent wave in a given country
mlogit decoupling_3b urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave

* without global human footprint and newspapers
mlogit decoupling_3b urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave1

* With country fixed effects
mlogit decoupling_3b urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave_country_effect

* without global human footprint and newspapers
mlogit decoupling_3b urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr polviolence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store recent_wave_country_effect1

* With country fixed effects - battles, riots, civ_violence
mlogit decoupling_3b urban i.travel_times_c radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr global_human_footprint battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store wave_country_split_violence

* without global human footprint and newspapers
mlogit decoupling_3b urban i.travel_times_c radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store wave_country_split_violenc1

* With a country fixed effect but no GIS or violence
mlogit decoupling_3b urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store no_GIS_no_violence

* without global human footprint and newspapers
mlogit decoupling_3b urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country [pw=perweight] if never_married==0 & last_wave==1, rrr base(1)
estimates store no_GIS_no_violence1

* Regions
mlogit decoupling_3b urban radio newspaper tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions

* without global human footprint and newspapers
mlogit decoupling_3b urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions1

* without global human footprint and newspapers + violence
mlogit decoupling_3b urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store regions1_violence

outreg2 [full_model full_model1 recent_wave recent_wave1 recent_wave_country_effect recent_wave_country_effect1 wave_country_split_violence wave_country_split_violenc1 no_GIS_no_violence no_GIS_no_violence1 regions regions1 regions1_violence] using decoupling_3b.xls, replace eform


*** Last model, from the three decoupling variables
* without global human footprint and newspapers + violence
mlogit decoupling_3a urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store decoupled

* without global human footprint and newspapers + violence
mlogit decoupling_3b urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(1)
estimates store coupled

* without global human footprint and newspapers + violence
mlogit decoupling urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(0)
estimates store decoupling

outreg2 [decoupled coupled decoupling] using decoupling_try.xls, replace eform


*** With employment 
mlogit decoupling urban radio tv i.educlvl i.husedlvl i.edugap muslim age i.agefrstmar_c i.employment i.wealthq pipedwtr battles_p1 riots_p1 civ_violence_p1 i.country last_wave regions subnational [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)

*** This is the one to use
mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.urban i.muslim i.country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store model1
outreg2 [model1] using ASA1.xls, replace eform lab side dec(2)
outreg2 [model1] using ASA1, word replace eform lab side dec(2)


mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv urban i.muslim battles_p1 riots_p1 civ_violence_p1 country i.waves3_alt [pw=womwt] if never_married==0, rrr base(0) cl(dhsid)
estimates store model2
outreg2 [model2] using ASA2.xls, replace eform lab side



*** from Feb 21, 2021
mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.urban muslim country i.waves3 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store threewavesrural

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c i.wealthq radio tv i.urban muslim country i.waves3 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store threewavesrural_nopipe

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.smod muslim country i.waves3 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store threewaves_smod

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c i.wealthq radio tv i.smod muslim country i.waves3 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store threewaves_smod_nopope

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.urban muslim country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store twowaves_rural

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c i.wealthq radio tv i.urban muslim country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store twowaves_rural_nopope

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.smod muslim country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store twowaves_smod

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c i.wealthq radio tv i.smod muslim country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store twowaves_smod_nopipe

estimates stats threewavesrural threewavesrural_nopipe threewaves_smod threewaves_smod_nopope twowaves_rural twowaves_rural_nopope twowaves_smod twowaves_smod_nopipe
*BY AIC and BIC, the models with smod are better than these with rural


mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.urban muslim country i.waves3 urban#c.age [pw=perweight] if never_married==0, base(0) cl(dhsid)

estimates store threewavesrural

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv ib3.smod muslim country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)

mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv ib3.smod muslim i.country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)



*** From Mar 16, 2021
mlogit decoupling i.educlvl i.husedlvl i.edugap i.employment age i.agefrstmar_c pipedwtr i.wealthq radio tv i.urban muslim i.country i.waves2 [pw=perweight] if never_married==0, rrr base(0) cl(dhsid)
estimates store model1

label define dec1_l 0 "a" 1 "b" 2 "c" 3 "d"
label values decoupling dec1_l

* Maybe needed?
*recast byte decoupling
*format %9.0g decoupling



* fix labels
label variable urban "Urban"
label define urban_l 0 "Rural" 1 "Urban"
label values urban urban_l

label define wealthq_l 1 "Household wealth - Poorest" 2 "Household wealth - Poorer" 3 "Household wealth - Middle" ///
4 "Household wealth - Richer" 5 "Household wealth - Richest"
label values wealthq wealthq_l

label variable pipedwtr "Had own piped water"

label define media_l 0 "Have no media access" 1 "Have media access"
label values media_access media_l

label variable currwork_d "Currently working"
label variable age "Age"

label define c_age_l 1 "Age when married: -15" 2 "Age when married: 16-19" 3 "Age when married: +20"
label values agefrstmar_c c_age_l

label define educlvl_l 0 "Women's edu: None" 1 "Women's edu: Primary" 2 "Women's edu: Secondary" 3 "Women's edu: Higher"
label values educlvl educlvl_l

label define husedlvl_l 0 "Partner's edu: None" 1 "Partner's edu: Primary" 2 "Partner's edu: Secondary" 3 "Partner's edu: Higher"
label values husedlvl husedlvl_l

label define edugap_l 0 "Woman have lower edu than partner" 1 "Woman have equal edu as partner" 2 "Woman have higher edu than partner"
label values edugap edugap_l

label define waves2_l 1 "First wave" 2 "Second wave"
label values waves2 waves2_l

* FOR PAA figure
* Nir: Liz, I changed back do decoupling (over _new) as the origional one was coded correctly. I sometimes flip between adding i. to dummy variables - it effect which label is been used (that of the categories or of the variable). AS you use ib3 for religion, there is really no need to recode the variable. the "other religions" will be the based category.
mlogit decoupling i.urban ib3.wealthq pipedwtr i.media_access currwork_d age i.agefrstmar_c i.educlvl i.husedlvl ib1.edugap ib3.religion_c i.waves2 i.country [pw=perweight], rrr base(0)

* The code for the figure itself, after the mlogit
* ssc install coefplot, replace
* net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
coefplot ., bylabel("Walking but not talking") || ., bylabel("Not walking but talking") || ., bylabel("Neither walking nor talking") ||, drop(_cons *country) eform scheme(cleanplots) byopts(rows(1)) ysize(40) xsize(60) sub(,size(small))

*coefplot ., keep(b:) bylabel("Rejects gender equity" "Empowered in household") || ., keep(c:) bylabel("Supports gender equity" "Not empowered in household") || ., keep(d:) bylabel("Rejects gender equity" "Not empowered in household") ||, drop(_cons *country) eform scheme(cleanplots) byopts(rows(1)) ysize(40) xsize(60) sub(,size(small))



* gen fixedn=e(sample)
set scheme cleanplots

catplot decoupling waves3
graph dot (mean) de1 (mean) de2 (mean) de3 (mean) de4, over(waves3)

tab decoupling waves3 if never_married==0

* to compute one or more sets of estimate in a graph
* coefplot model1, nolabel drop(_cons) keep(*:) ysize(100) xsize(25)


* generate fixedn=e(sample)


** To run margins - for predicted probabilities:
* See here https://stats.idre.ucla.edu/stata/dae/multinomiallogistic-regression/ and Williams 2012
margins educlvl, at(age=(20 30 40 49)) predict(outcome(0))
marginsplot, name(model5) title("Supports gender equity/Empowered in household")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(1))
marginsplot, name(model6) title("Rejects gender equity/Empowered in household")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(2))
marginsplot, name(model7) title("Supports gender equity/Not empowered in household")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(3))
marginsplot, name(model8) title("Rejects gender equity/Not empowered in household")

graph combine model5 model6 model7 model8, ycommon cols(2) ysize(40) xsize(80)


margins employment, at(age=(20 30 40 50 60)) predict(outcome(0))
marginsplot, name(model1) title("Supports gender equity/Empowered in household")

margins employment, at(age=(20 30 40 50 60)) predict(outcome(1))
marginsplot, name(model2) title("Rejects gender equity/Empowered in household")

margins employment, at(age=(20 30 40 50 60)) predict(outcome(2))
marginsplot, name(model3) title("Supports gender equity/Not empowered in household")

margins employment, at(age=(20 30 40 50 60)) predict(outcome(3))
marginsplot, name(model4) title("Rejects gender equity/Not empowered in household")

graph combine model1 model2 model3 model4, ycommon


margins i.edugap#i.employment, predict(outcome(0))
marginsplot, name(model15) title("Supports gender equity/Empowered in household")

* not very helpful at all
margins i.edugap#i.employment, at(age=(20 30 40 50 60)) predict(outcome(0))
marginsplot, name(model16) title("Supports gender equity/Empowered in household")

margins, dydx(radio tv waves3_alt) at(age=(20 30 40 50 60)) predict(outcome(0))
marginsplot, name(model17) title("Supports gender equity/Empowered in household")


margins, dydx(radio tv urban pipedwtr) at(waves3_alt=( 0 1 2)) predict(outcome(0)) 
marginsplot, name(model18) title("Supports gender equity/Empowered in household", size(medsmall))


margins, dydx(radio tv) at(waves3_alt=( 0 1 2)) predict(outcome(1))
marginsplot, name(model19) title("Supports gender equity/Empowered in household")

margins, dydx(radio tv) at(waves3_alt=( 0 1 2)) predict(outcome(2))
marginsplot, name(model20) title("Supports gender equity/Empowered in household")

margins, dydx(radio tv) at(waves3_alt=( 0 1 2)) predict(outcome(3))
marginsplot, name(model21) title("Supports gender equity/Empowered in household")

graph combine model18 model19 model20 model21

margins media_access#waves3_alt edugap, predict(outcome(0))
marginsplot, name(model22)


margins muslim, at(age=(20 30 40 50)) predict(outcome(0))

margins, dydx(i.muslim) at(age=(20 30 40 50)) predict(outcome(0))
marginsplot, name(model2)

margins muslim, at(age=(20 30 40 50)) predict(outcome(1))
marginsplot, name(model3)

margins muslim, at(age=(20 30 40 50)) predict(outcome(2))
marginsplot, name(model4)

margins muslim, at(age=(20 30 40 50)) predict(outcome(3))
marginsplot, name(model5)

graph combine model2 model3 model4 model5, ycommon


* urban
margins urban, at(age=(20 30 40 50 60)) predict(outcome(0))
marginsplot, name(urban1) title("Supports gender equity/Empowered in household")

margins urban, at(age=(20 30 40 50 60)) predict(outcome(1))
marginsplot, name(urban2) title("Rejects gender equity/Empowered in household")

margins urban, at(age=(20 30 40 50 60)) predict(outcome(2))
marginsplot, name(urban3) title("Supports gender equity/Not empowered in household")

margins urban, at(age=(20 30 40 50 60)) predict(outcome(3))
marginsplot, name(urban4) title("Rejects gender equity/Not empowered in household")

graph combine urban1 urban2 urban3 urban4, ycommon cols(2) ysize(40) xsize(80)

* do the same thing for outcome 1, 2, 3 but after each run, ues:
marginsplot, name(NAME)
* option: marginsplot, recast(line) recastci(rarea) name(NAME)

margins employment#last_wave1 predict(outcome(0))

* At the end:
* graph combine name1 name 2 etc, ycommon


*** A figure with the 4 categories of discordance, by country and wave

* ssc install splitvallabels
* findit grc1leg
set scheme plotplain

label define waves_1 1 "First wave" 2 "Second wave"
label values waves2 waves_1


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

splitvallabels waves2, length(6)  
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
legend(rows(2) stack size(small) ///
order(1 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Empowered in household" ///
3 "Supports gender equity/Not empowered in household" ///
4 "Rejects gender equity/Not empowered in household") ///
symplacement(center) ///
title(Discordance , size(small))) name(pakistan)

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

grc1leg bangladesh burundi cameroon congo benin ethiopia ghana guinea india kenya lesotho madagascar malawi mali mozambique namibia nepal niger nigeria pakistan rwanda senegal zimbabwe uganda egypt tanzania burkina zambia


***For PAA poster
* education
margins educlvl, at(age=(20 30 40 49)) predict(outcome(0))
marginsplot, name(edu1) title("Walking and talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(1))
marginsplot, name(edu2) title("Walking but not talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(2)) 
marginsplot, name(edu3) title("Not walking but talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins educlvl, at(age=(20 30 40 49)) predict(outcome(3)) 
marginsplot, name(edu4) title("Neither walking nor talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("") legend(cols(4))


grc1leg edu1 edu2 edu3 edu4, ycommon cols(2) ysize(40) xsize(70) legendfrom(edu4)
*graph combine model5 model6 model7 model8, ycommon cols(2) ysize(40) xsize(80)

* employment
margins employment, at(age=(20 30 40 49)) predict(outcome(0))
marginsplot, name(employ1) title("Walking and talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins employment, at(age=(20 30 40 49)) predict(outcome(1))
marginsplot, name(employ2) title("Walking but not talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins employment, at(age=(20 30 40 49)) predict(outcome(2))
marginsplot, name(employ3) title("Not walking but talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("")

margins employment, at(age=(20 30 40 49)) predict(outcome(3))
marginsplot, name(employ4) title("Neither walking nor talking") ///
plot1opts(lpattern("--")) plot2opts(lpattern("_--_#")) plot3opts(lpattern("_...")) ytitle("") legend(cols(4))

grc1leg employ1 employ2 employ3 employ4, ycommon ysize(40) xsize(70) legendfrom(employ4)
*graph combine model1 model2 model3 model4, ycommon

* Muslim
margins muslim, at(age=(20 30 40 49)) predict(outcome(0))
marginsplot, name(muslim1) title("Walking and talking") ///
plot1opts(lpattern("--")) ytitle("")

margins muslim, at(age=(20 30 40 49)) predict(outcome(1))
marginsplot, name(muslim2) title("Walking but not talking") ///
plot1opts(lpattern("--")) ytitle("")

margins muslim, at(age=(20 30 40 49)) predict(outcome(2))
marginsplot, name(muslim3) title("Not walking but talking") ///
plot1opts(lpattern("--")) ytitle("")

margins muslim, at(age=(20 30 40 49)) predict(outcome(3))
marginsplot, name(muslim4) title("Neither walking nor talking") ///
plot1opts(lpattern("--")) ytitle("")  legend(cols(2))

grc1leg muslim1 muslim2 muslim3 muslim4, ycommon xsize(70) ysize(40) legendfrom(muslim4)
* graph combine muslim1 muslim2 muslim3 muslim4, ycommon

* urban
margins urban, at(age=(20 30 40 49)) predict(outcome(0))
marginsplot, name(urban1) title("Walking and talking") ///
plot1opts(lpattern("..")) ytitle("")

margins urban, at(age=(20 30 40 49)) predict(outcome(1))
marginsplot, name(urban2) title("Walking but not talking") ///
plot1opts(lpattern("..")) ytitle("")

margins urban, at(age=(20 30 40 49)) predict(outcome(2))
marginsplot, name(urban3) title("Not walking but talking") ///
plot1opts(lpattern("..")) ytitle("")

margins urban, at(age=(20 30 40 49)) predict(outcome(3))
marginsplot, name(urban4) title("Neither walking nor talking") ///
plot1opts(lpattern("..")) ytitle("")  legend(cols(2))

grc1leg urban1 urban2 urban3 urban4, ycommon xsize(70) ysize(40) legendfrom(urban4)
*graph combine urban1 urban2 urban3 urban4, ycommon cols(2) ysize(40) xsize(80)
