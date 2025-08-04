*************************************************
** file name: aim1_acs.do
** date created: 06/27/2025
** date modified: 07/04/2025
**			      07/05/2025
**				  07/06/2025
**				  07/16/2025
**
**
** NOTE1: modified from aim1.do (aim1_update.do)
**		  for the subset with ACS data
**
**
**
**


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New/"
use "working.dta",clear

codebook studyid
*N=43918/n=398041 (cohort3)
*N=98550/n=798665 (cohort2)

keep if cohort3==1



sort studyid visitdate,stable
merge m:1 studyid using T16_acs.dta
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       506,078
        from master                   497,877  (_merge==1)
        from using                      8,201  (_merge==2)

    Matched                           300,788  (_merge==3)
    -----------------------------------------

*/

codebook studyid if _merge==3 & cohort3==1
*N=16,338/n=222,972

keep if _merge==3
*(353,898 observations deleted)

codebook studyid
*N=16,338/n=222,972



**# derivation of new variables

* rename group
rename *_18 *

destring ep_pov,replace
*ep_pov_18: all characters numeric; replaced as double

gen pctnobroadband=100-pctbroadband
label var pctnobroadband "%households without broadband internet (derived)"
order pctnobroadband,after(pctbroadband)

*cd "Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New/Plots"

foreach y of var ep_pov-pctnohealthins{
	replace `y'=. if `y'<0
	
	*histogram `y' if visitno==1
	*graph export "hist_`y'.tif",replace 

}

sort studyid visitdate,stable
bys studyid: gen visitno=_n

tabstat ep_pov-nchs_urban if visitno==1,stat(p50 p25 p75 min max mean sd n) c(s)

tab nchs_urban if visitno==1


sort studyid visitdate,stable
save "working_acs.dta",replace






cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New/"

use "working_acs.dta",clear

codebook studyid
*N=16,338/n=222,972

sort studyid visitdate,stable
bys studyid: egen tlvisitno=max(visitno)
*range 1-289, 24(IQR 13-41)

*keep if visitno==1
*(208,879 observations deleted)

codebook studyid
*N=16338


** ======================== **
**#eTable 2
** Patient characteristics


gen agecat=1*(age>=52&age<65)+2*(age>=65&age<74)+3*(age>=74)
label define Lage 0"25-56" 1"56-70" 2"70-79" 3"79-125",modify
label val agecat Lage

tabstat age if visitno==1,stat(min max n median p25 p75) by(agecat)
/*

agecat |       Min       Max         N       p50       p25       p75
-------+------------------------------------------------------------
 25-56 |        25        55      3330        45        38        51
 56-70 |        56        69      4211        64        60        67
 70-79 |        70        78      4513        74        72        76
79-125 |        79       125      4569        84        81        89
-------+------------------------------------------------------------
 Total |        25       125     16623        71        59        79
--------------------------------------------------------------------

*/




local z "entry_yr agecat female race_cat2 ethnic_cat lang_cat lang_help insurcat2_bl"
local z "`z' right_censored change_coverage relocate"

