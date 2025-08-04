************************************************************************
** file name: aim1.do
** date created: 06/27/2025
** date modified: 06/30/2025
**			      07/04/2025
**				  07/05/2025	
**				  07/06/2025
**				  07/07/2025
**				  07/08/2025
**				  07/14/2025
**				  07/15/2025
**
**
**
**
** Individual tables: T0_tvT1.dta, T1.dta, T2.dta
**					  T3_cohort3.dta, T5_cohort.dta, T7_cohort3.dta
**                    T8.dta, T18.dta
**					  T16_acs.dta
**
**
**
** Merged tables: working_T210BL.dta
**				  working_cohort3.dta (T357)
**                working_T818.dta
**
**
** For analysis: working_cohort3 + individual baseline SDOH
**				 
**
**
**


cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"
use "working_cohort3.dta",clear


codebook studyid
*N=46264/n=220268 (Cohort 3)
*N=64509/n=538503
*N=105040/n=805164 (Cohort 2: all eligible eye patients to RMLEI)

sort studyid visitdate
merge m:m studyid visitdate using "working_T210BL.dta"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                       739,611
        from master                    64,173  (_merge==1)
        from using                    675,438  (_merge==2)

    Matched                           156,113  (_merge==3)
    -----------------------------------------

	    Result                      Number of obs
    -----------------------------------------
    Not matched                       925,707
        from master                   316,329  (_merge==1)
        from using                    609,378  (_merge==2)

    Matched                           222,173  (_merge==3)
    -----------------------------------------

*/

drop _merge


sort studyid visitdate
merge m:1 studyid using "cohort3 list.dta",update
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                       275,190
        from master                   275,190  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           620,534
        not updated                   188,995  (_merge==3)
        missing updated               430,320  (_merge==4)
        nonmissing conflict             1,219  (_merge==5)
    -----------------------------------------

    Result                      Number of obs
    -----------------------------------------
    Not matched                       341,002
        from master                   341,002  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           806,879
        not updated                   449,775  (_merge==3)
        missing updated               357,104  (_merge==4)
        nonmissing conflict                 0  (_merge==5)
    -----------------------------------------

	
*/

drop _merge

drop if visitdate==.
*(32876 observations deleted)

codebook studyid 
*N=99400/n=1115005

sort studyid visitdate,stable
bys studyid: egen c3=min(cohort3)

tab c3 cohort3,m
/*
           |     dryeye cohort (primary)
        c3 |         0          1          . |     Total
-----------+---------------------------------+----------
         0 |    88,728          0     95,101 |   183,829 
         1 |         0    806,512          0 |   806,512 
         . |         0          0    124,664 |   124,664 
-----------+---------------------------------+----------
     Total |    88,728    806,512    219,765 | 1,115,005 

*/

replace cohort3=0 if cohort3==.&c3==0
*(95,101 real changes made)

drop c3

codebook studyid if cohort3==1
*N=45329/n=806512


** re-assign cohort membership
sort studyid visitdate
order cohort*,after(studyid)
order cohort1,before(cohort2)

sort studyid visitdate
bys studyid: egen cohort1_new=min(cohort1)

sort studyid visitdate
bys studyid: egen cohort2_new=min(cohort2)

order cohort1_new,after(cohort1)
order cohort2_new,after(cohort2)

drop cohort1 cohort2
rename cohort1_new cohort1
rename cohort2_new cohort2

sort studyid visitdate,stable
bys studyid: egen c3=max(cohort3)

compare c3 cohort3



tab cohort2 cohort3,m
/*
           |     dryeye cohort (primary)
   cohort2 |         0          1          . |     Total
-----------+---------------------------------+----------
         1 |   182,592    805,425    124,664 | 1,112,681 
         . |     1,237      1,087          0 |     2,324 
-----------+---------------------------------+----------
     Total |   183,829    806,512    124,664 | 1,115,005 

	 
*/

replace cohort3=0 if cohort3==.

drop if dob==.
*(316,330 observations deleted)


codebook studyid if cohort3==1
*N=44962/n=549454

drop if age<18
*(10 observations deleted)


codebook studyid if cohort3==1
*N=44962/n=549449

codebook studyid if cohort2==1
*N=98550/n=798665

drop c3 *merge* 





sort studyid visitdate
save "working.dta",replace








** ================== **
** Table 1            **
**					  **	
** Index visit only   **  
** ================== **

