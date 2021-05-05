*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"

use 00_dhs_women.dta, replace


**********************
*** Using dhsid and collapse for the women file ***
**********************

keep if resident==1

* Droping clusters with less than 10 cases
bys dhsid: gen dup_dhsid=_N
drop if dup_dhsid <10
drop dup_dhsid



* marstat - women's current marital or union status
* 10=never married; 11=unconsummated marriage; 20=married or living together; 21=married; 22=living together; 31=widowed; 32=divorced; 33=separated-not living together; 98=missing
recode marstat (11/22=1 yes) (98=.) (nonmiss=0 no), gen(marstat_d)
label variable marstat_d "currently married women dummy"

* currwork - currently working
* 0=no; 10=yes; 11=yes spontaneous; 12= yes prompted; 98=missing; 99=niu
recode currwork (0=0 no) (10/12=1 yes) (98 99 = .), gen(currworkwm)
label variable currworkwm "currently working women dummy"

* wkemploywhen
*gen employment =.
*replace employment=0 if currwork_d==0
*replace employment=1 if wkemploywhen==10
*replace employment=2 if wkemploywhen==23
*replace employment=3 if wkemploywhen==24 | wkemploywhen==25
*label define employmentl 0 "doesn't work" 1 "all year" 2 "seasonally" 3 "occasionlly"
*label values employment employmentl
*label variable employment "woman works all year, seasonally, occasionally, or not at all"

* wkearntype
recode wkearntype (0 3 =0) (1 2 =1) (8/9 =.), gen(paidcashwm)
label define paidcashwml 0 "not paid in cash" 1 "paid in cash"
label values paidcashwm paidcashwml
label variable paidcashwm "woman paid in cash"

gen laborforcewm =.
replace laborforcewm=0 if currworkwm==0
replace laborforcewm=0 if currworkwm==1 & paidcashwm==0
replace laborforcewm=1 if currworkwm==1 & paidcashwm==1
label define laborforcewml 0 "women unengaged in the labor force" 1 "women engaged in the labor force"
label values laborforcewm laborforcewml
label variable laborforcewm "women engagment in the labor force"

* educlvl - highest educational level
* 0=no education; 1=primary; 2=secondary; 3=higher; 8=missing
*recode educlvl (0=0 no) (8=.) (nonmiss=1 yes), gen(anyeducation)
*label variable anyeducation "any education women"


* edyrtotal - women's total years of education
* 0/27=years of education 96=inconsistent; 97=don't know; 98=missing
replace edyrtotal=. if edyrtotal>95

* husedlvl - partner's educational level
* 0=no education; 1=primary; 2=secondary; 3=higher; 4=other; 7=don't know; 8/9=missing and not in universe
*recode husedlvl (0=0 no) (1/3=1 yes) (4/9=.), gen(anyeducationhus)
*label variable anyeducationhus "any education partner's" 

* husedyrs - partner's education in total years
* 0/26=years of education; 95=other; 96=inconsistent; 97=don't know; 98/99=missing and not in universe
replace husedyrs =. if husedyrs>94

* Education gap
gen edugap = edyrtotal - husedyrs
recode edugap (-26/-1 = 0) (nonmiss=1)
label define edugapl 0 "less" 1 "equal or more"
label values edugap edugapl
label variable edugap "woman have equal more education than partner"


* radiobrig - listens to radio: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing
recode radiobrig (0/2=0 no) (10/12=1 yes) (98=.), gen(radio)
label variable radio "women listen to radio"

* newsbrig - reads newspaper: bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing, 99=niu
recode newsbrig (0/2=0 no) (10/12=1 yes) (98/99=.), gen(newspapers)
label variable newspapers "women reads newspapers"

* tvbrig - watches television - bridging variable
* 0=no; 1=not at all; 2=less than once a week; 10=yes; 11=at least once a week; 12=almost every day; 98=missing
recode tvbrig (0/2=0 no) (10/12=1 yes) (98/99=.), gen(tv)
label variable tv "women watches television"

