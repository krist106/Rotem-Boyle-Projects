*******************************************************************************
***                                                                         ***
***                     Eearly warning models								***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 01.028.2020

**********************
*** Python works best with numbers only and in CVS format ***
**********************

cd "C:\Users\Nir\PycharmProjects\Nir"
clear


*** full sample *** 
use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
drop if battles_l1==.
drop if battles_p1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1 
drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban
export delimited using "08_full_battles_leg1", nolabel replace


use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
drop if battles_l2==.
drop if battles_p1==.
drop battles_l1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1 
drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban
export delimited using "08_full_battles_leg2", nolabel replace


use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
drop if riots_l1==.
drop if riots_p1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l2 civ_violence_l1 civ_violence_l2 civ_violence_p1 
drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban
export delimited using "08_full_riots_leg1", nolabel replace


use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
drop if civ_violence_l1==.
drop if civ_violence_p1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l2  
drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban
export delimited using "08_full_civ_violence_leg1", nolabel replace


*** random sample ***

use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
* as there are 2,432 observations with battles, we need to sample 3,106 observations without battles
sample 2432 if battles_l1 == 0, count
drop if battles_l1==.
drop if battles_p1==.
drop battles_l2 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1

drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban

export delimited using "08_random_sample_battles_leg1", nolabel replace


use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
* as there are 2,399 observations with leg2 battles, we need to sample 2,881 observations without battles
sample 2399 if battles_l2 == 0, count
drop if battles_l2==.
drop if battles_p1==.
drop battles_l1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1

drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban

export delimited using "08_random_sample_battles_leg2", nolabel replace

use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
* as there are 354 observations with leg1 five battles plus, we need to sample 587 observations without battles
sample 354 if battles_five_l1 == 0, count
drop if battles_five_l1==.
drop if battles_p1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l2 riots_l1 riots_l2 riots_p1 civ_violence_l1 civ_violence_l2 civ_violence_p1

drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban

export delimited using "08_random_sample_battle_leg1_five", nolabel replace

use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
* as there are 5,492 observations with riots, we need to sample 6,653 observations without riots
sample 5492 if riots_l1 == 0, count
drop if riots_l1==.
drop if battles_p1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l2 civ_violence_l1 civ_violence_l2 civ_violence_p1

drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban

export delimited using "08_random_sample_riots_l1", nolabel replace

use "C:\Users\Nir\Documents\Projects\2020\Early warning systems\DHS data\06_additional_datasets_merged", replace
* as there are 4,061 observations with violence against civilians, we need to sample 5,011 observations without violence against civilians
sample 4061 if civ_violence_l1 == 0, count 
drop if civ_violence_l1==.
drop if battles_p1==.
drop battles_l1 battles_l2 battles_p1 battles_five_l1 battles_five_l2 battles_five_p1 riots_l1 riots_l2 riots_p1 civ_violence_l2

drop sample_id country year decades regions idregion_gen dhsid tv radio newspapers paidcashwm v2x_freexp_altinf v2clprptyw v2clacjstw v2csgender v2clgencl v2peapsgen aridity stuntingnewwho wastingnewwho bhcpermit_d currworkwm urban

export delimited using "08_random_sample_civ_violence_l1", nolabel replace

