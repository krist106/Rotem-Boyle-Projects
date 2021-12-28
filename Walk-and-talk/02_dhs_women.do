*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***        Not Only a Policy Instrument but a Lived Reality?				***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 06.18.2021

cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"
clear
* use 02_women.dta, replace
**********************
*** Organizing the women's variables ***
**********************
use 02_women.dta, replace
replace dvppushfq = 0 if dvppush==0
recode dvppushfq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvppush_di)

replace dvpslapfq = 0 if dvpslap==0
recode dvpslapfq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvpslap_di)

replace dvptwistfq = 0 if dvptwist==0
recode dvptwistfq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvptwist_di)

replace dvppunchfq = 0 if dvppunch==0
recode dvppunchfq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvppunch_di)
 
replace dvpchokefq = 0 if dvpchoke==0
recode dvpchokefq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvpchoke_di)

replace dvpkickfq = 0 if dvpkick==0
recode dvpkickfq (0 13 =0) (11/12 20=1) (90/100=.), gen (dvpkick_di)

replace dvpsexfq = 0 if dvpsex==0
recode dvpsexfq (0 13 =0) (11/12 20=1) (90/100=.), gen(dvpsex_di)

replace dvpsexothfq = 0 if dvpsexoth==0
recode dvpsexothfq (0 13 =0) (11/12 20=1) (90/100=.), gen(dvpsexoth_di)


* Two ways of asking about weapons.
* For Cameroon and Cote d'Ivoire:
replace dvpknifethfq = 0 if dvpknifeth==0
recode dvpknifethfq (0 13 =0) (11/12 20=1) (90/100=.), gen(dvpknife_th_di)
* For Cote d'Ivoire only:
replace dvpknifeusef = 0 if dvpknifeuse==0
recode dvpknifeusef (0 13 =0) (11/12 20=1) (90/100=.), gen(dvpknife_att_di)
* For all other samples:
replace dvpknfthusef = 0 if dvpknfthuse==0
recode dvpknfthusef (0 13 =0) (11/12 20=1) (90/100=.), gen(dvpknife1_di)
* Put together:
gen dvpknife_di=.
replace dvpknife_di = 0 if dvpknife1_di==0
replace dvpknife_di = 1 if dvpknife1_di==1
replace dvpknife_di = 0 if dvpknife_th_di==0
replace dvpknife_di = 1 if dvpknife_th_di==1
replace dvpknife_di = 1 if dvpknife_att_di==1


****************************************************************
*** Combine all IPV variables into one dichotomous variable  ***
****************************************************************

egen ipv_any = rowmax(dvppush_di dvpslap_di dvptwist_di dvppunch_di dvpchoke_di dvpkick_di dvpknife_di dvpsex_di dvpsexoth_di)

*tab sample ipv_any [aw=dvweight]
 
* Need to limit this to correct sample size
*graph hbar (mean) ipv_any [aweight = dvweight], over(sample, label(angle(horizontal))) ytitle(Percent experiencing any IPV)



** To construct something like POPWT
*Calculate the sum of FQWEIGHT for all eligible women (age 15 to 49) within the sample of interest.
* POPWT of individual i = (FQWEIGHT of individual i / Sum of FQWEIGHT in the sample) * Total population of women 15 to 49 in that country in that year.
merge m:1 country year using women_annual_population.dta, nogen
keep in 1/2020319
destring Populationaged1549, gen(pop1549)

sort sample
by sample: egen sumperweiht = total(perweight) if age>14 & age<50

gen womwt = (perweight/sumperweiht) * (pop1549 * 1000)
replace womwt=0 if womwt==.
label variable womwt "women aged 15-49 population adjustment factor"
order womwt, a(awfactt)
drop Populationaged1549 pop1549 sumperweiht


keep if resident==1 | country==430

* Droping clusters with less than 10 cases
bys dhsid: gen dup_dhsid=_N
drop if dup_dhsid <10
drop dup_dhsid