* media access - indicates if a woman have a weekly access to radio, newspaper or tv. Pierotti 2013 used a similar variable
gen media_access = max(radio, newspaper, tv)
label variable media_access "women's media access"


* decfemearn - final say on spending woman's earnings
recode decfemearn (10/30=1 yes) (40/60=0 no) (98 99 =.), gen(decfemearn_d)

* decdailypur - final say on household purchases for dayily needs
* the total n is 478,893 so I think we should drop this variable - it will lower our total n

*decbighh - final say on making large household purchases
* 10=woman; 20=woman and husband; 30=woman and someone else; 40=husband; 50=someone else; 51=other male; 52=other female; 60=other; 98=missing; 99=niu (n=245,927)
recode decbighh (10/30=1 yes) (40/60=0 no) (98 99 =.), gen(decbighh_d)
label variable decbighh_d "woman have a say in making large household purchases"


* decfemhcare - final say on woman's health care
* 1=woman alone; 2=woman and husband; 3=woman and someone else; 4=husband; 5=someone else; 6=other; 8=missing; 9=niu (n=250,718)
recode decfemhcare (1/3=1 yes) (4/6=0 no) (8 9 =.), gen(decfmhcare_d)
label variable decfmhcare_d "woman have a say on woman's health care"

* decfamvisit - final say on visits to family or relatives
* 1=woman alone; 2=woman and husband; 3=woman and someone else; 4=husband; 5=someone else; 6=other; 8=missing; 9=niu (n=250,716)
recode decfamvisit (1/3=1 yes) (4/6=0 no) (8 9 =.), gen(decfamvisit_d)
label variable decfamvisit_d "woman have a say on visits to family or relatives"

* Index variable - final say
generate decindex1= decfemearn_d + decbighh_d + decfmhcare_d + decfamvisit_d
label variable decindex1 "woman have a final say index"
label define decl 0 "never" 1 "seldom" 2 "some of the time" 3 "often" 4 "always"
label values decindex1 decanyl

generate decindex= decbighh_d + decfmhcare_d + decfamvisit_d
label variable decindex "woman have a final say index"
label define decl1 0 "never" 1 "seldom" 2 "often" 3 "always"
label values decindex decl



*** Liz, 
*** fpdecider - decision-maker for using fp have 800,630 not in universe. 
*** husprofp - husband approve fp use - have a total of 599,644, out of which 183,073 niu
*** fpldisreas5y - reason of last discontinuation have a total of 641,564, out of which 490,446 niu
*** fplastsrcs - last source for fp for current users have 1,060,012 not in universe
*** fptalkhusno - number of times discused fp with partner have a total of 606,637, out of which 191,962 niu
*** I think these variables should be removed


* dv attitudes 
* 0=no; 1=yes; 7=maybe; 8/9 are missing and not in universe
* very few 7s, so let's skip them
* note that we are reversing the coding
generate dvjustargue=.
replace dvjustargue=1 if dvaargue==0
replace dvjustargue=0 if dvaargue==1
label variable dvjustargue "wife beating is unjustified if woman argues with him"

generate dvjustburnfood=.
replace dvjustburnfood=1 if dvaburnfood==0
replace dvjustburnfood=0 if dvaburnfood==1
label variable dvjustburnfood "wife beating is unjustified if woman burns food"

generate dvjustgoout=.
replace dvjustgoout=1 if dvagoout==0
replace dvjustgoout=0 if dvagoout==1
label variable dvjustgoout "wife beating is unjustified if woman goes out without telling him"

generate dvjustifnosex=.
replace dvjustifnosex=1 if dvaifnosex==0
replace dvjustifnosex=0 if dvaifnosex==1
label variable dvjustifnosex "wife beating is unjustified if woman refused to have sex"

generate dvjustnegkid=.
replace dvjustnegkid=1 if dvanegkid==0
replace dvjustnegkid=0 if dvanegkid==1
label variable dvjustnegkid "wife beating is unjustified if woman neglects the children"