foreach y of local z{
	*tab `y',m
	*tab `y' right_censored,m
	*tab `y' right_censored, chi col
	
	tab `y' yr2017 if visitno==1,m
	tab `y' yr2017 if visitno==1, chi col nokey
}


tabstat age if visitno==1,stat(p50 p25 p75 min max mean sd n) by(yr2017) c(s)

median age if visitno==1,by(yr2017)


** ======================== **
**#eTable 2



tabstat ep_pci ep_pov ep_unemp ep_nohsdp ep_disabl ep_sngpnt ep_minrty ep_limeng pct_forborn pctnohealthins if visitno==1,stats(p50 p25 p75 mean sd min max n) c(s)


tabstat ep_munit ep_mobile ep_crowd ep_noveh pctnointernet pctnobroadband pctnocomputer if visitno==1,stat(p50 p25 p75 mean sd min max n) c(s)


tab nchs_urban if visitno==1













** ======================== **
**#eTable 3
** Access to care


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New/"

use "working_acs.dta",clear

codebook studyid
*N=16,338/n=222,972

*drop _merge


**# Cohort 4
** selecting patients who had been followed for at least 4 times and up to 2 years

** including whose entry year was 2017 (prevalent cases)
** and those entered since 2018 (incident cases)


sort studyid visitdate,stable
bys studyid: egen index_date=min(visitdate)
format index_date %td

gen censor_date=index_date+365*2
format censor_date %td

gen censor_visit=(visitdate>censor_date)
label var censor_visit "a censored visit?"
order censor_date censor_visit index_date,after(visitdate)

tab censor_visit yr2017,m
/*

a censored |    prevalent cases
    visit? |         0          1 |     Total
-----------+----------------------+----------
         0 |    63,035     48,862 |   111,897 
         1 |    34,021     77,054 |   111,075 
-----------+----------------------+----------
     Total |    97,056    125,916 |   222,972 


*/

codebook studyid
*N=16,623/n=225,502

codebook studyid if yr2017==1
*N=6,273/n=126,796

codebook studyid if yr2017==0
*N=10,350/n=98,706

drop if fu_end==0
*(1,649 observations deleted)

*sort studyid visitdate
*bys studyid: gen visitno=_n
*bys studyid: egen tlvisitno=max(visitno)



**# selection of cohort 4
** FU up to 2 yrs since the index visit
** encounters within 2 years since the index visit
** returned 2+ visits (total num visits 3+)

gen cohort=1 if censor_visit==0
bys studyid: egen for_LDA=min(cohort)

gen cohort4=(for_LDA==1) if for_LDA!=.

replace cohort4=. if tlvisitno<4
*(6477 real changes made, 6477 to missing)
replace cohort4=. if censor_visit==1
*(111,544 real changes made, 111,544 to missing)
*only consider the first 24 months since the index visit


codebook studyid if cohort4==1
*N=12,164/n=104,606

keep if cohort4==1
*(118,366 observations deleted)



**#recalculation for the first two years
drop fu_end visitno tlvisitno int_d ave_int fu_m


sort studyid visitdate
bys studyid: gen visitno=_n

bys studyid: egen tlvisitno=max(visitno)
label var tlvisitno "total # visits"

sort studyid visitdate
bys studyid: gen fu_m=(visitdate-visitdate[1])/30.5
label var fu_m "months since the index visit"


bys studyid: egen fu_end=max(fu_m)
label var fu_end "total FU time in months"

sort studyid visitdate
bys studyid: gen int_d=(visitdate-visitdate[_n-1])
label var int_d "days since the last visit"

bys studyid: egen ave_int=median(int_d)
label var ave_int "median interval between visits, days"

label var cohort4 "dry eye patients who have been followed 4+ times and up to 2 years"
label val cohort4 Lyesno

order visitdate visitno tlvisitno fu_m fu_end int_d,before(female)



tabstat tlvisitno fu_end ave_int if visitno==1,stat(p50 p25 p75 mean sd min max n) by(yr2017) c(s)

foreach y of var tlvisitno fu_end ave_int{
	median `y' if visitno==1,by(yr2017)
} 




** ======================= **
**# eTable 4      
** 
**# dry eye PROGRESSION
** 
** added meds
** changed meds
** added procedures
** any changes in meds or procedures

*keep studyid visitdate visitno entry_yr yr2017 ethnic_cat num_proc procedurename1 cptcode1 procedurename2 cptcode2 num_meds ded_meds1 ded_meds2 ded_meds3 ded_meds4 


foreach y of var num_proc num_ded_meds{
  replace `y'=0 if `y'==.
}

sort studyid visitdate,stable
bys studyid: gen _dt=visitdate-visitdate[1]
order _dt,after(visitdate)

sort studyid visitdate,stable
bys studyid: gen d_proc=num_proc-num_proc[_n-1]
order d_proc,before(num_proc)


gen d_proc_cat=2*(d_proc<0)+1*(d_proc>0) if d_proc!=.
label define Ldnum 0"no change" 2"decrease" 1"increase",modify
label val d_proc_cat Ldnum
label var d_proc_cat "any change in # from the previous visit"