cd "Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"
use "working.dta",clear




**# for Table 1
** ================================

*keep if cohort3==1
*(248,803 observations deleted)
*(275,190 observations deleted)
*(242,683 observations deleted)
*(513,979 observations deleted)

*drop visitno
**# variable derivation
**  ______________________ **

sort studyid visitdate,stable
bys studyid: gen visitno=_n
*range 1-327
*median 11 (IQR 4-25)

sort studyid visitdate
bys studyid: gen fu_m=(visitdate-visitdate[1])/30.5
label var fu_m "months since baseline"

bys studyid: egen fu_end=max(fu_m)
label var fu_end "total FU time in months"

sort studyid visitdate
bys studyid: gen int_d=(visitdate-visitdate[_n-1])
label var int_d "days between visits"

bys studyid: egen ave_int=median(int_d)
label var ave_int "median interval between visits,days"

order visitdate visitno fu_m fu_end int_d ave_int,before(female)

sort studyid visitdate
bys studyid: gen visit_yr=year(visitdate)
bys studyid: egen entry_yr=min(visit_yr)
order visit_yr entry_yr,after(visitdate)

gen yr2017=(entry_yr==2017)
label var yr2017 "prevalent cases"
*/


tabstat fu_end int_d ave_int if visitno==1,stat(p50 p25 p75 min max mean sd n) c(s)
/*

    Variable |       p50       p25       p75       Min       Max      Mean        SD         N
-------------+--------------------------------------------------------------------------------
        fu_m |         0         0         0         0         0         0         0     45895
      fu_end |  21.86885  3.672131  57.86885         0  95.67213   32.2087  31.06522     45895
       int_d |         .         .         .         .         .         .         .         0
     ave_int |      40.5        22      88.5         1      2846  97.61544  187.0928     40527
----------------------------------------------------------------------------------------------

*/

codebook studyid if fu_end==0
*N=5510 persons without FU visits

codebook studyid if fu_end>0
*N=39819 persons with 1+ FU visits

*codebook studyid if fu_end>4
*N=34,584 persons with FU duration > 4 months

*codebook studyid if fu_end>4 & ave_int<=13 
*N=33,178 persons with FU duration > 4 months & median interval btn visits <=12 months
*n=697,051


codebook studyid
*N=45,895/n=555,992
*N=45,329/n=601,333

codebook studyid if fu_end==0
*N=5,510 persons without FU visits (12.15%)

codebook studyid if fu_end>0
*N=39,819 persons with 1+ FU visits (87.84%)



codebook studyid
*N=98,550/n=798,665 (cohort2)

codebook studyid if cohort3==1
*N=44,962/n=549,449


**# additional dry eye patients 
*BEFORE Table 1
** ================================
*other dz ICD
*other symptoms ICD
*other CPT

foreach y of var total_ot total_symp total_CPTot{
	codebook studyid if cohort3==0 & `y'>0 & `y'!=.
}

*N=44962 for cohort3

*N=9,184 other ICD (20.43% of cohort3) 44962
*N=5,348 symptoms ICD (11.89% of cohort3)
*N=2,029  other CPT (4.51% of cohort3)


**# Table 1
** ================================
keep if cohort3==1
*(249,216 observations deleted)

*drop visitno

sort studyid visitdate,stable
bys studyid: gen visitno=_n


keep if visitno==1
*(504,487 observations deleted)

codebook studyid
*N=44962



****************************************
**# NEEDS UPDATE ***********************
****************************************


codebook studyid
*N=44962



egen agecat=cut(age),group(4)
tabstat age,stat(min max n median p25 p75) by(agecat)
/*

  agecat |       Min       Max         N       p50       p25       p75
---------+------------------------------------------------------------
       0 |        18        51     11145        40        32        46
       1 |        52        64     10573        59        56        62
       2 |        65        73     11753        69        67        71
       3 |        74       125     11491        79        76        84
---------+------------------------------------------------------------
   Total |        18       125     44962        65        52        74
----------------------------------------------------------------------

*/

*gen agecat=1*(age>=50&age<64)+2*(age>=64&age<73)+3*(age>=73)
label define Lage 0"18-52" 1"52-65" 2"65-74" 3"74+",modify
label val agecat Lage



local z "right_censored entry_yr agecat female race_cat1 race_cat2 ethnic_cat lang_cat lang_help insurcat1_bl insurcat2_bl"
*local z "`z' right_censored change_coverage relocate"

