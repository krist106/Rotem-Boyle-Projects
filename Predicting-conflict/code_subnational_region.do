** Create subnational region variable with labels **

decode(country), gen(ct)
levelsof ct, local(ctstring)

foreach var of varlist geo* {
gen `var'_copy = `var'
}
drop geo_cm2004_2011_copy
drop geo_gn1999_2012_copy geo_gn2005_2012_copy
drop geoalt_mw2010_2016_copy
drop geoalt_ng2008_2013_copy
replace geo_rw1992_2005_copy = . if year == 2005
* see that rw is ok
drop geo_tz1991_2015_copy
*drop geo_ug2006_2011_copy
*my change:
drop geo_ug2006_2016_copy
drop geo_eg1988_2014_copy
drop geoalt_ls2004_2014_copy
drop geo_ml1987_2012_copy
drop geo_nm1992_2013_copy
drop geo_sn2012_2014_copy geo_sn2015_2016_copy

foreach var of varlist geo_bj1996_2011-geo_zw1994_2015 {
decode `var', gen(`var'str)
}
drop geo_cm2004_2011str
drop geo_gn1999_2012str geo_gn2005_2012str
drop geoalt_mw2010_2016str
drop geoalt_ng2008_2013str
replace geo_rw1992_2005str = "" if year == 2005
drop geo_tz1991_2015str
* drop geo_ug2006_2011str
*my change:
drop geo_ug2006_2016str
drop geo_eg1988_2014str
*drop geo_gn1999_2012str
*drop geo_gn2005_2012str
drop geoalt_ls2004_2014str
drop geo_ml1987_2012str
drop geo_nm1992_2013str
drop geo_sn2012_2014str geo_sn2015_2016str

egen region_temp = rowmax(geo_*_copy geoalt_*_copy)
drop geo_*copy geoalt*_copy

gen subnational = country*100 + region_temp
replace subnational = country*100 if subnational == .


egen region_label_t_gen = concat(geo*str)
gen region_label_gen = ct + " " + substr(region_label_t_gen,1,30)
egen idregion_gen = group(region_label_gen)
label variable idregion_gen "Subnational region identifier - general"

sort subnational
lab def subnational_gen 1 "temp"
levelsof(idregion_gen), local(levels)

foreach l of local levels {
gen temp = ""
replace temp = region_label_gen if idregion_gen == `l'
levelsof(temp), local(templabel)
lab def reg_label_gen `l' `templabel', modify
drop temp
}
label values idregion_gen reg_label_gen
label variable region_label_gen "Full subnational region labels - general"
drop subnational
drop geo*str region_temp
drop region_label_t_gen

** End general region creation **