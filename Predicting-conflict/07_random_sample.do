*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

**********************
*** Run split/random sample ***
**********************

cd "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data"
clear

use 06_additional_datasets_merged, replace

*** random sample ***

* as there are 2,432 observations with battles, we need to sample 3,106 observations without battles
sample 2432 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1, replace

use 06_additional_datasets_merged, replace
* as there are 2,399 observations with leg2 battles, we need to sample 2,881 observations without battles
sample 2399 if battles_l2 == 0, count
drop if battles_l2==.
drop battles_l1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg2, replace

use 06_additional_datasets_merged, replace
* as there are 354 observations with leg1 five battles plus, we need to sample 587 observations without battles
sample 354 if battles_five_l1 == 0, count
drop if battles_five_l1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l2 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battle_leg1_five, replace

use 06_additional_datasets_merged, replace
* as there are 5,492 observations with riots, we need to sample 6,653 observations without riots
sample 5492 if riots_l1 == 0, count
drop if riots_l1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l2 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_riots_l1, replace

use 06_additional_datasets_merged, replace
* as there are 4,061 observations with violence against civilians, we need to sample 5,011 observations without violence against civilians
sample 4061 if civ_violence_l1 == 0, count 
drop if civ_violence_l1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l2
save 07_random_sample_civ_violence_l1, replace

use 06_additional_datasets_merged, replace
keep if regions ==1
save 06_battles_leg1_north, replace
* there are 992 observations with battles
sample 460 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_north, replace

use 06_additional_datasets_merged, replace
keep if regions == 2
save 06_battles_leg1_southern, replace
* there are 383 observations with battles
sample 383 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_southern, replace

use 06_additional_datasets_merged, replace
keep if regions == 3
save 06_battles_leg1_east, replace
* there are 630 observations with battles
sample 630 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_east, replace

use 06_additional_datasets_merged, replace
keep if regions == 4
save 06_battles_leg1_west, replace
* there are 723 observations with battles
sample 723 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_west, replace

use 06_additional_datasets_merged, replace
keep if regions == 5
save 06_battles_leg1_central, replace
* there are 312 observations with battles
sample 236 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_central, replace

use 06_additional_datasets_merged, replace
keep if decades ==2
save 06_battles_leg1_1997_2007, replace
* there are 595 observations with battles
sample 543 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_1997_2007, replace

use 06_additional_datasets_merged, replace
keep if decades ==3
save 06_battles_leg1_2008_2017, replace
* there are 1889 observations with battles
sample 1889 if battles_l1 == 0, count
drop if battles_l1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1
save 07_random_sample_battles_leg1_2008_2017, replace