foreach y of local z{
	*tab `y',m
	*tab `y' right_censored,m
	*tab `y' right_censored, chi col
	
	tab `y' yr2017,m
	tab `y' yr2017, chi col nokey
}


tabstat age,stat(p50 p25 p75 min max mean sd n) by(yr2017) c(s)
median age,by(yr2017)





** =================== **
**# Tables 2 & 3       **
** 
** ACCESS to care
** PROGRESSION
** =================== **
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"

use "working.dta",clear

codebook studyid
*N=98,550/n=798,665 (Cohort2)

keep if cohort3==1
*(249,216 observations deleted)

codebook studyid
*N=44,962/n=549,449 (Cohort3)




**# Cohort 4
** selecting patients who had been followed for at least 4 times and up to 2 years

** including whose entry year was 2017 (prevalent cases)
** and those entered since 2018 (incident cases)

sort studyid visitdate
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
         0 |   203,291    102,023 |   305,314 
         1 |    89,628    154,507 |   244,135 
-----------+----------------------+----------
     Total |   292,919    256,530 |   549,449 

*/

codebook studyid
*N=44,962/n=549,449 (Cohort3)

codebook studyid if yr2017==1
*N=12817

codebook studyid if yr2017==0
*N=32,145

drop if fu_end==0
*(5,163 observations deleted)



sort studyid visitdate,stable
bys studyid: gen visitno=_n
bys studyid: egen tlvisitno=max(visitno)

order visitdate visitno tlvisitno index_date censor_date censor_visit visit_yr entry_yr fu_m fu_end int_d ave_int,after(studyid)


**# selection of cohort 4
** FU up to 2 yrs since the index visit
** encounters within 2 years since the index visit
** returned 2+ visits (total num visits 3+)

gen cohort=1 if censor_visit==0
bys studyid: egen for_LDA=min(cohort)

gen cohort4=(for_LDA==1) if for_LDA!=.

replace cohort4=. if tlvisitno<4
*(19705 real changes made, 19705 to missing)
replace cohort4=. if censor_visit==1
*(242,702 real changes made, 242,702 to missing)
*only consider the first 24 months since the index visit


codebook studyid if cohort4==1
*N=31,731/n=281,879

keep if cohort4==1
*(262,407 observations deleted)



**#recalculation for the first two years
drop fu_end visitno tlvisitno int_d ave_int fu_m


sort studyid visitdate,stable
bys studyid: gen visitno=_n

bys studyid: egen tlvisitno=max(visitno)
label var tlvisitno "total # visits"

sort studyid visitdate,stable
bys studyid: gen fu_m=(visitdate-visitdate[1])/30.5
label var fu_m "months since the index visit"


bys studyid: egen fu_end=max(fu_m)
label var fu_end "total FU time in months"

sort studyid visitdate,stable
bys studyid: gen int_d=(visitdate-visitdate[_n-1])
label var int_d "days since the last visit"

bys studyid: egen ave_int=median(int_d)
label var ave_int "median interval between visits, days"

label var cohort4 "dry eye patients who have been followed 4+ times and up to 2 years"
label val cohort4 Lyesno

order visitdate visitno tlvisitno fu_m fu_end int_d,before(female)


sort studyid visitdate,stable

save "cohort4 list.dta",replace


tabstat fu_end ave_int if visitno==1,stat(p50 p25 p75 min max n) by(cohort3) c(s)

/*
Summary for variables: fu_end ave_int
Group variable: cohort3 (dryeye cohort (primary))

 cohort3 |       p50       p25       p75       Min       Max         N
---------+------------------------------------------------------------
       0 |         6  1.901639  19.90164  .0327869  95.34426     36740 additionally identifiable dry eye patients
         |        35      17.5        84         1      2846     36740
---------+------------------------------------------------------------
       1 |  28.81967  8.163935  63.37705  .0327869  95.67213     39799
         |        40        22      87.5         1      2715     39799
---------+------------------------------------------------------------
   Total |  13.54098  3.377049  44.52459  .0327869  95.67213     76539
         |        38        21        86         1      2846     76539
----------------------------------------------------------------------
*/





/*
**# Bookmark #1
** ELIGIBLE PATIENT LIST

keep studyid visitdate visitno tlvisitno cohort2 cohort3 cohort4 right_censored change_coverage relocate yr2017
sort studyid visitdate

codebook studyid 

save "cohort list_long.dta",replace

keep if visitno==1
*(252,682 observations deleted)

keep studyid
*N=32174

sort studyid cohort4

save "cohort4 list.dta",replace
*/



** ============ **
**# table 2
** Access to care

tabstat tlvisitno fu_end ave_int if visitno==1,stat(p50 p25 p75 mean sd min max n) by(yr2017) c(s)

tab entry_yr if visitno==1

tab right_censored yr2017 if visitno==1,m

foreach y of var tlvisitno fu_end ave_int{
	median `y' if visitno==1,by(yr2017)
} 