* The mean of the variables above will be percent who justify beating under the different circumstances.

* Index variable
generate dvujustindex=dvjustargue + dvjustburnfood + dvjustgoout + dvjustifnosex + dvjustnegkid
* Mean of this will be a true mean, ranging from 0-5, reflecting level of justification of beating within the cluster.
label variable dvujustindex "wife beating unjustified index"
label define dvujustindexl 0 "never" 1 "seldom" 2 "some of the time" 3 "often" 4 "very often" 5 "always"
label values dvujustindex dvujustindexl



* bhcpermit - barrier to woman's health care: getting permission
* 10= not a big problem; 11=no probkem at all; 12=small problem; 20=is big problem; 98/99 missing and not in universe
recode bhcpermit (10/11=0 "not a problem") (12/20=1 "a problem") (98/99=.), gen(bhcpermit_d)
label variable bhcpermit_d "getting permission is a barrier to woman's health care"

* Regions of the African Union
* North egypt 818; marocco 504; tunisia 788; 
* Southern angola 24; lesotho 426; malawi 454; mozambique 508; namibia 516; south africa 710; zambia 894; zimbabwe 716
* East ethiopia 231; kenya 404; madagascar 450; rwanda 646; sudan 729; tanzania 834; uganda 800
* West benin 204; burkina faso 854; cote d'ivoire 384; ghana 288; guinea 324; mali 466; niger 562; nigeria 566; senegal 686
* Central burundi 108; cameroon 120; congo democratic republic 180; 

recode country (818 504 788 = 1 North) (24 426 454 508 516 710 894 716 = 2 Southern) (231 404 450 646 729 834 800 = 3 East) (204 854 384 288 324 466 562 566 686 = 4 West) (108 120 180 = 5 Central), gen(regions)
label variable regions "Regions of the African Union"

recode year (1986/1996 = 1 "1986 to 1996") (1997/2007 = 2 "1997 to 2007") (2008/2017 = 3 "2008 to 2017"), gen(decades)
label variable decades "decades of sample"

recode urban (2 = 0) (1 = 1)

rename sample sample_id

* Copy variable labels before collapse 
* https://www.stata.com/support/faqs/data-management/keeping-same-variable-with-collapse/ 

** Note that I removed  idregion_gen from the collapse code
foreach v of var * {
        local l`v' : variable label `v'
            if `"`l`v''"' == "" {
            local l`v' "`v'"
        }
}


collapse marstat_d currworkwm paidcashwm laborforcewm edugap radio tv newspapers media_access decindex dvujustindex bhcpermit_d urban, /// 
by(dhsid country year regions decades sample_id)

* Attach the saved labels after collapse - for this to work the original variable names should be kept
foreach v of var * {
        label var `v' "`l`v''"
}
 
* renaming the variables
* rename (di_marstat di_currwork anyeducation edyrtotal anyeducationhus husedyrs radio di_decbighh di_decfmhcare di_decfamvisit decindex idealkid refusex refusex_othwf dvjustargue dvjustburnfood dvjustgoout dvjustifnosex dvjustnegkid dvjustindex di_dveever di_dvpslap di_dvppunch di_dvpsex di_dvpsexever dveventindex di_bhcpermit) (pctmarried pctcurrwork pctanyeducation avgedyrtotal pctanyeducationhus avghusedyrs pctradio pctdecbighh pctdecfmhcare pctdecfamvisit avgdecindex aveidealkid pctrefusex pctrefusex_othwf pctdvjustargue pctdvjustburnfood pctdvjustgoout pctdvjustifnosex pctdvjustnegkid avgdvjustindex pctdveever pctdvpslap pctdvppunch pctdvpsex pctdvpsexever avgdveventindex pctbhcpermit)

replace urban =. if urban>0 & urban<1
label define urbanl 0 "rural" 1 "urban"
label values urban urbanl

** Save to a new file
save 02_dhs_women_collapse, replace