* marstat - women's current marital or union status
* 10=never married; 11=unconsummated marriage; 20=married or living together; 21=married; 22=living together; 31=widowed; 32=divorced; 33=separated-not living together; 98=missing
recode marstat (11/22=1 yes) (98=.) (nonmiss=0 no), gen(marstat_d)
label variable marstat_d "currently married dummy"
order marstat_d, a(marstat)

recode marstat (10=0 no) (11/34=1 yes)  (98=.), gen(ever_married)
label variable ever_married "Ever married"
order ever_married, a(marstat_d)

* agefrstmar - age at first marriage
* range from 0 to 63, with niu of 479,000. As in marstat there are 450,679 who never married, it seems that the never married were classified as niu.
* Following Pierotti 2013, creating categorical variable - first married at age 15 years or younger, married between age 16 and age 19, and age 20 or older
recode agefrstmar (0/15=1) (16/19=2) (20/63=3) (99=.), gen(agefrstmar_c)
label define c_agel 1 "Age when married: -15" 2 "Age when married: 16-19" 3 "Age when married: +20"
label values agefrstmar_c c_agel
label variable agefrstmar_c "Age at first marriage or cohabitation by categories"
order agefrstmar_c, a(agefrstmar)

recode agefrstmar (0/17=1) (18/63=0) (99=.), gen(mar18)
label define age18l 1 "Under age 18 when married" 0 "Age 18 and over when married"
label values mar18 age18l
label variable mar18 "Under age 18 at first marriage or cohabitation"
order mar18, a(agefrstmar_c)

by dhsid, sort: egen mar18pc = mean(100 * mar18)
label variable mar18pc "% Under age 18 when married"
order mar18pc, a(mar18)

* Three main religions
recode religion (1000=1) (2000/2999=2) (4000=3) (9998=.) (nonmiss=.), gen(religion_c)
label define reli_c 1 "Muslim" 2 "Christian" 3 "Hindu"
label values religion_c reli_c
label variable religion_c "Religion"
order religion_c, after(religion)

*Four main religions
recode religion (1000=1) (2100=2) (2300/2901=3) (4000=4) (9998=.) (nonmiss=.), gen(religion_4c)
label define reli_4c 1 "Muslim" 2 "Catholic" 3 "Protestant" 4 "Hindu"
label values religion_4c reli_4c
label variable religion_4c "Religion"
order religion_4c, after(religion_c)

*Main religions
recode religion (0=0 "No religion") (1000=1 "Muslim") (2000/2999=2 "Christian") (3000/3999=3 "Buddhist") (4000=4 "Hindu") (6000/6999=6 "Traditional") (9000=9 "Other") (5000 7000/7999=9) (9998=.), gen(religion_cf)
label variable religion_cf "Religion"
order religion_cf, a(religion_c)

* Three main religions + other
*recode religion (1000=1) (2000/2999=2) (4000=3) (9998=.) (nonmiss=4), gen(religion_c)
*label define reli_c 1 "Muslim" 2 "Christian" 3 "Hindu" 4 "Other"
*label values religion_c reli_c
*label variable religion_c "Religion by categories"
*order religion_c, after(religion)


*** Religious composition of community

* First recode into dummies
recode religion_c (1=1) (2/3 = 0) , gen(muslim)
label define musliml 1 "Muslim" 0 "Non Muslim"
label values muslim musliml
label variable muslim "Muslim"
order muslim, a(religion_c)

recode religion_c (2=1) (1 3 = 0) , gen(christian)
label define christianl 1 "Christian" 0 "Non Christian"
label values christian christianl
label variable christian "Christian"
order christian, a(muslim)

recode religion_c (3=1) (1 2 = 0), gen(hindu)
label define hindul 1 "Hindu" 0 "Non Hindu"
label values hindu hindul
label variable hindu "Hindu"
order hindu, a(christian)

* Get the % of each religion in every cluster
by dhsid, sort: egen muslimpc = mean(100 * muslim)
label variable muslimpc "% Muslim"
order muslimpc, a(muslim)