** ======================= **
**# Table 3      
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

sort studyid visitdate
bys studyid: gen _dt=visitdate-visitdate[1]
order _dt,after(visitdate)

sort studyid visitdate
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



** NEW CPT at any time
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
 no change |   248,918      1,045          0 |   249,963 
  increase |         0         89          0 |        89 
  decrease |        13         83          0 |        96 
         . |    30,477         83      1,171 |    31,731 
-----------+---------------------------------+----------
     Total |   279,408      1,300      1,171 |   281,879 


*/

codebook studyid if ever_increase==1
*n=83
codebook studyid 
*N=31731

tab ever_increase yr2017
/*

ever_incre |    prevalent cases
       ase |         0          1 |     Total
-----------+----------------------+----------
        no |   179,762     96,877 |   276,639 
       yes |     4,882      2,150 |     7,032 
-----------+----------------------+----------
     Total |   184,644     99,027 |   283,671 

ever_incre |    prevalent cases
       ase |         0          1 |     Total
-----------+----------------------+----------
        no |   181,226     98,182 |   279,408 
       yes |     1,028        272 |     1,300 
-----------+----------------------+----------
     Total |   182,254     98,454 |   280,708 
	 
*/

codebook studyid if ever_increase==1 & yr2017==1
*n=18
codebook studyid if yr2017==1
*N=11045

codebook studyid if ever_increase==1 & yr2017==0
*n=65
codebook studyid if yr2017==0
*N=20686



** NEW DED prescriptions at any time
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
 no change |   152,750     83,935 |   236,685 
  increase |     4,569      1,939 |     6,508 
  decrease |     4,955      2,000 |     6,955 
         . |    20,686     11,045 |    31,731 
-----------+----------------------+----------
     Total |   182,960     98,919 |   281,879 

*/


**# added prescriptions (time-varying)
codebook studyid if d_med_cat==1
*N=4891


codebook studyid if d_med_cat==1 & yr2017==1
*N=1436

codebook studyid if d_med_cat==1 & yr2017==0
*N=3455



**# added or subtracted prescriptions (time-varying)
codebook studyid if d_med_cat!=0 & d_med_cat!=.
*N=5952


codebook studyid if d_med_cat!=0 & yr2017==1 & d_med_cat!=.
*N=1684

codebook studyid if d_med_cat!=0 & yr2017==0 & d_med_cat!=.
*N=4268



** changed prescriptions or received procedures (time-varying)
gen any_progress=1 if (ever_increase==1)
label var any_progress "changed meds or received procedure any time"
label val any_progress Lyesno

replace any_progress=1 if d_med_cat!=0 & d_med_cat!=.
replace any_progress=0 if any_progress==.


codebook studyid if any_progress==1
*N=6006

codebook studyid if any_progress==1 & yr2017==1
*N=1698

codebook studyid if any_progress==1 & yr2017==0
*N=4380

gen agecat=1*(age>=52&age<65)+2*(age>=65&age<74)+3*(age>=74)
label define Lage 0"18-52" 1"52-65" 2"65-74" 3"74+",modify
label val agecat Lage


sort studyid visitdate
save "working_model_anyprogress.dta",replace





**# for fixed time points within 2 years

** added medication at 0-6m, 6-12m, 12-18m, 18-24m
gen tp=1*(_dt>0 & _dt<183)+2*(_dt>=183 & _dt<365)+3*(_dt>=365 & _dt<548)+4*(_dt>=548) 
label define Ltp 0"BL" 1"0-6m" 2"6-12m" 3"12-18m" 4"18m-24m",modify
label val tp Ltp

order tp,after(_dt)