replace d_proc_cat=. if d_proc==.
order d_proc_cat,after(num_proc)

sort studyid
bys studyid: egen ever_decrease=min(d_proc)
bys studyid: egen ever_increase=max(d_proc)
order ever_decrease ever_increase,after(d_proc_cat)



** NEW CPT at any time (time-varying)
label val ever_increase Lyesno
tab d_proc_cat ever_increase,m

replace ever_increase=0 if ever_increase<0
replace ever_increase=1 if ever_increase>0 & ever_increase!=.


tab d_proc_cat ever_increase if cohort4==1,m
tab d_proc_cat ever_increase
/*

any change |
 in # from |
       the |
  previous |          ever_increase
     visit |        no        yes          . |     Total
-----------+---------------------------------+----------
 no change |    91,045      2,038          0 |    93,083 
  increase |         0        219          0 |       219 
  decrease |        10        192          0 |       202 
         . |    11,620        172        536 |    12,328 
-----------+---------------------------------+----------
     Total |   102,675      2,621        536 |   105,832 

*/

codebook studyid if ever_increase==1
*n=172
codebook studyid 
*N=12328

tab ever_increase yr2017
/*

ever_incre |    prevalent cases
       ase |         0          1 |     Total
-----------+----------------------+----------
        no |    56,467     46,208 |   102,675 
       yes |     1,340      1,281 |     2,621 
-----------+----------------------+----------
     Total |    57,807     47,489 |   105,296 


*/

codebook studyid if ever_increase==1 & yr2017==1
*n=80
codebook studyid if yr2017==1
*N=5467

codebook studyid if ever_increase==1 & yr2017==0
*n=92
codebook studyid if yr2017==0
*N=6861



** NEW DED prescriptions at any time (time-varying)
sort studyid visitdate,stable
bys studyid: gen d_num_meds=num_ded_meds-num_ded_meds[_n-1]
label var d_num_meds "change in # from the previous visit"

replace d_num_meds=1 if d_num_meds==0 & (ded_meds1-ded_meds1[_n-1]!=0) & ded_meds1!=.
*(276 real changes made)

gen d_med_cat=1*(d_num_meds>0)+2*(d_num_meds<0) if d_num_meds!=.
label val d_med_cat Ldnum


tab d_med_cat yr2017,m
/*

           |    prevalent cases
 d_med_cat |         0          1 |     Total
-----------+----------------------+----------
 no change |    48,320     40,320 |    88,640 
  increase |     1,429        957 |     2,386 
  decrease |     1,500        978 |     2,478 
         . |     6,861      5,467 |    12,328 
-----------+----------------------+----------
     Total |    58,110     47,722 |   105,832 

*/


**# added prescriptions (time-varying)
codebook studyid if d_med_cat==1
*N=1783


codebook studyid if d_med_cat==1 & yr2017==1
*N=716

codebook studyid if d_med_cat==1 & yr2017==0
*N=1067



**# added or subtracted prescriptions (time-varying)
codebook studyid if d_med_cat!=0 & d_med_cat!=.
*N=2134


codebook studyid if d_med_cat!=0 & yr2017==1 & d_med_cat!=.
*N=830

codebook studyid if d_med_cat!=0 & yr2017==0 & d_med_cat!=.
*N=1304



** changed prescriptions or received procedures (time-varying)
gen any_progress=1 if (ever_increase==1)
label var any_progress "changed meds or received procedure any time"
label val any_progress Lyesno

replace any_progress=1 if d_med_cat!=0 & d_med_cat!=.
replace any_progress=0 if any_progress==.


codebook studyid if any_progress==1
*N=2146

codebook studyid if any_progress==1 & yr2017==1
*N=835

codebook studyid if any_progress==1 & yr2017==0
*N=1311


gen agecat=1*(age>=56&age<70)+2*(age>=70&age<79)+3*(age>=79)
label define Lage 0"25-56" 1"56-70" 2"70-79" 3"79-125",modify
label val agecat Lage


sort studyid visitdate,stable
save "working_acs_model_anyprogress.dta",replace