recode muslimpc (0/33.4=1) (33.5/66.7=2) (66.8/100=3), gen(muslimmaj)
label define muslimmajl 1 "Muslim minority" 2 "Muslim equal" 3 "Muslim majority"
label values muslimmaj muslimmajl
label variable muslimmaj "Muslim majority-minority"
order muslimmaj, a(muslimpc)

by dhsid, sort: egen christianpc = mean(100 * christian)
label variable christianpc "% Christian"
order christianpc, a(christian)

by dhsid, sort: egen hindupc = mean(100 * hindu)
label variable hindupc "% Hindu"
order hindupc, a(hindu)


* currwork - currently working
* 0=no; 10=yes; 11=yes spontaneous; 12= yes prompted; 98=missing; 99=niu
recode currwork (0=0 no) (10/12=1 yes) (98 99 = .), gen(currwork_d)
label define currwork_i 0 "Currently not working" 1 "Currently working"
label values currwork_d currwork_i
label variable currwork_d "Currently working"
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
label define educlvl_l 0 "None" 1 "Primary school" 2 "Secondary school" 3 "Higher"
label values educlvl educlvl_l
label variable educlvl "Education"

* edyrtotal - women's total years of education
* 0/27=years of education 96=inconsistent; 97=don't know; 98=missing
replace edyrtotal=. if edyrtotal>95

* husedlvl - partner's educational level
* 0=no education; 1=primary; 2=secondary; 3=higher; 4=other; 7=don't know; 8/9=missing and not in universe
replace husedlvl=. if husedlvl>3
label define husedlvl_l 0 "Husb-educ none" 1 "Husb-educ primary" 2 "Husb-educ secondary" 3 "Husb-educ higher"
label values husedlvl husedlvl_l

* husedyrs - partner's education in total years
* 0/26=years of education; 95=other; 96=inconsistent; 97=don't know; 98/99=missing and not in universe
replace husedyrs =. if husedyrs>94

* Education gap
gen edugap = educlvl - husedlvl
recode edugap (0 = 1) (1/3 = 2) (-3/-1 = 0)
label define edugapl 0 "Woman has less educ" 1 "Woman have equal educ as partner" 2 "Woman has more educ"
label values edugap edugapl
label variable edugap "Education gap"
order edugap, a(husedyrs)


* radiobrig - listens to radio: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing

replace radiobrig=0 if radioday==0
replace radiobrig=10 if radioday==1

recode radiobrig (0/2=0 no) (10/12=1 yes) (98=.), gen(radio)
label define radiol 0 "Doesn't listens to radio" 1 "Listens to radio frequently"
label values radio radiol
label variable radio "Listens to radio frequently"

* newsbrig - reads newspaper: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing, 99=niu
recode newsbrig (0/2=0 no) (10/12=1 yes) (98/99=.), gen(newspaper)
label variable newspaper "woman reads newspapers"

* tvbrig - watches television - bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing
recode tvbrig (0/2=0 no) (10/12=1 yes) (98=.), gen(tv)
label variable tv "woman watches television"

* internetmo - fq of using internet in  last month
* 0=not al all; 1=less than once a week; 2=at least once a week; 3=almost every day; 8=missing
recode internetmo (0/1=0 no) (2/3=1 yes) (8=.), gen(internet)
label variable internet "woman uses the internet"

* media access - indicates if a woman have a weekly access to radio, newspaper or tv. Pierotti 2013 used a similar variable
gen media_access_old = max(radio, newspaper, tv)
label variable media_access_old "women's media access"
label define medial 0 "No media access" 1 "Has media access"
label values media_access_old medial

gen media_access = max(radio, newspaper, tv, internet)
label variable media_access "Women's media access"
label values media_access medial

gen radio_tv = max(radio, tv)
gen only_news =.
replace only_news=0 if radio_tv==0
replace only_news=0 if newspaper==0
replace only_news=0 if newspaper==1 & radio_tv==1
replace only_news=1 if newspaper==1 & radio_tv==0