** CPT
sort studyid visitdate,stable
bys studyid: egen new_cpt6m=max(d_proc) if d_proc!=. & tp==1
label var new_cpt6m "new CPT 0-6m"
gen d_proc_cat6m=2*(new_cpt6m<0)+1*(new_cpt6m>0) if new_cpt6m!=.
label var d_proc_cat6m "change in # in 0-6m"
label val d_proc_cat6m Ldnum
order new_cpt6m d_proc_cat6m,after(d_proc)


sort studyid visitdate,stable
bys studyid: egen new_cpt12m=max(d_proc) if d_proc!=. & tp==2
label var new_cpt12m "new CPT 6-12m"
gen d_proc_cat12m=2*(new_cpt12m<0)+1*(new_cpt12m>0) if new_cpt12m!=.
label var d_proc_cat12m "change in # in 6-12m"
label val d_proc_cat12m Ldnum
order new_cpt12m d_proc_cat12m,after(d_proc)

sort studyid visitdate,stable
bys studyid: egen new_cpt18m=max(d_proc) if d_proc!=. & tp==3
label var new_cpt18m "new CPT 12-18m"
gen d_proc_cat18m=2*(new_cpt18m<0)+1*(new_cpt18m>0) if new_cpt18m!=.
label var d_proc_cat18m "change in # in 12-18m"
label val d_proc_cat18m Ldnum
order new_cpt18m d_proc_cat18m,after(d_proc)


sort studyid visitdate,stable
bys studyid: egen new_cpt24m=max(d_proc) if d_proc!=. & tp==4
label var new_cpt24m "new CPT 18-24m"
gen d_proc_cat24m=2*(new_cpt24m<0)+1*(new_cpt24m>0) if new_cpt24m!=.
label var d_proc_cat24m "change in # in 18-24m"
label val d_proc_cat24m Ldnum
order new_cpt24m d_proc_cat24m,after(d_proc)


foreach y of var d_proc_cat6m d_proc_cat12m d_proc_cat18m d_proc_cat24m{
	*numerators
	codebook studyid if `y'==1
	codebook studyid if `y'==1 & yr2017==1
	codebook studyid if `y'==1 & yr2017==0
	*/
	
	/*denominators
	codebook studyid if `y'==!.
	codebook studyid if `y'==!. & yr2017==1
	codebook studyid if `y'==!. & yr2017==0
	*/
		
}


** Added prescriptions
sort studyid visitdate,stable
bys studyid: egen add_meds6m=max(d_num_meds) if d_num_meds!=. & tp==1
label var add_meds6m "new meds 0-6m"
gen d_med_cat6m=1*(add_meds6m>0)+2*(add_meds6m<0) if add_meds6m!=.
label var d_med_cat6m "change in meds in 0-6m"
label val d_med_cat6m Ldnum
order add_meds6m d_med_cat6m,after(d_num_meds)


sort studyid visitdate,stable
bys studyid: egen add_meds12m=max(d_num_meds) if d_num_meds!=. & tp==2
label var add_meds12m "new meds 6-12m"
gen d_med_cat12m=1*(add_meds12m>0)+2*(add_meds12m<0) if add_meds12m!=.
label var d_med_cat12m "change in meds in 6-12m"
label val d_med_cat12m Ldnum
order add_meds12m d_med_cat12m,after(d_num_meds)


sort studyid visitdate,stable
bys studyid: egen add_meds18m=max(d_num_meds) if d_num_meds!=. & tp==3
label var add_meds18m "new meds 12-18m"
gen d_med_cat18m=1*(add_meds18m>0)+2*(add_meds18m<0) if add_meds18m!=.
label var d_med_cat18m "change in meds in 12-18m"
label val d_med_cat18m Ldnum
order add_meds18m d_med_cat18m,after(d_num_meds)


sort studyid visitdate,stable
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
	
	*any changes in meds
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

/*
keep studyid tp entry_yr yr2017 ethnic_cat ever_increase d_proc_cat6m new_cpt6m d_proc_cat12m new_cpt12m d_proc_cat18m new_cpt18m d_proc_cat24m new_cpt24m d_med_cat add_meds6m add_meds12m add_meds18m add_meds24m d_med_cat6m d_med_cat12m d_med_cat18m d_med_cat24m any_progress any_progress6m any_progress12m any_progress18m any_progress24m

sort studyid tp

set seed 20152359
sort studyid tp,stable
bys studyid tp: gen seqno=_n
order seqno, after(tp)
keep if seqno==1
drop seqno

order d_proc_cat6m d_proc_cat12m d_proc_cat18m d_proc_cat24m new_cpt6m new_cpt12m new_cpt18m new_cpt24m d_med_cat6m d_med_cat12m d_med_cat18m d_med_cat24m add_meds6m add_meds12m add_meds18m add_meds24m,after(ethnic_cat)
order ever_increase,after(d_med_cat)
order tp,after(studyid)


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

sort studyid tp
save "working_outcomes_simple.dta",replace

*/