** added medication at 0-6m, 6-12m, 12-18m, 18-24m
gen tp=1*(_dt>0 & _dt<183)+2*(_dt>=183 & _dt<365)+3*(_dt>=365 & _dt<548)+4*(_dt>=548) 
label define Ltp 0"BL" 1"0-6m" 2"6-12m" 3"12-18m" 4"18m-24m",modify
label val tp Ltp

order tp,after(_dt)


** CPT
sort studyid visitdate
bys studyid: egen new_cpt6m=max(d_proc) if d_proc!=. & tp==1
label var new_cpt6m "new CPT 0-6m"
gen d_proc_cat6m=2*(new_cpt6m<0)+1*(new_cpt6m>0) if new_cpt6m!=.
label var d_proc_cat6m "change in # in 0-6m"
label val d_proc_cat6m Ldnum
order new_cpt6m d_proc_cat6m,after(d_proc)


sort studyid visitdate
bys studyid: egen new_cpt12m=max(d_proc) if d_proc!=. & tp==2
label var new_cpt12m "new CPT 6-12m"
gen d_proc_cat12m=2*(new_cpt12m<0)+1*(new_cpt12m>0) if new_cpt12m!=.
label var d_proc_cat12m "change in # in 6-12m"
label val d_proc_cat12m Ldnum
order new_cpt12m d_proc_cat12m,after(d_proc)

sort studyid visitdate
bys studyid: egen new_cpt18m=max(d_proc) if d_proc!=. & tp==3
label var new_cpt18m "new CPT 12-18m"
gen d_proc_cat18m=2*(new_cpt18m<0)+1*(new_cpt18m>0) if new_cpt18m!=.
label var d_proc_cat18m "change in # in 12-18m"
label val d_proc_cat18m Ldnum
order new_cpt18m d_proc_cat18m,after(d_proc)


sort studyid visitdate
bys studyid: egen new_cpt24m=max(d_proc) if d_proc!=. & tp==4
label var new_cpt24m "new CPT 18-24m"
gen d_proc_cat24m=2*(new_cpt24m<0)+1*(new_cpt24m>0) if new_cpt24m!=.
label var d_proc_cat24m "change in # in 18-24m"
label val d_proc_cat24m Ldnum
order new_cpt24m d_proc_cat24m,after(d_proc)


foreach y of var d_proc_cat6m d_proc_cat12m d_proc_cat18m d_proc_cat24m{
	/*numerators
	codebook studyid if `y'==1
	codebook studyid if `y'==1 & yr2017==1
	codebook studyid if `y'==1 & yr2017==0
	*/
	
	*denominators
	codebook studyid if `y'==!.
	codebook studyid if `y'==!. & yr2017==1
	codebook studyid if `y'==!. & yr2017==0
	*/
		
}


** Added prescriptions
sort studyid visitdate
bys studyid: egen add_meds6m=max(d_num_meds) if d_num_meds!=. & tp==1
label var add_meds6m "new meds 0-6m"
gen d_med_cat6m=1*(add_meds6m>0)+2*(add_meds6m<0) if add_meds6m!=.
label var d_med_cat6m "change in meds in 0-6m"
label val d_med_cat6m Ldnum
order add_meds6m d_med_cat6m,after(d_num_meds)


sort studyid visitdate
bys studyid: egen add_meds12m=max(d_num_meds) if d_num_meds!=. & tp==2
label var add_meds12m "new meds 6-12m"
gen d_med_cat12m=1*(add_meds12m>0)+2*(add_meds12m<0) if add_meds12m!=.
label var d_med_cat12m "change in meds in 6-12m"
label val d_med_cat12m Ldnum
order add_meds12m d_med_cat12m,after(d_num_meds)


sort studyid visitdate
bys studyid: egen add_meds18m=max(d_num_meds) if d_num_meds!=. & tp==3
label var add_meds18m "new meds 12-18m"
gen d_med_cat18m=1*(add_meds18m>0)+2*(add_meds18m<0) if add_meds18m!=.
label var d_med_cat18m "change in meds in 12-18m"
label val d_med_cat18m Ldnum
order add_meds18m d_med_cat18m,after(d_num_meds)


sort studyid visitdate
bys studyid: egen add_meds24m=max(d_num_meds) if d_num_meds!=. & tp==4
label var add_meds24m "new meds 18-24m"
gen d_med_cat24m=1*(add_meds24m>0)+2*(add_meds24m<0) if add_meds24m!=.
label var d_med_cat24m "change in meds in 18-24m"
label val d_med_cat24m Ldnum
order add_meds24m d_med_cat24m,after(d_num_meds)


foreach y of var d_med_cat6m d_med_cat12m d_med_cat18m d_med_cat24m{
	
	/*added meds
	codebook studyid if `y'==1
	codebook studyid if `y'==1 & yr2017==1
	codebook studyid if `y'==1 & yr2017==0
	*/
	
	**any changes in meds
	codebook studyid if `y'!=0 & `y'!=.
	codebook studyid if `y'!=0 & yr2017==1 & `y'!=.
	codebook studyid if `y'!=0 & yr2017==0 & `y'!=.
	*/
}