*decbighh - final say on making large household purchases
* 10=woman; 20=woman and husband; 30=woman and someone else; 40=husband; 50=someone else; 51=other male; 52=other female; 60=other; 98=missing; 99=niu (n=912,611)
recode decbighh (10/30=1 yes) (40/60=0 no) (98 99 =.), gen(decbighh_d)
label variable decbighh_d "woman have a say in making large household purchases"

* decdailypur - final say on household purchases for dayily needs
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


* dv attitudes 
* 0=no; 1=yes; 7=don't know; 8/9 are missing and not in universe
* very few 7s, so let's skip them

* Liz, the dvapreshusb and dvapresomale have a large missing (nearly 650,000) - should we count the answers of women only when no male was present or was not listening?
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
* Mean of this will be a true mean, ranging from 0-5, reflecting level of opposition to beating within the cluster.
label variable dvunjustindex "opposition to wife beating index"
label define dvunjustindexl 0 "never" 1 "seldom" 2 "some of the time" 3 "often" 4 "very often" 5 "always"
label values dvunjustindex dvunjustindexl

recode dvunjustindex (0/4=0 no) (5=1 yes), gen(dvunjust_d)
label variable dvunjust_d "always oppose wife beating"


* build a new 4 cat var - coupling - if wife beating is ungesitifed and woman have  0, =1 if dosn't have a final say, ... 0-4

*************************************************************************
* Our dependent variable - rejection of IPV and household empowerment
generate decoupling=.
replace decoupling=3 if decindex_d==0 & dvunjust_d==0
replace decoupling=2 if decindex_d==0 & dvunjust_d==1
replace decoupling=1 if decindex_d==1 & dvunjust_d==0
replace decoupling=0 if decindex_d==1 & dvunjust_d==1
label variable decoupling "Attitude/empowerment correspondence possibilities"
label define decouplingl 0 "walk_talk" 1 "walk_notalk" 2 "talk_nowalk" 3 "neither"
label values decoupling decouplingl

recode decoupling (0=0) (3=2) (1/2 = 1), gen(decoupling_3a)
label variable decoupling_3a "Decoupling - pro-decoupled"
label define dec3a 0 "Supports gender equity/Empowered in household" 2 "Rejects gender equity/Not empowered in household" 1 "Decoupled"
label values decoupling_3a dec3a

recode decoupling (0 3 = 1) (1 = 0) (2 = 2), gen(decoupling_3b)
label variable decoupling_3b "Decoupling - pro-coupled"
label define dec3b 0 "Rejects gender equity/Empowered in household" 2 "Supports gender equity/Not empowered in household" 1 "Coupled"
label values decoupling_3b dec3b

recode decoupling (0=1) (1/3=0), gen(de1)
label variable de1 "Walking and Talking"

recode decoupling (1=1) (0 2 3 =0), gen(de2)
label variable de2 "Walking but not Talking"

recode decoupling (2=1) (0 1 3 =0), gen(de3)
label variable de3 "Not Walking but Talking"

recode decoupling (3=1) (0/2=0), gen(de4)
label variable de4 "Neither Walking nor Talking"

order decoupling, a(dvweight)
order decoupling_3a, a(decoupling)
order decoupling_3b, a(decoupling_3a)
order de1, a(decoupling_3b)
order de2, a(de1)
order de3, a(de2)
order de4, a(de3)

* Get the % of each category in every cluster
by dhsid, sort: egen de1pc = mean(100 * de1)
label variable de1pc "% Walking and talking"
order de1pc, a(de1)

by dhsid, sort: egen de2pc = mean(100 * de2)
label variable de2pc "% Walking but not talking"
order de2pc, a(de2)

by dhsid, sort: egen de3pc = mean(100 * de3)
label variable de3pc "% Not walking but talking"
order de3pc, a(de3)

by dhsid, sort: egen de4pc = mean(100 * de4)
label variable de4pc "% Neither walking not talking"
order de4pc, a(de4)