**# eTable 1
**
** Cohort 4 participants characteristics
** compared to Cohort 3


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



**#prtesti

**change in meds
prtesti 11045	0.1525		20686	0.2063
prtesti 8590	0.0795		17730	0.1153
prtesti 7205	0.0715		12465	0.0866
prtesti 7283	0.0654		10092	0.0856
prtesti 6255	0.0646		7912	0.0856
				
**added meds				
prtesti 11045	0.1300		20686	0.1670
prtesti 8590	0.0709		17730	0.1068
prtesti 7205	0.0615		12465	0.0766
prtesti 7283	0.0573		10092	0.0741
prtesti 6255	0.0545		7912	0.0731
			
**added CPT			
prtesti 11045	0.0016		20686	0.0031
prtesti 8590	0.0013		17730	0.0024
prtesti 7205	0.0003		12465	0.0010
prtesti 7283	0.0005		10092	0.0006
prtesti 6255	0.0002		7912	0.0008
			
**any changes in meds or CPT			
prtesti 11045	0.1537		20686	0.2117
prtesti 8590	0.0807		17730	0.1171
prtesti 7205	0.0715		12465	0.0866
prtesti 7283	0.0654		10092	0.0856
prtesti 6255	0.0646		7912	0.0856








**# Table 3
** univariable regression on PROGRESS
** "any_progress (time-varying)"

cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"

use "working_model_anyprogress.dta",clear

codebook studyid
*N=31731/n=281879


local k "agecat yr2017 female race_cat2 ethnic_cat lang_cat lang_help insurcat2_bl change_coverage"

foreach y of local k{ 
	
	logistic any_progress i.`y',cluster(studyid)
	
	/*
	foreach z of local k{
		bys `z': logistic any_progress i.`y',cluster(studyid)
	}
	*/
}


logistic any_progress relocate,cluster(studyid)




**#stratified#1

** nocons

*yr2017: NS
*female: NS
*race_cat x relocate: female, language
*ethnic_cat x relocate: non-Hispanic and unknown grp
*language: NS
*need interpreter: NS
*insurcat2_bl: NS
*changed coverage: NS
**# relocate: collinear with insurcat2_bl, relocat x ethnic_cat, relocate x race_cat2


**#stratified#2

*agecat: yr2017, female,race_cat2,primary language,insurcat2_bl
*yr2017: race_cat2,ethnic_cat2,need interpreter,insurcat2_bl,
*female: 
*race_cat: 
*ethnic_cat: 
*primary language: 
*need interpreter: 
*insurcat2_bl: 
*changed coverage: 
**relocate: 




**Multivariable regression on PROGRESS
sw, pe(0.25): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl i.change_coverage yr2017 relocate, cluster(studyid)
est store a
sw, pe(0.2): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store b
sw, pe(0.15): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store c
**a has the lowest AIC/BIC

sw, pr(0.25): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl i.change_coverage yr2017 relocate, cluster(studyid)
est store A
sw, pr(0.2): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store B
sw, pr(0.15): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store C

est stats *



sw, pe(0.25): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store e
sw, pr(0.25): logistic any_progress i.agecat female i.race_cat2 i.ethnic_cat i.lang_cat i.lang_help i.insurcat2_bl yr2017, cluster(studyid)
est store f

est stats *



** new variables
gen race_cat3=race_cat2
recode race_cat3 1=0 3=0 2=1 4=2
label define Lrace3 0"white,1+ race or other,Asian/Indigent/PI" 1"Black" 2"Unknown",modify
label val race_cat3 Lrace3

gen black=(race_cat3==1)
label var black Lyesno


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



logistic any_progress i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 i.race_cat3 i.lang_cat2 change_coverage relocate,cluster(studyid)
est store m

logistic any_progress i.agecat female yr2017 i.insurcat3_bl i.ethnic_cat2 black i.lang_cat2 change_coverage relocate,cluster(studyid)
est store k