** changed prescriptions or received procedures
gen any_progress6m=1 if (d_proc_cat6m==1|d_med_cat6m!=0) & d_med_cat6m!=. & tp==1
label var any_progress6m "changed meds or received procedure 0-6m"
label val any_progress6m Lyesno
replace any_progress6m=0 if d_proc_cat6m!=.&any_progress6m==.

gen any_progress12m=1 if (d_proc_cat12m==1|d_med_cat12m!=0) & d_med_cat12m!=. & tp==2
label var any_progress12m "changed meds or received procedure 6-12m"
label val any_progress12m Lyesno
replace any_progress12m=0 if d_proc_cat12m!=.&any_progress12m==.

gen any_progress18m=1 if (d_proc_cat18m==1|d_med_cat18m!=0) & d_med_cat18m!=. & tp==3
label var any_progress18m "changed meds or received procedure 12-18m"
label val any_progress18m Lyesno
replace any_progress18m=0 if d_proc_cat18m!=.&any_progress18m==.

gen any_progress24m=1 if (d_proc_cat24m==1|d_med_cat24m!=0) & d_med_cat24m!=. & tp==4
label var any_progress24m "changed meds or received procedure 18-24m"
label val any_progress24m Lyesno
replace any_progress24m=0 if d_proc_cat24m!=.&any_progress24m==.