***********************************************************************************
*** Our alternative dependent variable - experience of IPV and household empowerment
generate ipv_empowerment=.
replace ipv_empowerment=3 if decindex_d==0 & ipv_any==1
replace ipv_empowerment=2 if decindex_d==0 & ipv_any==0
replace ipv_empowerment=1 if decindex_d==1 & ipv_any==1
replace ipv_empowerment=0 if decindex_d==1 & ipv_any==0
label variable ipv_empowerment "Empowered / IPV"
label define ipv_eml 0 "Empowered and no IPV" 1 "Empowered but experienced IPV" 2 "Disempowered and no IPV" 3 "Disempowered and experienced IPV"
label values ipv_empowerment ipv_eml

recode ipv_empowerment (0=1) (1/3=0), gen(ipv_emp1)
label variable ipv_emp1 "Empowered and no IPV"

recode ipv_empowerment (1=1) (0 2 3 =0), gen(ipv_emp2)
label variable ipv_emp2 "Empowered but experienced IPV"

recode ipv_empowerment (2=1) (0 1 3 =0), gen(ipv_emp3)
label variable ipv_emp3 "Disempowered and no IPV"

recode ipv_empowerment (3=1) (0/2=0), gen(ipv_emp4)
label variable ipv_emp4 "Disempowered and experienced IPV"

order ipv_empowerment, a(de4pc)
order ipv_emp1, a(ipv_empowerment)
order ipv_emp2, a(ipv_emp1)
order ipv_emp3, a(ipv_emp2)
order ipv_emp4, a(ipv_emp3)

* Get the % of each category in every cluster
by dhsid, sort: egen ipv_emp1pc = mean(100 * ipv_emp1)
label variable ipv_emp1pc "% Empowered and no IPV"
order ipv_emp1pc, a(ipv_emp1)

by dhsid, sort: egen ipv_emp2pc = mean(100 * ipv_emp2)
label variable ipv_emp2pc "% Empowered but experienced IPV"
order ipv_emp2pc, a(ipv_emp2)

by dhsid, sort: egen ipv_emp3pc = mean(100 * ipv_emp3)
label variable ipv_emp3pc "% Disempowered and no IPV"
order ipv_emp3pc, a(ipv_emp3)

by dhsid, sort: egen ipv_emp4pc = mean(100 * ipv_emp4)
label variable ipv_emp4pc "% Disempowered and experienced IPV"
order ipv_emp4pc, a(ipv_emp4)

**************************************************************

*** Our alternative dependent variable - experience of and attitudes towards IPV 
generate ipv_exp=.
replace ipv_exp=3 if dvunjust_d==0 & ipv_any==1
replace ipv_exp=2 if dvunjust_d==0 & ipv_any==0
replace ipv_exp=1 if dvunjust_d==1 & ipv_any==1
replace ipv_exp=0 if dvunjust_d==1 & ipv_any==0
label variable ipv_exp "Attitude/experienced IPV"
label define ipv_exp1 0 "Rejects and no IPV" 1 "Rejects IPV but experienced IPV" 2 "Approve IPV but not experienced IPV" 3 "Approve IPV and experienced IPV"
label values ipv_exp ipv_exp1

recode ipv_exp (0=1) (1/3=0), gen(ipv_exp1)
label variable ipv_exp1 "Rejects and no IPV"

recode ipv_exp (1=1) (0 2 3 =0), gen(ipv_exp2)
label variable ipv_exp2 "Rejects IPV but experienced IPV"

recode ipv_exp (2=1) (0 1 3 =0), gen(ipv_exp3)
label variable ipv_exp3 "Approve IPV but not experienced IPV"

recode ipv_exp (3=1) (0/2=0), gen(ipv_exp4)
label variable ipv_exp4 "Approve IPV and experienced IPV"

order ipv_exp, a(ipv_emp4pc)
order ipv_exp1, a(ipv_exp)
order ipv_exp2, a(ipv_exp1)
order ipv_exp3, a(ipv_exp2)
order ipv_exp4, a(ipv_exp3)

by dhsid, sort: egen ipv_exp2pc = mean(100 * ipv_exp2)
label variable ipv_exp2pc "% Rejects IPV but experienced IPV"
order ipv_exp2pc, a(ipv_exp2)

