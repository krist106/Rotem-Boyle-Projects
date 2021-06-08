

*** Religious composition of community


cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear

use 02_women.dta if never_married==0


drop religion_c
recode religion (1000=1) (2000/2999=2) (4000=3) (9998=.) (nonmiss=4), gen(religion_c)
label define reli_c 1 "Muslim" 2 "Christian" 3 "Hindu" 4 "Other"
label values religion_c reli_c
label variable religion_c "Religion by categories"
order religion_c, after(religion)

* I don't think that using collapse followed by merge is the best way. It is posible, using the following user written command:

gcollapse (mean) religion_pc = religion_c, by(dhsid country year) merge

* This will do the same using a different approch:
 by dhsid, sort: egen religion_pc = mean(100 * religion_c)
 
 * The problem, however, is that it is hard to know if a cluster includes a majority of hindo with few muslims, or with few chrisitians, for example...
 
 * The following is similar to what Hayford and Trinitappli did in their paper
 *  https://doi-org.ezp2.lib.umn.edu/10.1111/j.1468-5906.2011.01566.x

* First recode into dummies
recode religion_c (2=1) (1 3 4 =0) , gen(christian)
label define christianl 1 "Christian" 0 "Non Christian"
label values christian christianl
label variable christian "Christian"
order christian, a(muslim)

recode religion_c (3=1) (1 2 4 =0), gen(hindu)
label define hindul 1 "Hindu" 0 "Non Hindu"
label values hindu hindul
label variable hindu "Hindu"
order hindu, a(christian)

recode religion_c (4=1) (1/3=0), gen(other)
label define otherl 1 "Other" 0 "Non Other"
label values other otherl
label variable other "Other"
order other, a(hindu)

* Get the % of each religion in every cluster
by dhsid, sort: egen muslimpc = mean(100 * muslim)
label variable muslimpc "% Muslim"
order muslimpc, a(muslim)

by dhsid, sort: egen christianpc = mean(100 * christian)
label variable christianpc "% Christian"
order christianpc, a(christian)

by dhsid, sort: egen hindupc = mean(100 * hindu)
label variable hindupc "% Hindu"
order hindupc, a(hindu)

by dhsid, sort: egen otherpc = mean(100 * other)
label variable otherpc "% Other"
order otherpc, a(other)

* If we think that a minority-majority is important, we can create a variable that records if an individual belongs to her cluster majority or is forming a minority. For that, we will need a cutoff point for a minority, and maybe also think about a third category - 50/50.