foreach y of var any_progress6m any_progress12m any_progress18m any_progress24m{
	
	codebook studyid if `y'==1
	codebook studyid if `y'==1 & yr2017==1
	codebook studyid if `y'==1 & yr2017==0
	*/

}

**# eTable 4_ACS

**any change in prescriptsions
prtesti 5467	0.1518		6861	0.1901
prtesti 4195	0.0801		5679	0.1145
prtesti 3543	0.0689		3968	0.0834
prtesti 3617	0.0658		3335	0.0840
prtesti 3136	0.0625		2655	0.0768
				
**added prescriptions				
prtesti 5467	0.1310		6861	0.1555
prtesti 4195	0.0706		5679	0.1053
prtesti 3543	0.0612		3968	0.0741
prtesti 3617	0.0600		3335	0.0717
prtesti 3136	0.0539		2655	0.0640


**new CPT				
prtesti 5467	0.0146		6861	0.0134
prtesti 4195	0.0050		5679	0.0074
prtesti 3543	0.0065		3968	0.0066
prtesti 3617	0.0058		3335	0.0087
prtesti 3136	0.0086		2655	0.0064


** any changes in prescriptions or CPT				
prtesti 5467	0.1573		6861	0.1943
prtesti 4195	0.0834		5679	0.1190
prtesti 3543	0.0737		3968	0.0885
prtesti 3617	0.0697		3335	0.0900
prtesti 3136	0.0695		2655	0.0802


prtesti 5428	0.1538	6736	0.1946
prtesti 4183	0.0813	5605	0.1172
prtesti 3539	0.0692	3929	0.0845
prtesti 3609	0.0659	3307	0.0856
prtesti 3129	0.0626	2633	0.0775




















**# eTable 1
**
** Cohort 4 participants characteristics
** compared to Cohort 3

gen agecat=1*(age>=56&age<70)+2*(age>=70&age<79)+3*(age>=79)
label define Lage 0"25-56" 1"56-70" 2"70-79" 3"79-125",modify
label val agecat Lage


tabstat age if visitno==1,stat(median p25 p75 min max n) by(agecat)
/*
  agecat |       p50       p25       p75       Min       Max         N
---------+------------------------------------------------------------
       0 |        45        37        50        25        55      6125
       1 |        64        60        67        56        69      7737
       2 |        74        72        76        70        78      9041
       3 |        84        81        89        79       125      9271
---------+------------------------------------------------------------
   Total |        72        60        80        25       125     32174
----------------------------------------------------------------------
*/

local z "entry_yr agecat female race_cat1 race_cat2 ethnic_cat lang_cat lang_help insurcat1_bl insurcat2_bl"
*local z "`z' right_censored change_coverage relocate"

foreach y of local z{
	*tab `y',m
	*tab `y' right_censored,m
	*tab `y' right_censored, chi col
	
	tab `y' yr2017 if visitno==1,m
	tab `y' yr2017 if visitno==1, chi col nokey
}


tabstat age,stat(p50 p25 p75 min max mean sd n) by(yr2017) c(s)

median age,by(yr2017)




**# eTable5
**
**


use "working_acs_model_anyprogress.dta",clear
sort studyid visitdate

/*
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New/Plots"

foreach y of local dich{
	histogram `y',by(any_progress)
	graph export "histo_`y'.tif",replace
	
}
*/


egen pcicat=cut(ep_pci), group(4)
tabstat ep_pci if visitno==1,stat(p50 p25 p75 mean sd min max n) by(pcicat)
bys any_progress: tabstat ep_pci if visitno==1,stat(p50 p25 p75 mean sd min max n) by(pcicat)

label define Lpci 0"4687-27754" 1"27767-37988" 2"38032-52609" 3"52756-137060",modify
label val pcicat Lpci

local gau "ep_unemp ep_disabl ep_sngpnt"
local gau "`gau' pctbroadband pctnobroadband"

local skew "`gau' ep_pov"
local skew "`skew'  pct_forborn" 
local skew "`skew'  pctnointernet pctnocomputer"
local skew "`skew' ep_noveh pctnohealthins"

local dich "`skew' ep_mobile ep_crowd ep_munit ep_limeng ep_minrty ep_nohsdp ep_pci "

foreach y of local dich{
	regress `y' any_progress,cluster(studyid)
}

tab nchs_urban any_progress,chi


**logistic regression: individual level

foreach y of var agecat female race_cat2 ethnic_cat lang_cat lang_help insurcat2_bl change_coverage  yr2017 relocate{ 

	logistic any_progress i.`y',cluster(studyid)

}



**logistic regression: ACS level

**# derived variables
for var ep_pov ep_unemp ep_nohsdp ep_disabl ep_sngpnt ep_minrty ep_limeng ep_munit ep_mobile ep_crowd ep_noveh pctnointernet pctnobroadband pctnocomputer pct_forborn pctnohealthins: gen X_10pct=X/10

gen ep_pci_k=ep_pci/1000
label var ep_pci_k "per capita income in thousands"


foreach y of var ep_pov ep_minrty ep_unemp ep_nohsdp ep_disabl ep_sngpnt ep_limeng ep_munit ep_mobile ep_crowd ep_noveh pctnointernet pctnobroadband pctnocomputer pct_forborn pctnohealthins{
	logistic any_progress `y'_10pct,cluster(studyid)
}

logistic any_progress i.pcicat,cluster(studyid)
logistic any_progress i.nchs_urban,cluster(studyid)

logistic any_progress ep_minrty_10pct,cluster(studyid)

logistic any_progress ep_pci_k,cluster(studyid)



** new variables for cohort4
gen race_cat3=race_cat2
recode race_cat3 1=0 3=0 2=1 4=2
label define Lrace3 0"white,1+ race or other,Asian/Indigent/PI" 1"Black" 2"Unknown",modify
label val race_cat3 Lrace3

gen insurcat3_bl=(insurcat2_bl==4) if insurcat2_bl!=.
label var insurcat3_bl "not Medicare,managed care,medicaid,self-pay"
label val insurcat3_bl Lyesno

gen lang_cat2=(lang_cat==2)
label var lang_cat2 "non-Eng,non-Span"
replace lang_cat2=. if lang_cat==3
label val lang_cat2 Lyesno

gen ethnic_cat2=(ethnic_cat==2)
label var ethnic_cat2 "Unknown ethnicity"
label val ethnic_cat2 Lyesno


** model m from the primary analysis
logistic any_progress i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate, cluster(studyid)





sw,pr(0.15) lockterm1:logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate) ep_pov_10pct ep_unemp_10pct ep_nohsdp_10pct ep_disabl_10pct ep_sngpnt_10pct ep_munit_10pct ep_mobile_10pct ep_crowd_10pct ep_noveh_10pct pctnointernet_10pct pctnobroadband_10pct pctnocomputer_10pct pct_forborn_10pct pctnohealthins_10pct ep_pci_k ep_minrty_10pct urban, cluster(studyid) 
est store p

sw,pe(0.15) lockterm1:logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate) ep_pov_10pct ep_unemp_10pct ep_nohsdp_10pct ep_disabl_10pct ep_sngpnt_10pct ep_munit_10pct ep_mobile_10pct ep_crowd_10pct ep_noveh_10pct pctnointernet_10pct pctnobroadband_10pct pctnocomputer_10pct pct_forborn_10pct pctnohealthins_10pct ep_pci_k ep_minrty_10pct urban, cluster(studyid)
est store P

sw,pr(0.2) lockterm1:logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate) ep_pov_10pct ep_unemp_10pct ep_nohsdp_10pct ep_disabl_10pct ep_sngpnt_10pct ep_munit_10pct ep_mobile_10pct ep_crowd_10pct ep_noveh_10pct pctnointernet_10pct pctnobroadband_10pct pctnocomputer_10pct pct_forborn_10pct pctnohealthins_10pct ep_minrty_10pct i.pcicat i.nchs_urban, cluster(studyid)
est store q

sw,pe(0.2) lockterm1:logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate) ep_pov_10pct ep_unemp_10pct ep_nohsdp_10pct ep_disabl_10pct ep_sngpnt_10pct ep_munit_10pct ep_mobile_10pct ep_crowd_10pct ep_noveh_10pct pctnointernet_10pct pctnobroadband_10pct pctnocomputer_10pct pct_forborn_10pct pctnohealthins_10pct ep_minrty_10pct i.pcicat i.nchs_urban, cluster(studyid)
est store Q



logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) pctnointernet_10pct ep_minrty_10pct i.nchs_urban, cluster(studyid)
est store y


logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) pctnointernet_10pct ep_minrty_10pct, cluster(studyid)
est store z

logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) pctnointernet_10pct ep_minrty_10pct i.nchs_urban, cluster(studyid)
est store w

logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) ep_unemp_10pct ep_crowd_10pct ep_minrty_10pct ep_pci_k pctnointernet_10pct,vce(robust)
est store v

logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) ep_unemp_10pct ep_crowd_10pct ep_minrty_10pct ep_pci_k pctnointernet_10pct i.nchs_urban,vce(robust)
est store p


logistic any_progress (i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate) ep_unemp_10pct ep_crowd_10pct ep_minrty_10pct ep_pci_k pctnointernet_10pct i.urban,cluster(studyid)
est store d


est stats * 
0.959

**# new variable
gen non_urban=(nchs_urban>=4)
label var urban "small metro, micropolitan, noncore?"
label val urban Lyesno

** choosing model d based on lowest BIC and LR test

logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate),cluster(studyid)
est store n

logistic any_progress (i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate) ep_pci_k ep_minrty_10pct pct_forborn_10pct pctnocomputer_10pct non_urban,cluster(studyid)
est store m