*****************************************************************
recode urban (2 = 0) (1 = 1)
label define urbanl 0 "Rural residence" 1 "Urban residence"
label values urban urbanl
label variable urban "Urban residence"


*** I am exluding Liberia as there is no data on attitudes in 2007
recode sample (5006 10802 12003 18001 20402 23102 28804 32402 35603 40003 40404 42601 45003 45003 45402 46603 50802 51603 52402 56203 56603 58603 64603 68604 71603 80003 81806 83404 85403 89404 = 1 "First wave") (5007 10803 12004 18002 20404 23104 28806 32403 35604 40007 40406 42603 45004 45004 45405 46605 50803 51604 52405 56204 56605 58604 64606 68610 71605 80006 81808 83406 85404 89405 = 2 "Second wave") (nonmiss=.), gen(waves2)
label variable waves2 "Maximum variation two waves"
order waves2, a(samplestr)

*recode sample (10802 12003 18001 20402 23103 28805 32402 40405 42601 45404 46604 51603 52404 56604 64604 68608 71605 81806 85403 89404 = 0 "first wave") (10803 12004 18002 20404 23104 28806 32403 40406 42602 45405 46605 51604 52405 56605 64605 68609 71606 81807 85404 89405 = 1 "second wave") (nonmiss=.), gen(waves2)


*recode sample (23102 28804 40404 45403 46603 56603 64603 68606 71604 81805 = 0 "first wave") (23103 28805 40405 45404 46604 56604 64604 68608 71605 81806 = 1 "second wave") (23104 28806 40406 45405 46605 56605 64605 68609 71606 81807 = 2 "third wave") (nonmiss=.), gen(waves3)
*label variable waves3 "there waves"
*order waves3, a(waves2)

***  81804 6 7 8
recode sample (23102 28804 40404 45402 46603 56603 64602 68604 71603 81806 = 0 "First wave") (23103 28805 40405 45404 46604 56604 64603 68606 71604 81807 = 1 "Second wave") (23104 28806 40406 45405 46605 56605 64605 68609 71605 81808 = 2 "Third wave") (nonmiss=.), gen(waves3)
label variable waves3 "Maximum variation there waves"
order waves3, a(waves2)

*recode sample (10802 12003 18001 20402 23102 23103 28804 28805 32402 40404 40405 42601 45402 45403 45404 46603 46604 51603 52404 56603 56604 64603 64604 68604 68605 68606 68608 71603 71604 71605 81805 81806 85403 89404 = 0 "previous waves") (10803 12004 18002 20404 23104 28806 32403 40406 42602 45405 46605 51604 52405 56605 64605 68609 71606 81807 85404 89405 = 1 "last wave") (nonmiss=.), gen(last_wave1)
*label variable last_wave1 "alternative last wave"
*order last_wave1, a(waves3)

*recode sample (5005 5006 10802 12003 18001 20402 20403 23102 23103 28804 28805 32402 35603 40003 40004 40404 40405 40006 42601 42602 45003 45402 45403 45404 46603 46604  50802 51601 51603 52402 52403 52404 56203 56603 56604 58603 64602 64603 64604 68604 68605 68606 68607 68608 68609 71603 71604 71605 80003 80004 80005 81805 81806 83404 83405 85403 89404 = 0 "previous waves") (nonmiss=1 "last wave"), gen(last_wave)
*label variable last_wave "last wave"
*order last_wave, a(last_wave1)


* Fix some labels

label define wealthq_l 1 "Poorest wealth quintile" 2 "Poor wealth quintile" 3 "Middle wealth quintile" ///
4 "Rich wealth quintile" 5 "Richest wealth quintile"
label values wealthq wealthq_l
label variable wealthq "Household wealth"

label variable age "Age"


* For wealthiest qualitie
recode wealthq (1/4 = 0) (5=1) (8=.), gen(wealthq_5)
label define wlt_l 0 "Bottom 4" 1 "Richest"
label values wealthq_5 wlt_l
label variable wealthq_5 "Wealthiest quintile"
order wealthq_5, after(wealthq)

** Save to a new file
save 02_women, replace