* choosing m as the final model based on AIC/BIC/LR test 

logistic any_progress i.agecat female yr2017 i.insurcat2_bl i.ethnic_cat i.race_cat2 i.lang_cat change_coverage relocate,cluster(studyid)
est store p












use "cohort4 list.dta",clear

sort studyid visitdate,stable
keep if visitno==1
*(250,148 observations deleted)

codebook studyid
*N=31731

save,replace


**# Table2 
** Lab tests: Dry eye signs

cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

use "working_T818.dta",clear

codebook studyid
*N=92,789/n=536,930


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"

sort studyid visitdate,stable
merge m:1 studyid using "cohort4 list.dta"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                       185,021
        from master                   184,948  (_merge==1)
        from using                         73  (_merge==2)

    Matched                           351,982  (_merge==3)
    -----------------------------------------


    Result                      Number of obs
    -----------------------------------------
    Not matched                       458,003
        from master                   356,527  (_merge==1)
        from using                    101,476  (_merge==2)

    Matched                           180,403  (_merge==3)
    -----------------------------------------
	
*/

rename _merge merge

tab merge cohort4,m
/*
                      | dry eye patients who
                      | have been followed 4+
                      |   times and up to 2
 Matching result from |         years
                merge |       yes          . |     Total
----------------------+----------------------+----------
      Master only (1) |         0    184,948 |   184,948 
       Using only (2) |        73          0 |        73 
          Matched (3) |   351,982          0 |   351,982 
----------------------+----------------------+----------
                Total |   352,055    184,948 |   537,003 
 


*/


sort studyid visitdate
merge m:1 study using "T0_BL.dta"
/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                         7,308
        from master                       269  (_merge==1)
        from using                      7,039  (_merge==2)

    Matched                           536,734  (_merge==3)
    -----------------------------------------



*/


drop _merge

sort studyid visitdate
merge m:1 study using "T1.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        31,526
        from master                         0  (_merge==1)
        from using                     31,526  (_merge==2)

    Matched                           544,042  (_merge==3)
    -----------------------------------------
*/

drop _merge

*sort studyid visitdate,stable
*bys studyid: egen member=max(cohort4)

drop if visitdate>censor_date
*(156,309 observations deleted)

*drop if cohort4==.
*(223,513 observations deleted)



codebook studyid
*N=32,103/n=355,855
*N=31,572/n=195746
*N=131,268/n=419259


/*
sort studyid visitdate
bys studyid: egen index_visit=min(visitdate)
gen entry_yr=year(index_visit)
format index_visit %td
gen yr2017=(entry_yr==2017)
*/


/* 
gen osmo=(tear_osmo!=.)
label var osmo "presence of tear osmolarity results this visit"
label val osmo Lyesno

gen labcounts=csf + conj + schirmer + tbut + osmo
label var labcounts "# lab results available this visit"
*/


tab labcounts yr2017,m
/*

 num. test |
   results |    prevalent cases
this visit |         0          1 |     Total
-----------+----------------------+----------
         1 |     2,929        924 |     3,853 
         2 |   120,439     65,838 |   186,277 
         3 |     3,242      1,406 |     4,648 
         4 |       744        102 |       846 
         5 |        15          8 |        23 
         . |        74         25 |        99 
-----------+----------------------+----------
     Total |   127,443     68,303 |   195,746 





drop if labcounts==.
*(99 observations deleted)

codebook studyid 
*N=31,499/n=195647


/*
tab labcounts yr2017,m


 num. test |
   results |    prevalent cases
this visit |         0          1 |     Total
-----------+----------------------+----------
         1 |     4,021      2,349 |     6,370 
         2 |   174,789    161,211 |   336,000 
         3 |     4,729      3,354 |     8,083 
         4 |     1,101        363 |     1,464 
         5 |        19         11 |        30 
-----------+----------------------+----------
     Total |   184,659    167,288 |   351,947 

*/

/*
sort studyid visitdate
bys studyid: gen visit_yr=year(visitdate)
bys studyid: egen entry_yr=min(visit_yr)
order visit_yr entry_yr,after(visitdate)

gen yr2017=(entry_yr==2017)
label var yr2017 "prevalent cases"

bys studyid: egen tlvisitno=max(visitno)
label var tlvisitno "total # visits"

*/
*/

sort studyid visitdate,stable
bys studyid: gen _dt=(visitdate-visitdate[1])

gen tp=1*(_dt>0 & _dt<183)+2*(_dt>=183 & _dt<365)+3*(_dt>=365 & _dt<548)+4*(_dt>=548) 
label define Ltp 0"BL" 1"0-6m" 2"6-12m" 3"12-18m" 4"18m-24m",modify
label val tp Ltp

order tp,after(_dt)
*/


**# table2 - symptoms/signs

local test "csf conj tbut osmo schirmer"


* numerators (patients receiving the test) by year
foreach y of var csf {
	tab tp yr2017 if `y'==1,m
	forval z=1/4{
		codebook studyid if `y'==1 & tp==`z'
		codebook studyid if `y'==1 & tp==`z'&yr2017==1
		codebook studyid if `y'==1 & tp==`z'&yr2017==0
	}
	
}

** additionally possible dry eye patients
foreach y of var csf {
	tab tp yr2017 if `y'==1&cohort3==0,m
	forval z=1/4{
		codebook studyid if `y'==1 & tp==`z'&cohort3==0
		codebook studyid if `y'==1 & tp==`z'&yr2017==1&cohort3==0
		codebook studyid if `y'==1 & tp==`z'&yr2017==0&cohort3==0
	}
	
}


* denominators by year
forval z=0/4{
		codebook studyid if tp==`z'
		codebook studyid if tp==`z'&yr2017==1
		codebook studyid if tp==`z'&yr2017==0
	}

*BL
prtesti 10878 0.9966 21225 0.9948
prtesti 10878 0.9968 21225 0.9951
prtesti 10878 0.0205 21225 0.0226
prtesti 10878 0      21225 0.0091
prtesti 10878 0.0002 21225 0.0048

prtesti 10969	0.9965	20530	0.9942
prtesti 10969	0.9966	20530	0.9951
prtesti 10969	0.0206	20530	0.0228
prtesti 10969	0.0001	20530	0.0092
prtesti 10969	0.0002	20530	0.0049

*0-6m
prtesti 6809 0.9974 15556 0.9969
prtesti 6809 0.9975 15556 0.9970
prtesti 6809 0.0388 15556 0.0471
prtesti 6809 0.0012	15556 0.0345
prtesti 6809 0.0013 15556 0.0167

prtesti 6848	0.9972	15113	0.9963
prtesti 6848	0.9974	15113	0.9970
prtesti 6848	0.0388	15113	0.0479
prtesti 6848	0.0015	15113	0.0349
prtesti 6848	0.0013	15113	0.0169

*6-12m
prtesti 6354 0.9991 10774 0.9972
prtesti 6354 0.9992 10774 0.9995
prtesti 6354 0.0342 10774 0.0408
prtesti 6354 0.0072	10774 0.0192
prtesti 6354 0.0017 10774 0.0091

prtesti 6360	0.9983	10461	0.9961
prtesti 6360	0.9992	10461	0.9995
prtesti 6360	0.0343	10461	0.0415
prtesti 6360	0.0074	10461	0.0192
prtesti 6360	0.0017	10461	0.0091

*12-18m
prtesti 6685 0.9983 8990 0.9979
prtesti 6685 0.9994 8990 0.9996
prtesti 6685 0.0302 8990 0.0335
prtesti 6685 0.0177	8990 0.0157
prtesti 6685 0.0015 8990 0.0073

prtesti 6631	0.9985	8672	0.9976
prtesti 6631	0.9991	8672	0.9995
prtesti 6631	0.0303	8672	0.0342
prtesti 6631	0.0176	8672	0.0160
prtesti 6631	0.0015	8672	0.0075

*18-24m
prtesti 9685 0.9998 12463 0.9994
prtesti 9685 0.9998 12463 0.9998
prtesti 9685 0.0754 12463 0.0654
prtesti 9685 0.0503	12463 0.0363
prtesti 9685 0.0223 12463 0.0235

prtesti 5288	0.9989	6534	0.9971
prtesti 5288	0.9994	6534	0.9994
prtesti 5288	0.0244	6534	0.0320
prtesti 5288	0.0165	6534	0.0150
prtesti 5288	0.0004	6534	0.0096

**# NEEDS UPDATE
**# poisson regression
** need to calculate "person-years" or "person-months"

local "csf conj tbut osmo schirmer"


forval z=0/4{
	foreach y of var conj {
	
		logistic `y' yr2017 if tp==`z',cluster(studyid)
	}
}





