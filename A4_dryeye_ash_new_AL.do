*******************************************************************************
**file name:dryeye_ash_new_AL.do
**date created: 06/22/2025
**date modified: 06/30/2025
**				 07/02/2025
**				 07/14/2025
**				 07/15/2025
**				 07/28/2025
**
**
**
** NOTE#1: original file: dryeye_ash_new.do
** 
** NOTE#2:
** "C3827_T0_TempTable_20250228.csv" original file from HDC
** "T0_TempTable_20250205.csv"       copy, renamed for easy coding
**
** NOTE#3:
** "T1_Person_20250205.csv"          original file from HDC  
** "T1_Person_20250224.csv"			 after removing 9 patients from VA who had only
**                                   billing codes but no individual SDOH	
** NOTE#4:
** "T8_Labs_20250205.csv"			 check for "tear osmolarity" "anti-SSA"/"anti-SSB" IgG
**
**


** Table 2 
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T2_Encounter_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 4
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T4_Proc_OrderedEMR_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 6
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T6_Surgeries_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 9
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T9_ADT_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 12
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T12_FamilyHistory_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 13
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T13_SocialHistory_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 14
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T14_Allergy_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 15
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T15_Referral_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
** Table 17
cd "C:\Users\ashly\The University of Colorado Denver\Liu, Alison - 2025-01-07"
import delimited "T17_CensusData2014_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe

** Table 16
cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"
import delimited "T16_CensusData2018_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe

gen studyid=arb_person_id
order studyid, before(arb_person_id)
destring arb_person_id, replace

codebook studyid

cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T16_Census.dta", replace

** ------------- **
** Table 0 - All
** ------------- **


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-07-09"

*cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

*cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

*import delimited "C3827_T0_TempTable_20250228.csv", varnames(1) asdouble stringcols(1 2) clear
*import delimited "T0_TempTable_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
*describe



import delimited "C3175_T19_LongFormOfTable2_20250718.csv", varnames(1) asdouble stringcols(1 2) clear


label define Lyesno 0"no" 1"yes",modify


codebook arb_person_id
*N=99,677/n=1,344,996
*N=99669/n=1344943


gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

gen date_extraction = substr(encounterdate, 1, 10)
gen visitdate=date(date_extraction,"YMD")
label var visitdate "date of visit"
format visitdate %td


gsort studyid visitdate arb_encounter_id
bys studyid visitdate: gen seqno=_n
*seqno from 1 to 16

*duplicates tag studyid visitdate, gen(dup_ind)
*dup_ind ranged from 0 to 15

list arb_person_id encounterdate arb_encounter_id deceasedyn seqno if seqno==1 & deceasedyn=="Y",sepby(arb_person_id)


**remove multiple encounter records on the same date
**usually due to differences in payor classes
keep if seqno==1
*(292,555 observations deleted)
drop seqno

codebook studyid
*N=99,677
*n=1,052,435
*N=99,669
*n=1,052,388



*** ----------------------------------------------- ****
*** time-varying variables: death,insurance,zipcode ****
*** ----------------------------------------------- ****

gsort studyid visitdate arb_encounter_id
bys studyid: gen visitno=_n

**change in mortality**
**-------------------**
codebook studyid if deceasedyn == "Y" & cdphe_dod == "" & dateofdeathemr == ""
*N=3
*3 patients died but no recorded "date of death"

codebook studyid if deceasedyn == "Y"
*N=8562
codebook studyid if cdphe_dod != "" | dateofdeathemr != ""
*N=8559


/*
*Make a new variable that identfies the date of death 
sort studyid
by studyid: egen deceasedyn_flag = max(deceasedyn == "Y")
by studyid: replace deceasedyn = "Y" if deceasedyn_flag == 1
drop deceasedyn_flag

gen dod_temp = ""
replace dod_temp = cdphe_dod if cdphe_dod !=""
replace dod_temp = dateofdeathemr if dateofdeathemr !="" & dod_temp == ""

gen dod_clean = trim(dod_temp)
*tab dod_clean
*tab cdphe_dod
*drop dod_normalized first_two_chars are_first_two_numeric 
* Step 2: Normalize the date by adding leading zeros for single-digit months or days
gen dod_normalized = dod_clean

* Add leading zero to month if needed
gen first_two_chars = substr(dod_clean, 1, 2)
*tab first_two_chars
gen are_first_two_numeric = !missing(real(first_two_chars))

* Step 3: Add a leading zero if the first two characters are not numeric
replace dod_normalized = "0" + dod_clean if !are_first_two_numeric

*tab dod_normalized 
* Add leading zero to day if needed
*drop first_five_chars num_numeric_chars
gen first_five_chars = substr(dod_normalized, 1, 5)
*tab first_five_chars
gen num_numeric_chars = 0
forval i = 1/5 {
    replace num_numeric_chars = num_numeric_chars + (real(substr(first_five_chars, `i', 1)) != .)
}
*tab num_numeric_chars
replace dod_normalized = substr(dod_normalized, 1, 3) + "0" + substr(dod_normalized, 4, .) if num_numeric_chars == 3

replace dod_normalized = substr(dod_normalized, 1, 6) + "20" + substr(dod_normalized, 7, .) if dod_normalized != "0"

replace dod_normalized = "" if dod_normalized == "0"
*tab dod_normalized 

*drop string_length
gen string_length = length(dod_normalized) if 
tab string_length,m

codebook studyid if dod_normalized != ""
*6,638

* Step 3: Convert the normalized date string to a Stata numeric date (MDY format)
gen dod_num = date(dod_normalized, "MDY")
format dod_num %td

sort studyid
by studyid: egen dod = max(dod_num)
drop dod_num dod_normalized dod_temp dod_clean

codebook studyid if dod != .
*6,638 
codebook studyid if dod == .
*63,958 

codebook studyid if deceasedyn == "Y"
*6,639
codebook studyid if deceasedyn == "N"
*63,957 
codebook studyid

codebook studyid if deceasedyn == "Y" & dod == .
*1
*/



gen censored=(deceasedyn=="Y")
label var censored "censored visit"
label val censored Lyesno

bys arb_person_id: egen right_censored=max(censored)
label var right_censored "censored person"
label val right_censored Lyesno

*right_censored N=8104/n=89,913

gen dod_str=cdphe_dod if censored==1
replace dod_str=dateofdeathemr if censored==1 & dod==""

gen dod=date(dod_str,"YMD") if dod_str!=""
format dod %td
label var dod "date of death"
*N=8559
*3 patients had no recorded "date of death"




bys studyid: gen fu_d=visitdate-visitdate[1]
label var fu_d "FU time(d)"

gen fu_m=fu_d/30.5
label var fu_m "FU time(m)"

gen fu_yr=fu_m/12
label var fu_yr "FU time(y)"

tabstat fu_m, stat(median p25 p75 p90 p95 mean sd max) c(s) by(right_censored)	
/*
right_censored |       p50       p25       p75       p90       p95      Mean        SD       Max
---------------+--------------------------------------------------------------------------------
            no |  13.08197  2.360656  39.01639   64.9836  76.65574  23.43108   25.2801  95.67213
           yes |  11.73771  2.491803   30.7541  51.14754  62.98361   19.2899  20.69001   95.2459
---------------+--------------------------------------------------------------------------------
         Total |  12.91803  2.360656  38.09836  63.86885  75.77049  23.04648  24.91849  95.67213
------------------------------------------------------------------------------------------------
*/
/*
list arb_person_id encounterdate arb_encounter_id deceasedyn ///
censored right_censored seqdate if right_censored==1 & ///
arb_person_id=="996772331",sepby(arb_person_id)
*/



**change in insurance**
**-------------------**
gen insurcat=0*(payorfinancialclass=="Medicare")+ ///
			 3*(payorfinancialclass=="Colorado Medicaid"| ///
				payorfinancialclass=="Out of State Medicaid")+ ///
			 1*(payorfinancialclass=="Managed Medicaid"| ///
				payorfinancialclass=="Managed Care"| ///
				payorfinancialclass=="Managed Medicare"| ///
				payorfinancialclass=="Commercial")+ ///
			 5*(payorfinancialclass=="Worker's Comp"| ///
				payorfinancialclass=="Tricare"| ///
				payorfinancialclass=="Indigent Care"| ///
				payorfinancialclass=="Special Accounts")+ ///
			 4*(payorfinancialclass=="UCHEALTH EMPLOYEE PLAN"| ///
				payorfinancialclass=="CU - UA NET")+ ///
			 2*(payorfinancialclass=="Self-Pay") if payorfinancialclass!=""

label define Linsurcat 0"Medicare" 3"Medicaid" 1"Managed care" 5"Others" 4"CU-UC EP" 2"Self-pay",modify
label val insurcat Linsurcat


sort studyid visitno
bys studyid: gen d_insur=insurcat-insurcat[_n-1]
gen change_insur=(d_insur!=0) if d_insur!=.
label var change_insur "changed insur from prior visit"
label val change_insur Lyesno

sort studyid visitno
bys studyid: egen change_coverage=max(change_insur) 
label var change_coverage "changed insur person"
label val change_coverage Lyesno

gen insurcat2=insurcat
replace insurcat2=4 if insurcat>=4 & insurcat!=.

label define Linsurcat2 0"Medicare" 1"Manaaged care" 2"Self-Pay" 3"Medicaid" 4"Others",modify
label val insurcat2 Linsurcat2




/*
sort studyid visitno
bys studyid: gen d2_insur=insurcat-insurcat[_n-2]
gen change2_insur=(d2_insur!=0) if d2_insur!=.
label var change2_insur "changed insur from 2 visits prior"
label val change2_insur Lyesno
*/



**change in zipcode
*missing N=46/n=178
*missing & right_censored N=2/n=17

encode zipcode, gen(zipcode_new)
gsort studyid visitno
bys studyid: gen d_zip= zipcode_new-zipcode_new[_n-1]

gen change_zipcode=(d_zip!=0) if zipcode!="" & d_zip!=.
label var change_zipcode "changed zipcode visit"
label val change_zipcode Lyesno


sort studyid visitno
bys studyid: egen relocate=max(change_zipcode)
label var relocate "changed zipcode person"
label val relocate Lyesno

*changed zipcode N=58/n=94
*changed zipcode & died N=3/n=6

*drop date_extraction d_insur d2_insur change2_insur d_zip

keep studyid visitdate visitno dod censored right_censored insurcat ///
change_insur change_coverage zipcode change_zipcode relocate


codebook studyid
*N=99,669/n=1,052,388



sort studyid visitdate

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
save "T0_tvT1.dta",replace


/*
preserve
keep studyid visitdate deceasedyn insurcat dod zipcode 
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T0_all_observations.dta", replace
restore

preserve
duplicates drop studyid arb_encounter_id, force 
keep studyid arb_encounter_id visitdate deceasedyn insurcat dod zipcode 
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T0_encounter_id.dta", replace
restore

preserve
duplicates drop studyid visitdate, force 
keep studyid arb_encounter_id visitdate deceasedyn insurcat dod zipcode 
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T0_visitdate.dta", replace
restore



sort studyid visitdate
bys studyid: gen visitno=_n
keep if visitno == 1

codebook studyid 
*70,596 
** number of observations is 70,596

keep studyid deceasedyn insurcat dod zipcode

cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T0_one_observation.dta", replace
*/













** ------------- **
** Table 1 - All
** ------------- ** 
cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"

cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"


import delimited "C3175_T1_Person_20250718.csv", varnames(1) asdouble stringcols(1 2) clear
*import delimited "T1_Person_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_Id
birthdate       str10   %10s                  BirthDate
name            str51   %51s                  Name
sex             str12   %12s                  Sex
race            str42   %42s                  Race
ethnicity       str41   %41s                  Ethnicity
primarylanguage str35   %35s                  PrimaryLanguage
needinterpreter str1    %9s                   NeedInterpreter
payorfinancia~s str22   %22s                  PayorFinancialClass
zipcode         str10   %10s                  ZipCode
deceasedyn      str1    %9s                   DeceasedYN
cdphe_dod       str10   %10s                  CDPHE_DOD
dateofdeathemr  str10   %10s                  DateOfDeathEMR
causeofdeath    strL    %9s                   CauseOfDeath
cohort1         byte    %8.0g                 Cohort1
cohort2         byte    %8.0g                 Cohort2
*/


label define Lyesno 0"no" 1"yes",modify


codebook arb_person_id
*N=131,420

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

codebook studyid
*N=131,420


rename cohort_1_or_2
label define Lcohort 1"only in Cohort1" 2"Cohort2",modify
label val cohort Lcohort
label var cohort "cohort membership"


**#missing data 
*N=1 birthdate
*N=2711 race
*N=22904 payorfinancialclass
*N=398 zipcode
*--------------*
* cohort2
*N=1 birthdate
*N=1544 race
*N=15915 payorfinancialclass
*N=197 zipcode


codebook studyid sex race ethnicity if birthdate==""
*"15226362087" "Male" missing/unspecified "race" or "ethnicity"

drop if birthdate==""
*(1 observation deleted)

codebook studyid
*N=131,427/n=154,520


duplicates tag studyid, gen(dup_id)
label var dup_id "duplicate ID in T1"


tab cohort dup_id,m
/*

           |  duplicate ID in T1
   Cohort2 |        no        yes |     Total
-----------+----------------------+----------
         1 |    81,947     23,093 |   105,040 some persons met Cohort2 criteria in some years
         . |    26,387     23,093 |    49,480 but not in the other years
-----------+----------------------+----------
     Total |   108,334     46,186 |   154,520

	 
*/

/*	 
sort studyid dup_id
bys studyid: egen grp2=min(cohort2)
drop if cohort2==. & grp2==1
*(23,093 observations deleted)

drop dup_id grp2
replace cohort2=0 if cohort2==.
label var cohort2 "dry eye cohort (primary)"
label val cohort2 Lyesno
*/

drop dup_id



codebook studyid
*N=131,420
*N=105031 cohort2
*N=26389  cohort1 only


 


/*
duplicates report studyid,tag(dup_id)
duplicates report studyid birthdate sex race ethnicity primarylanguage needinterpreter payorfinancialclass zipcode deceasedyn cdphe_dod causeofdeath dateofdeathemr
*cohort1 & cohort2

duplicates drop studyid, force
*/

gen female=1*(sex=="Female")+2*(sex=="Male")
recode female 0=2 2=0
label define Lsex 0"male" 1"female" 2"Unknown",modify
label val female Lsex



gen dob= date(birthdate, "MDY",1999)
*(4 missing values generated)
replace dob=date(birthdate,"YMD",1899) if dob==.
replace dob=date(birthdate,"MDY",2000) if dob==.
label var dob "date of birth"
format dob %td

/*
tab studyid if dob == . 
list if studyid == "15226362087" 
*/

gen birthyr=year(dob)
label var birthyr "year of birth"

*derive a continuting age that calculates age based off of the year (time-varrying variables)
*We are no longer doing a stagnent age calculation now doing a dynamic one based on visitdates
/*
gen date1="2024-12-31"
gen doa=date(date1,"20YMD")
label var doa "date of analysis(fixed)"
format doa %td

gen age=round((doa-dob)/365.25)
label var age "age in yrs"
preserve
keep if deceasedyn == "N"
codebook studyid if age>=18 & age<40
codebook studyid if age>=40 & age<60
codebook studyid if age>=60 & age<80
codebook studyid if age>=80
keep if age>=18 
egen median_age = median(age)
egen q1_age = pctile(age), p(25)
egen q3_age = pctile(age), p(75)
display median_age " (" q1_age " to " q3_age ")"
restore
*/

* \New - 20250205 Variable Categories for Insurance
/*
gen insurcat2=1*(payorfinancialclass=="Colorado Medicaid"| ///
				payorfinancialclass=="Managed Medicaid"| ///
				payorfinancialclass=="Out of State Medicaid")+ ///
			 2*(payorfinancialclass=="CU - UA NET"| ///
				payorfinancialclass=="Worker's Comp"| ///
				payorfinancialclass=="Managed Care" | ///
				payorfinancialclass=="UCHEALTH EMPLOYEE PLAN" | ///
				payorfinancialclass=="Commercial" | ///
				payorfinancialclass=="Tricare") if payorfinancialclass!=""
*/










* \New - 20250516 Variable Categories for Race
tab race
/*
gen race_cat=1*(race=="Black or African American")+ ///
			 2*(race=="American Indian or Alaska Native"| ///
				race=="Native Hawaiian and Other Pacific Islander"| ///
				race=="Other Pacific Islander" | ///
				race=="Patient Declined" | ///
				race=="More Than One Race" | ///
				race=="Korean"| ///
				race=="Other Asian" | ///
				race=="Asian Indian" | ///
				race=="Other")
*/

gen race_cat1=2*(race=="Black or African American")+ ///
			 3*(race=="Asian Indian"| ///
				race=="Chinese"| ///
				race=="Filipino"| ///
				race=="Guamanian or Chamorro"| ///
				race=="Japanese"| ///
				race=="Korean"| ///
				race=="Vietnamese"| ///
				race=="Other Asian")+ ///
			5*(race=="American Indian or Alaska Native"| ///
				race=="Native Hawaiian"| ///
			  	race=="Native Hawaiian and Other Pacific Islander"| ///
				race=="Other Pacific Islander"| ///
				race=="Samoan")+ ///
			4*(race=="Patient Declined"| ///
				race=="Unknown"| ///
				race=="")+ ///
			1*(race=="More Than One Race"| ///
				race=="Other")

label define Lrace1 0"White" ///
				   1"1+ race| ot" ///
				   2"Black" ///
				   3"Asian" ///
				   4"Unknown" ///
				   5"Indigent| Islander" ,modify
label val race_cat1 Lrace1


gen race_cat2=race_cat1
replace race_cat2=3 if race_cat2==5

label define Lrace2 0"White" ///
				   1"1+ race| ot" ///
				   2"Black" ///
				   3"Asian| Indigent| Islander" ///
				   4"Unknown",modify
label val race_cat2 Lrace2







* \New - 20250205 Variable Categories for Ethnicity
tab ethnicity
gen ethnic_cat=1*(ethnicity=="Hispanic, Latino/a, or Spanish Origin")+ ///
			   2*(ethnicity=="Patient Unable to Answer"| ///
				  ethnicity=="*Unspecified"| ///
				  ethnicity=="Unknown")
					
label define Lethnic 0"Non-Hisp" ///
					 1"Hisp" ///
					 2"Unknown",modify
label val ethnic_cat Lethnic





* Primary Language Categories - In progress
tab primarylanguage
gen lang_cat=1*(primarylanguage=="Spanish")+ ///
			 2*(primarylanguage=="English")+ ///
			 3*(primarylanguage=="*Unspecified"| ///
				primarylanguage=="Unknown") 

recode lang_cat 2=0 0=2				
				
label define Llang 0"English" ///
					   1"Spanish" ///
					   2"Other" ///
					   3"Unknown",modify
label val lang_cat Llang

gen lang_help=(needinterpreter=="Y")
label var lang_help "needed interpreter"
label val lang_help Lyesno


tab lang_cat lang_help,m
/*
           |  needed interpreter
  lang_cat |        no        yes |     Total
-----------+----------------------+----------
   English |   118,312         16 |   118,328 
   Spanish |       900      5,275 |     6,175 
     Other |       947      3,760 |     4,707 
   Unknown |     2,216          1 |     2,217 
-----------+----------------------+----------
     Total |   122,375      9,052 |   131,427
*/




/*
gen dod_temp = ""
replace dod_temp = cdphe_dod if cdphe_dod != ""
replace dod_temp = dateofdeathemr if dateofdeathemr != "" & dod_temp == ""
gen dod= date(dod_temp, "YMD")
label var dod "date of death"
format dod %td

codebook studyid if dod !=.
codebook studyid if dod ==.

codebook studyid if cdphe_dod != "" | dateofdeathemr != ""
tab deceasedyn if dod !=.
tab deceasedyn if dod == .

replace deceasedyn = "Y" if dod !=.

gen zipcode_new =regexs(1) if regexm(zipcode, "([0-9][0-9][0-9][0-9][0-9])\-([0-9][0-9][0-9][0-9])")
replace zipcode=zipcode_new if zipcode_new !=""
drop zipcode_new
*/


keep studyid cohort dob birthyr female race_cat2 lang_cat lang_help
sort studyid

*cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"

cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"
save "T1.dta", replace
*export delimited using "T1_person.csv", replace




** ------------- **
** Combining Tables 0 & 1
** ------------- ** 
*cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"

cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

use "T1.dta",clear
sort studyid

merge 1:m studyid using "T0_time-varyT1.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        31,750
        from master                    31,750  (_merge==1)
        from using                          0  (_merge==2)

    Matched                         1,052,435  (_merge==3)
    -----------------------------------------

*/

sort studyid visitdate
order visitdate visitno fu_m zipcode change_zipcode relocate insurcat change_insur change_coverage censored right_censored dod,after(lang_help) 

tab cohort2 _merge,m
/*
   dry eye | Matching result from
    cohort |         merge
 (primary) | Master on  Matched ( |     Total
-----------+----------------------+----------
        no |    26,387          0 |    26,387 
       yes |     5,363  1,052,435 | 1,057,798 N=105,040
-----------+----------------------+----------
     Total |    31,750  1,052,435 | 1,084,185 
						N=99,677
*/

drop if _merge==1
*(31,750 observations deleted)

codebook studyid
*N=99,677/n=1,052,435


sort studyid visitdate
save "working_T01.dta",replace




** ------------- **
** Combining Tables 0 & 2
** ------------- ** 
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

import delimited "T2_Encounter_20250205.csv", varnames(1) asdouble stringcols(1 2) clear


gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

gen str_date = substr(date, 1, 10)
gen visitdate=date(str_date,"YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate date,after(arb_person_id)
drop str_date 


codebook arb_person_id
*N=99,677/n=1,352,062

tab encountertype

/*
      EncounterType |      Freq.     Percent        Cum.
--------------------+-----------------------------------
Ancillary Procedure |         67        0.00        0.00
         Anesthesia |        975        0.07        0.08
   Anesthesia Event |        975        0.07        0.15
        Appointment |    469,571       34.73       34.88
   Clinical Support |          2        0.00       34.88
         Evaluation |     35,985        2.66       37.54
 Hospital Encounter |          1        0.00       37.54
      Initial Visit |    108,620        8.03       45.57
       Nurse Triage |    180,903       13.38       58.95
       Office Visit |    427,469       31.62       90.57
    Patient Message |    113,549        8.40       98.97
          Treatment |     13,945        1.03      100.00
--------------------+-----------------------------------
              Total |  1,352,062      100.00
*/

** remove duplicates encountertypes that were not physicians' encounter
sort studyid visitdate
drop if encountertype=="Anesthesia"|encountertype=="Anesthesia Event"|encountertype=="Patient Message"
*(115,499 observations deleted)

codebook studyid
*N=99,477/n=1,236,563

drop if encountertype=="Nurse Triage"
*>99% "Self-Pay"
*(180,903 observations deleted)


codebook studyid
*N=98,880/n=1,055,660


** remove providernames
drop if regexm(lower(providername), "diagnostic")
*(125,214 observations deleted)

drop if regexm(lower(providername), "resident")
*(4,252 observations deleted)

drop if regexm(lower(providername), "eye")
*(19,592 observations deleted)

codebook studyid
*N=98,551/n=906,602





** remove duplicates insurancepayorclass
sort studyid visitdate arb_encounter_id
duplicates tag studyid visitdate,gen(dupind)

tab dupind
/*
     dupind |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    632,292       59.90       59.90
          1 |    264,326       25.04       84.93
          2 |    119,226       11.29       96.23
          3 |     27,436        2.60       98.83
          4 |      6,450        0.61       99.44
          5 |      3,906        0.37       99.81
          6 |      1,064        0.10       99.91
          7 |        616        0.06       99.97
          8 |        189        0.02       99.99
          9 |        110        0.01      100.00
         10 |         33        0.00      100.00
         11 |         12        0.00      100.00
------------+-----------------------------------
      Total |  1,055,660      100.00
*/

gen insurcat=0*(payorfinancialclass=="Medicare")+ ///
			 3*(payorfinancialclass=="Colorado Medicaid"| ///
				payorfinancialclass=="Out of State Medicaid")+ ///
			 1*(payorfinancialclass=="Managed Medicaid"| ///
				payorfinancialclass=="Managed Care"| ///
				payorfinancialclass=="Managed Medicare"| ///
				payorfinancialclass=="Commercial")+ ///
			 5*(payorfinancialclass=="Worker's Comp"| ///
				payorfinancialclass=="Tricare"| ///
				payorfinancialclass=="Indigent Care"| ///
				payorfinancialclass=="Special Accounts")+ ///
			 4*(payorfinancialclass=="UCHEALTH EMPLOYEE PLAN"| ///
				payorfinancialclass=="CU - UA NET")+ ///
			 2*(payorfinancialclass=="Self-Pay") if payorfinancialclass!=""

label define Linsurcat 0"Medicare" 3"Medicaid" 1"Managed care" 5"Others" 4"CU-UC EP" 2"Self-pay",modify
label val insurcat Linsurcat


gen insurcat2=insurcat
replace insurcat2=4 if insurcat>=4 & insurcat!=.

label define Linsurcat2 0"Medicare" 1"Managed care" 2"Self-Pay" 3"Medicaid" 4"Others",modify
label val insurcat2 Linsurcat2


* for individuals with duplicate records, majority shifted payor class to "self-pay"
codebook studyid
*N=98551/n=906602

codebook studyid if dupind==0
*N=91989 (93.34%)/n=700402 (77.26%)



sort studyid visitdate arb_encounter_id
bys studyid visitdate: gen seqno=_n

tab seqno dupind
/*
           |                                         dupind
     seqno |         0          1          2          3          4          5          6          7 |     Total
-----------+----------------------------------------------------------------------------------------+----------
         1 |   700,402     90,180      6,761      1,147        146         35          3          1 |   798,675 
         2 |         0     90,180      6,761      1,147        146         35          3          1 |    98,273 
         3 |         0          0      6,761      1,147        146         35          3          1 |     8,093 
         4 |         0          0          0      1,147        146         35          3          1 |     1,332 
         5 |         0          0          0          0        146         35          3          1 |       185 
         6 |         0          0          0          0          0         35          3          1 |        39 
         7 |         0          0          0          0          0          0          3          1 |         4 
         8 |         0          0          0          0          0          0          0          1 |         1 
-----------+----------------------------------------------------------------------------------------+----------
     Total |   700,402    180,360     20,283      4,588        730        210         21          8 |   906,602 
*/

codebook studyid
*N=98,551/n=906,602

keep if seqno==1
*(107,927 observations deleted)

codebook studyid
*N=98,551/n=798,675



/*
sort studyid visitno
bys studyid: gen d_insur=insurcat-insurcat[_n-1]
gen change_insur=(d_insur!=0) if d_insur!=.
label var change_insur "changed insur from prior visit"
label val change_insur Lyesno

sort studyid visitno
bys studyid: egen change_coverage=max(change_insur) 
label var change_coverage "changed insur person"
label val change_coverage Lyesno
*/


sort studyid visitdate

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
save "T2.dta",replace


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
use "working_T01.dta",clear

rename _merge merge_T10

sort studyid visitdate
merge m:m studyid visitdate using "T2.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       285,510
        from master                   285,510  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           798,675  (_merge==3)
    -----------------------------------------

*/

rename _merge merge_T102

drop if merge_T102==1
*(285,510 observations deleted)


codebook studyid
*N=98,551/n=798,675



sort studyid visitdate
save "working_T102.dta",replace


** ======================== **
** merge with T8_tear_osmo  **
**            T18_small     **


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
use "working_T102.dta",clear


codebook studyid
*N=98551/n=798675

sort studyid visitdate
merge m:m studyid visitdate using T8_tear_osmo.dta
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       796,124
        from master                   796,112  (_merge==1)
        from using                         12  (_merge==2)

    Matched                             2,563  (_merge==3

    -----------------------------------------


*/

rename _merge merge_T8

drop osmo1 osmo2 nomissing

codebook studyid
*N=98551/n=798687


sort studyid visitdate
merge m:m studyid visitdate using "T18_small.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       351,292
        from master                   306,544  (_merge==1)
        from using                     44,748  (_merge==2)

    Matched                           492,143  (_merge==3)
    -----------------------------------------
*/

rename _merge merge_T818

codebook studyid
*N=98961/n=843435

sort studyid visitdate
save "working_T102818.dta",replace






** ------------- **
** Table 3
** ------------- ** 
** Table 3: ICD codes
** create separate SMALLER tables based on "billing", "encoutner", "problem list"

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

import delimited "T3_Diagnosis_20250205.csv", varnames(1) asdouble stringcols(1 2) clear

*describe
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_ID
arb_encounter~d str12   %12s                  Arb_Encounter_Id
diagnosiscode~e str9    %9s                   DiagnosisCodeType
diagnosiscode   str8    %9s                   DiagnosisCode
diagnosisdesc~n strL    %9s                   DiagnosisDescription
encounterdate   str10   %10s                  EncounterDate
problemonsetd~e str10   %10s                  ProblemOnsetDate
problemresolu~e str10   %10s                  ProblemResolutonDate
provenance      str19   %19s                  Provenance
*/

*missings report
/*
  +----------------------------------+
  |                        # missing |
  |----------------------------------|
  |     problemonsetdate    19357914 |
  | problemresolutondate    19828838 |
  +----------------------------------+
*/

label define Lyesno 0"no" 1"yes",modify

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

/*
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
merge m:1 studyid using t1_person.dta
keep if _merge == 3
drop _merge 
*/

codebook studyid 
*N=104,788/n=20,060,966


** derived labels or variables 
encode provenance,gen(source_icd)



tab source_icd
/*
         Provenance |      Freq.     Percent        Cum.
--------------------+-----------------------------------
  Billing Diagnosis |  9,907,999       49.80       49.80
Encounter Diagnosis |  9,449,915       47.50       97.30
       Problem List |    536,645        2.70      100.00
--------------------+-----------------------------------
              Total | 19,894,559      100.00


gen sessionid=arb_encounter_id
order sessionid, before(arb_encounter_id)
*destring arb_encounter_id, replace
*/


gen visitdate=date(encounterdate,"YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate encounterdate,after(arb_person_id)

gen visityr=year(visitdate)
label var visityr "year of visit"




tab visityr, m
/*
    year of |
      visit |      Freq.     Percent        Cum.
------------+-----------------------------------
       2017 |  1,779,075        8.94        8.94
       2018 |  2,049,122       10.30       19.24
       2019 |  2,093,078       10.52       29.76
       2020 |  2,044,315       10.28       40.04
       2021 |  2,518,697       12.66       52.70
       2022 |  2,779,240       13.97       66.67
       2023 |  3,161,816       15.89       82.56
       2024 |  3,469,216       17.44      100.00
------------+-----------------------------------
      Total | 19,894,559      100.00
*/

sort arb_person_id encounterdate source_icd diagnosiscode
bys arb_person_id encounterdate source_icd: gen noicd=_n
bys arb_person_id encounterdate source_icd: egen maxnoicd=max(noicd)
label var noicd "no. ICD codes per category"
label var maxnoicd "max no. ICD codes per category"

bys source_icd: summ maxnoicd, de

/*
** --- Problem list codes--- **
keep if source_icd==3
*(2,695,989 observations deleted)

**off campus
cd "/Volumes/dept/SOM/OPH/OPH/DERegTL/Cohort2"

**on campus
cd "/Volumes/DERegTL/Cohort2"

export delimited using "T3_icd_problem.csv", replace


** --- Encounter codes--- **
keep if source_icd==2
*(1,455,057 observations deleted)


**off campus
cd "/Volumes/dept/SOM/OPH/OPH/DERegTL/Cohort2"

**on campus
cd "/Volumes/DERegTL/Cohort2"

export delimited using "T3_icd_encounter.csv", replace
*/




** --- Billing codes --- **
keep if source_icd==1
*(10,066,227 observations deleted)

codebook studyid
*N=98,737/n=9,994,739 

codebook problemonsetdate problemresolutondate
drop problemonsetdate problemresolutondate provenance source_icd noicd maxnoicd diagnosiscodetype


gen ded_icd = .
* Step 2: Map diagnosis codes to numeric categories
*Diagnosis - Dry Eye Disease 
replace ded_icd = 0  if regexm(diagnosiscode, "H16\.221|H16\.222|H16\.223")
replace ded_icd = 1  if regexm(diagnosiscode, "H11\.141|H11\.142|H11\.143")
replace ded_icd = 2  if regexm(diagnosiscode, "H04\.121|H04\.122|H04\.123")
replace ded_icd = 3  if regexm(diagnosiscode, "H16\.211|H16\.212|H16\.213")
replace ded_icd = 4  if regexm(diagnosiscode, "M35\.01")
replace ded_icd = 5  if regexm(diagnosiscode, "M35\.00")
replace ded_icd = 6  if regexm(diagnosiscode, "H16\.101|H16\.102|H16\.103")
replace ded_icd = 7  if regexm(diagnosiscode, "H16\.121|H16\.122|H16\.123")
replace ded_icd = 8  if regexm(diagnosiscode, "H16\.141|H16\.142|H16\.143")
replace ded_icd = 9  if regexm(diagnosiscode, "H16\.231|H16\.232|H16\.233")
replace ded_icd = 10 if regexm(diagnosiscode, "H18\.831|H18\.832|H18\.833")
replace ded_icd = 11 if regexm(diagnosiscode, "H02\.881|H02\.882|H02\.889|H02\.88A|H02\.88B|H02\.883|H02\.884|H02\.885|H02\.886")


gen ot_icd=.
*Diagnosis - Non-Dry Eye Disease 
replace ot_icd = 1 if regexm(diagnosiscode, "L51\.1|L51\.3")
**Stevens-Johnson syndrome and the overlap syndrom of SJS & TEN
replace ot_icd = 2 if regexm(diagnosiscode, "M35\.0A|M35\.0B|M35\.0C")
replace ot_icd = 3 if regexm(diagnosiscode, "D89\.811")
replace ot_icd = 4 if regexm(diagnosiscode, "D89\.813")
replace ot_icd = 5 if regexm(diagnosiscode, "L71\.9|L71\.8")
replace ot_icd = 6 if regexm(diagnosiscode, "H10\.821|H10\.822|H10\.823|H10\.829")
replace ot_icd = 7 if regexm(diagnosiscode, "^H01")
replace ot_icd = 8 if regexm(diagnosiscode, "L71\.0")
replace ot_icd = 9 if regexm(diagnosiscode, "L71\.1")
replace ot_icd = 10 if regexm(diagnosiscode, "M06\.9")
replace ot_icd = 11 if regexm(diagnosiscode, "M32\.9")
replace ot_icd = 12 if regexm(diagnosiscode, "^E08|^E09|^E10|^E11|^E13")
replace ot_icd = 13 if regexm(diagnosiscode, "E50\.7")

gen symp_icd=.
*Symptoms - Undiagnosed Dry Eye
replace symp_icd = 1 if regexm(diagnosiscode, "H53\.141|H53\.142|H53\.143")
replace symp_icd = 2 if regexm(diagnosiscode, "H57\.11|H57\.12|H57\.13")
replace symp_icd = 3 if regexm(diagnosiscode, "H04\.201|H04\.202|H04\.203")
replace symp_icd = 4 if regexm(diagnosiscode, "H53\.8")

*0 to 12

* Step 3: Add human-readable labels
label define Lded ///
    0  "KCS (non-Sjögren's)" ///
    1  "Conjunctival Xerosis" ///
    2  "Dry Eye Syndrome - Lacrimal" ///
    3  "Exposure Keratoconjunctivitis" ///
    4  "Sjogren with KCS" ///
    5  "Sjogren, unspecified" ///
    6  "Superficial Keratitis" ///
    7  "Filamentary Keratitis" ///
    8  "Punctate Keratitis" ///
    9  "Neurotrophic KCS" ///
    10 "Recurrent Corneal Erosion" ///
    11 "MGD", modify

label val ded_icd Lded
label var ded_icd "ICD for DED"
    
	
label define Lot ///	
	1 "Stevens-Johnson" ///
    2 "Sjögren with other involvement" ///
    3 "Chronic GVHD" ///
    4 "GVHD unspecified" ///
    5 "Rosacea (unspecified or other)" ///
    6 "Rosacea conjunctivitis" ///
    7 "Blepharitis" ///
    8 "Perioral dermatitis" ///
    9 "Rhinophyma" ///
    10 "Rheumatoid arthritis" ///
    11 "Lupus" ///
    12 "Diabetes (any type)" ///
    13 "Vitamin A deficiency",modify

label val ot_icd Lot
label var ot_icd "ICD for secondary DED"
    
	
label define Lsymp ///	
	1 "Visual discomfort" ///
    2 "Ocular pain" ///
    3 "Epiphora" ///
    4 "Visual disturbance",modify

label val symp_icd Lsymp
label var symp_icd "ICD for ocular symptoms"


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison"
save "T3.dta",replace






** ============================================ **
** COHORT 3
** patients selection **
** any visit with 1+ DED ICD code in the dataset


/*
gen cohort3=(ded_icd!=.)
label var cohort3 "ICD,CPT,meds for DED"
label val cohort3 Lyesno


*keep if cohort3==1
*(9,760,363 observations deleted)

codebook studyid
*N=39390/n=234,376

	
tab ded_icd, missing 
*N=59,252/n=734,999 with "ded_icd"
*N=98,483/n=9,259,740 without "ded_icd"

tab diagnosiscode if ded_icd == 24
*keep if ded_icd !=.
** want to keep all observations regardless of DED - that will be found in analysis
*/

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison"
use "T3.dta",clear

** for ICD "MGD"
bys studyid visitdate: gen eyelid=1 if ded_icd==11
bys studyid visitdate: egen lids=total(eyelid)
*duplicate records for bilateral MGD

drop if ded_icd==11 & lids>1
*(27,454 observations deleted)
*(45,707 observations deleted)
*(47,532 observations deleted)


/** dry eye ICD
bys studyid visitdate: egen icd_records=count(ded_icd)
sort studyid visitdate 
label var icd_records "# ICD this visit"

bys studyid visitdate: gen ded_visit=(icd_records>0)
label var ded_visit "1+ DED ICD this visit"
label val ded_visit Lyesno


** other ICD
bys studyid visitdate: egen ot_records=count(ot_icd)
sort studyid visitdate 
label var ot_records "# other ICD this visit"

bys studyid visitdate: gen ot_visit=(ot_records>0)
label var ot_visit "1+ other ICD this visit"
label val ot_visit Lyesno


** dry eye symptom ICD
bys studyid visitdate: egen symp_records=count(symp_icd)
sort studyid visitdate 
label var symp_records "# symp ICD this visit"

bys studyid visitdate: gen symp_visit=(symp_records>0)
label var symp_visit "1+ symp ICD this visit"
label val symp_visit Lyesno


** any of DED ICD, ot ICD, symptoms ICD
sort studyid visitdate
gen select=ded_visit+ot_visit+symp_visit

tab select
/*

     select |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  6,237,220       62.70       62.70 N=91806
          1 |  3,276,585       32.94       95.64 N=56965
          2 |    419,600        4.22       99.86 N=17805 
          3 |     13,802        0.14      100.00 N=1141
------------+-----------------------------------
      Total |  9,947,207      100.00
*/


drop if select==0
*(6,237,220 observations deleted)
*/

egen empty_record=rowmiss(ded_icd ot_icd symp_icd)


drop if empty_record==3
*(9,259,740 observations deleted)

codebook studyid
*N=58,481/n=679,309


drop arb_person_id encounterdate arb_encounter_id diagnosisdescription visityr eyelid lids empty_record diagnosiscode


sort studyid visitdate
bys studyid visitdate: gen seqno=_n
*bys studyid visitdate: egen maxseq=max(seqno)




reshape wide ded_icd ot_icd symp_icd,i(studyid visitdate) j(seqno)

egen num_ded_icd=rownonmiss(ded_icd1 ded_icd2 ded_icd3 ded_icd4 ded_icd5 ded_icd6 ded_icd7 ded_icd8 ded_icd9 ded_icd10 ded_icd11)
order num_ded_icd,before(ded_icd1)
label var num_ded_icd "# DED ICD codes this visit"

summ num_ded_icd,de
/*

                 # DED ICD codes this visit
-------------------------------------------------------------
      Percentiles      Smallest
 1%            1              1
 5%            1              1
10%            1              1       Obs             174,683
25%            1              1       Sum of wgt.     174,683

50%            1                      Mean           1.184557
                        Largest       Std. dev.      .4613319
75%            1              7
90%            2              7       Variance       .2128271
95%            2              7       Skewness       2.916055
99%            3              9       Kurtosis       14.25203
*/

egen num_ot_icd=rownonmiss(ot_icd1 ot_icd2 ot_icd3 ot_icd4 ot_icd5 ot_icd6 ot_icd7 ot_icd8 ot_icd9 ot_icd10 ot_icd11)
order num_ot_icd,before(ded_icd1)
label var num_ot_icd "# other ICD codes this visit"



egen num_symp_icd=rownonmiss(symp_icd1 symp_icd2 symp_icd3 symp_icd4 symp_icd5 symp_icd6 symp_icd7 symp_icd8 symp_icd9 symp_icd10 symp_icd11)
order num_symp_icd,before(ded_icd1)
label var num_symp_icd "# symptoms ICD codes this visit"


order ded_icd1 ded_icd2 ded_icd3 ded_icd4 ded_icd5 ded_icd6 ded_icd7 ded_icd8 ded_icd9 ded_icd10 ded_icd11, after(num_ded_icd)

order symp_icd1 symp_icd2 symp_icd3 symp_icd4 symp_icd5 symp_icd6 symp_icd7 symp_icd8 symp_icd9 symp_icd10 symp_icd11,after(num_symp_icd)


sort studyid visitdate

*N=39,390/n=174,683


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
*save "T3_icd_billing_long.dta",replace
*save "T3_long_simple.dta",replace
save "T3_cohort3.dta",replace



/** reshape from LONG to WIDE
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
use "T3_icd_billing_long.dta",clear

******
duplicates drop studyid visitdate arb_encounter_id, force 
drop sessionid arb_person_id arb_encounter_id

gsort studyid visitdate +diagnosiscode
bys studyid visitdate: gen seqno=_n
label var seqno "seqno dry eye ICD codes per visit"

summ seqno,de

** reshaping to wide form 
*moved visitdate from the reshape to the i()
reshape wide diagnosiscode diagnosisdescription ded_icd norecords,i(studyid visitdate) j(seqno)

gsort studyid visitdate
bys studyid:gen visitno=_n
label var visitno "visit seqno"

local icd_list ded_icd*
egen ded_icd_ind = concat(`icd_list'), punct(",")
label var ded_icd_ind "all dry eye ICD identifiers"

/*concatinate all of the diagnosis codes for the individual back into one variable
local diagnoses_list diagnosiscode*
egen diagnosiscode = concat(`diagnoses_list'), punct(",")
label var diagnosiscode "all dry eye ICD codes"
*/


keep studyid visitdate ded_icd diagnosiscode

sort studyid visitdate

cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
save "T3_billing.dta",replace
*export delimited using "T3_icd_billing_2023.csv", replace
*/



** ------------- **
** Table 5
** ------------- ** 
cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

import delimited "T5_Procedures_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
describe
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_Id
arb_encounter~d str12   %12s                  Arb_Encounter_Id
arb_procedure~d long    %12.0g                Arb_Procedure_ID
procedureepicid double  %10.0g                ProcedureEpicId
procedurename   strL    %9s                   ProcedureName
patientfriend~e strL    %9s                   PatientFriendlyName
procedurecode   str15   %15s                  ProcedureCode
proceduredate   str10   %10s                  ProcedureDate
proceduretime   str8    %9s                   ProcedureTime
providerrole    str42   %42s                  ProviderRole
department      str25   %25s                  Department
performingpro~e str41   %41s                  PerformingProvName
primarylocation str39   %39s                  PrimaryLocation
*/

missings report
/*
  +---------------------------------+
  |                       # missing |
  |---------------------------------|
  |     procedureepicid      118919 |
  |       procedurename          36 |
  | patientfriendlyname          36 |
  |       procedurecode          36 |
  +---------------------------------+
*/

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

codebook studyid
*N=96,885/n=9,443,522

label define Lyesno 0"no" 1"yes",modify


/*
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
merge m:1 studyid using t1_person.dta
keep if _merge == 3
drop _merge 
*/

gen visitdate=date(proceduredate,"19YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate proceduredate,after(arb_person_id)

gen calyear=year(visitdate)
label var calyear "year of visit"
tab calyear, m
/*
    year of |
      visit |      Freq.     Percent        Cum.
------------+-----------------------------------
       2017 |    847,749        9.09        9.09
       2018 |    953,683       10.22       19.31
       2019 |  1,032,557       11.07       30.37
       2020 |    960,691       10.30       40.67
       2021 |  1,167,007       12.51       53.18
       2022 |  1,279,861       13.72       66.90
       2023 |  1,468,170       15.74       82.63
       2024 |  1,620,589       17.37      100.00
------------+-----------------------------------
      Total |  9,330,307      100.00
*/

gen sessionid=arb_encounter_id
order sessionid, before(arb_encounter_id)
destring arb_encounter_id, replace

/*procedure code = cptcode_ind
labels : 
1 = LipiFlow - evacuation of meibomian glans, automated, using heat and intermittent pressure, unilateral
2 = TearCare - evacuation of meibomian glands, using heat delivered through wearable, open-eye eyelid treatment devices and manual gland expression, bilateral
3 = Meibomiography - near-infrared dual imaging (i.e., simultaneous reflective and trans-illuminated light) of meibomian glands, unilateral or bilateral, with interpretation and report
4 = Closure of the lacrimal punctum, by thermocauterization, ligation, or laser surgery, each
5 = Closure of the lacrimal punctum, by plug, each
6 = Fitting of contact lens for treatment of disease, including supply of lens
7 = Tarsorrhaphy procedures on the eyelids
8 = Repair (Brow Ptosis, Blepharoptosis, Lid Retraction, Ectropion, Entropion) Procedures on the Eyelids
9 = Probing nasolacrimal duct 
*/

gen cptcode_ind = ///
	cond(procedurecode=="0207T", 1, ///
	cond(procedurecode=="0563T", 2, ///
	cond(procedurecode=="0507T", 3, ///
	cond(procedurecode=="68760", 4, ///
	cond(procedurecode=="68761-50", 5, ///
	cond(procedurecode=="A4263", 6, ///
	cond(procedurecode=="92070", 7, ///
	cond(procedurecode=="67875", 8, ///
	cond(procedurecode=="67912", 9, ///
	cond(inlist(procedurecode, "68810", "68811", "68815"), 10, ///
	cond(procedurecode=="V2627" | procedurecode=="65778", 11,.)))))))))))
replace cptcode_ind=. if cptcode_ind == 0

label define Lcpt 1"0207T" 2"0563T" 3"0507T" 4"68760" 5"68761-50" 6"A4263" 7"92070" 8"67875" 9"67912" ///
				  10"68810,11,15" 11"V2627 or 65778",modify
label val cptcode_ind Lcpt


				 


	
gen otcptcode_ind = ///	
	cond(procedurecode=="66821", 1, ///
	cond(procedurecode=="S0800", 2, ///
	cond(procedurecode=="S0810", 3, ///
	cond(procedurecode=="66999", 4, ///
	cond(procedurecode=="66711", 5, ///
	cond(procedurecode=="66840", 6, ///
	cond(procedurecode=="66850", 7, ///
	cond(procedurecode=="66852", 8, ///
	cond(procedurecode=="66920", 9, ///
	cond(procedurecode=="66930", 10, ///
	cond(procedurecode=="66940", 11, ///
	cond(procedurecode=="66983", 12, ///
	cond(procedurecode=="66984", 13, ///
	cond(procedurecode=="66987", 14, .))))))))))))))
				  
replace otcptcode_ind=. if otcptcode_ind == 0

tab cptcode_ind,m
/*
cptcode_ind |      Freq.     Percent        Cum.
------------+-----------------------------------
          4 |         37        0.00        0.00
          6 |          4        0.00        0.00
          8 |        442        0.00        0.01
          9 |         72        0.00        0.01
         10 |        401        0.00        0.01
          . |  9,442,566       99.99      100.00
------------+-----------------------------------
      Total |  9,443,522      100.00
*/

tab otcptcode_ind,m
/*
otcptcode_i |
         nd |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      4,786        0.05        0.05
          4 |         41        0.00        0.05
          5 |        321        0.00        0.05
          6 |         14        0.00        0.05
          7 |         69        0.00        0.06
          8 |         56        0.00        0.06
          9 |         17        0.00        0.06
         10 |         17        0.00        0.06
         11 |          5        0.00        0.06
         12 |          3        0.00        0.06
         13 |     20,025        0.21        0.27
         14 |          5        0.00        0.27
          . |  9,418,163       99.73      100.00
------------+-----------------------------------
      Total |  9,443,522      100.00
*/

** ============================================ **
** COHORT 3
** patients selection **
** any visit with 1+ DED CPT code in the dataset

gen cohort3=(cptcode_ind!=.)
label var cohort3 "ICD,CPT,meds for DED"
label val cohort3 Lyesno


keep if cohort3==1
*(9,442,566 observations deleted)

codebook studyid
*N=775/n=956

keep studyid visitdate procedurename cptcode_ind

sort studyid visitdate cptcode_ind
bys studyid visitdate: gen seqno=_n

bys studyid visitdate: egen num_proc=max(seqno)
label var num_proc "# CPT codes this visit"
rename cptcode_ind cptcode

reshape wide procedurename cptcode,i(studyid visitdate) j(seqno)
order num_proc,after(visitdate)


sort studyid visitdate
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
save "T5_cohort3.dta",replace











/*
codebook procedurecode if cptcode_ind == .
* N = 16,821

*drop if cptcode_ind==.
** want to keep all observations - analysis will find relavance

codebook studyid
* N = 14,892

keep studyid visitdate cptcode_ind procedurecode
duplicates drop studyid visitdate cptcode_ind, force 

gsort studyid visitdate 
bys studyid visitdate: gen seqno=_n
label var seqno "CPT codes per visit"

reshape wide cptcode_ind procedurecode ,i(studyid visitdate) j(seqno)

*concatinate all of the cpt codes for the individual back into one variable
local cptcode_list cptcode_ind1 cptcode_ind2
egen cptcode_ind = concat(`cptcode_list'), punct(",")
label var cptcode_ind "all CPT codes"

order studyid,before(visitdate)
codebook studyid

keep studyid visitdate cptcode_ind

cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
save "T5_procedures.dta",replace
*export delimited using "table_5_17to24.csv", replace

*/




** ------------- **
** Table 7 
** ------------- ** 
cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"


import delimited "T7_Medication_20250205.csv", varnames(1) asdouble stringcols(1 2) clear

describe
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_ID
arb_encounter~d str12   %12s                  Arb_Encounter_Id
medicationepi~d double  %12.0g                MedicationEpicId
medicationord~d long    %12.0g                MedicationOrderEpicId
code            str14   %14s                  Code
medicationname  str64   %64s                  MedicationName
source          str37   %37s                  Source
dose            int     %8.0g                 Dose
doseunit        str12   %12s                  DoseUnit
medicationsta~e str10   %10s                  MedicationStartDate
medicationsto~e str10   %10s                  MedicationStopDate
route           str28   %28s                  Route
frequency       str39   %39s                  Frequency
mode            str10   %10s                  Mode
therapeuticcl~s str26   %26s                  TherapeuticClass
pharmace~lclass str50   %50s                  PharmaceuticalClass
pharmace~bclass str70   %70s                  PharmaceuticalSubclass
ordereddate     str10   %10s                  OrderedDate
dispenseprepa~t str23   %23s                  DispensePreparedInstant
orderedbyprov~r str39   %39s                  OrderedByProvider
authorizingpr~r str39   %39s                  AuthorizingProvider
orderedbyspec~y str49   %49s                  OrderedBySpecialty
authorizingby~y str49   %49s                  AuthorizingBySpecialty
*/

label define Lyesno 0"no" 1"yes",modify

*missings report
*not done yet 

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

/*
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
merge m:1 studyid using t1_person.dta
keep if _merge == 3
drop _merge 
*/

codebook studyid
*N=39,155/n=29,883,218



/*
gen sessionid=arb_encounter_id
order sessionid, before(arb_encounter_id)
destring arb_encounter_id, replace
*/

gen visitdate=date(ordereddate,"19YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate,before(ordereddate)

/*
gen calyear=year(visitdate)
tab calyear, m



gen date_order=date(ordereddate,"19YMD")
label var date_order "date of med order"
format date_order %td
order date_order,before(ordereddate)

gen medt0=date(medicationstartdate,"19YMD")
label var medt0 "start of med"
format medt0 %td
order medt0,before(medicationstartdate)

gen medt1=date(medicationstopdate,"19YMD")
label var medt1 "stop of med"
format medt1 %td
order medt1,before(medicationstopdate)
*/

set seed 3056139
sort studyid visitdate medicationname code,stable
bys studyid visitdate medicationname: gen seqno=_n

codebook seqno
*range 1 to 7174
keep if seqno==1
*(29,670,635 observations deleted)

codebook studyid
*N=39,155/n=212,583

drop seqno


cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
save "T7_medication_s.dta",replace
**removed duplicates of the same medication documented on the same day





** Variables derivation for LDA **
** ---------------------------- **
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"
use "T7_medication_s.dta",clear

codebook studyid
*N=39,155/n=212,583


encode route,gen(med_route)


tab med_route
/*
                *Unspecified |     46,830       22.03       22.03
               As Instructed |        495        0.23       22.26
                   Both Eyes |     82,226       38.68       60.94
                   Each Nare |      1,159        0.55       61.49
                    Ear/Otic |          1        0.00       61.49
                Feeding Tube |         63        0.03       61.52
                Infiltration |         14        0.01       61.52
                   Injection |          1        0.00       61.52
              Intra-catheter |          9        0.00       61.53
                 Intraocular |         59        0.03       61.56
                 Intravenous |      1,967        0.93       62.48
                  Irrigation |          4        0.00       62.48
                    Left Eye |     15,609        7.34       69.83
          Local Infiltration |         18        0.01       69.83
Misc.(Non-Drug; Combo Route) |          2        0.00       69.83
                       Nasal |          4        0.00       69.84
                  Ophthalmic |      8,404        3.95       73.79
                        Oral |     40,297       18.96       92.75
                       Other |          1        0.00       92.75
                  Per G Tube |          1        0.00       92.75
                   Right Eye |     15,399        7.24       99.99
                     Topical |         18        0.01      100.00
               Topical (Top) |          2        0.00      100.00
-----------------------------+-----------------------------------
                       Total |    212,583      100.00			   
					   
*/
*cyclosporine po "not for dry eye patients"?

gen eye_nasal=(med_route==3|med_route==5|med_route==11|med_route==14| ///
			   med_route==17|med_route==18|med_route==22) if route!=""
label val eye_nasal Lyesno
label var eye_nasal "Route: eye drops or nasal spray?"


local term "eye nasal op"
foreach y of local term{
	replace eye_nasal=1 if regexm(lower(medicationname), "`y'") & eye_nasal==0
}
*(64,384 real changes made)
*(1,203 real changes made)
*(70 real changes made)




** EYEDROPS for DED
gen ded_eyedrop = .
replace ded_eyedrop = 1 if regexm(lower(medicationname), "cyclosporine")
replace ded_eyedrop = 2 if regexm(lower(medicationname), "restasis")
replace ded_eyedrop = 3 if regexm(lower(medicationname), "xiidra")
replace ded_eyedrop = 4 if regexm(lower(medicationname), "cequa")
replace ded_eyedrop = 5 if regexm(lower(medicationname), "lifitegrast")
replace ded_eyedrop = 6 if regexm(lower(medicationname), "tyrvaya")

label define Lmeds 1 "Cyclosporine" ///
						 2 "Restasis" ///
						 3 "Xiidra" ///
						 4 "Cequa" ///
						 5 "Lifitegrast" ///
						 6 "Tyrvaya",modify
						 
label val ded_eyedrop Lmeds
label var ded_eyedrop "DED drops or spray"

tab ded_eyedrop eye_nasal,m
/*
             |  Route: eye drops or
DED drops or |     nasal spray?
       spray |        no        yes |     Total
-------------+----------------------+----------
Cyclosporine |       147     15,513 |    15,660  N=5787 
    Restasis |         0      4,700 |     4,700  N=2579
      Xiidra |         0      3,276 |     3,276  N=1684
       Cequa |         0      1,365 |     1,365  N=698
 Lifitegrast |         0      3,730 |     3,730  N=2066
     Tyrvaya |         0        817 |       817  N=404
           . |    13,848    169,187 |   183,035 
-------------+----------------------+----------
       Total |    13,995    198,588 |   212,583  N=8513
*/

replace ded_eyedrop=. if eye_nasal==0
*(147 real changes made, 147 to missing)

codebook studyid if ded_eyedrop!=.
*N=8665/n=29,401 using DED eyedrops or spray




**ANTIBX for MGD
gen ded_caps=.
replace ded_caps = 7 if regexm(lower(medicationname), "doxycycline")
replace ded_caps = 8 if regexm(lower(medicationname), "azithromycin")
*changed from looking for doxycycline gel to just the term doxycycline
label define Lcaps 7 "Doxycycline" ///
				   8 "Azithromycin", modify
label val ded_caps Lcaps
label var ded_caps "MGD antibx caps"
						

**DED meds
gen ded_meds=ded_eyedrop
replace ded_meds=ded_caps if ded_meds==.&ded_caps!=.

label define Ldedmeds 1 "Cyclosporine" ///
					  2 "Restasis" ///
					  3 "Xiidra" ///
					  4 "Cequa" ///
					  5 "Lifitegrast" ///
					  6 "Tyrvaya" ///						
					  7 "Doxycycline" ///
				      8 "Azithromycin", modify		
label val ded_meds Ldedmeds
label var ded_meds "DED prescripts"	
						
tab ded_meds eye_nasal,m
/*
             |  Route: eye drops or
         DED |     nasal spray?
  prescripts |        no        yes |     Total
-------------+----------------------+----------
Cyclosporine |         0     15,513 |    15,513 
    Restasis |         0      4,700 |     4,700 
      Xiidra |         0      3,276 |     3,276 
       Cequa |         0      1,365 |     1,365 
 Lifitegrast |         0      3,730 |     3,730 
     Tyrvaya |         0        817 |       817 
 Doxycycline |     1,932     15,900 |    17,832 
Azithromycin |     7,458      6,035 |    13,493 
           . |     4,605    147,252 |   151,857 
-------------+----------------------+----------
       Total |    13,995    198,588 |   212,583 


*/						
						

						
**GLAUCOMA meds

gen glaucoma_meds=.
*Loop through all of the glaucoma meds to see if any are present and need seperated out
local iop_meds "acetazolamide alphagan apraclonidine azopt betagan betaxolol betimol betoptic bimatoprost brimonidine brimonidine brinzolamide combigan cosopt diamox dorzolamide dorzolomide iopidine istalol iyuzeh latanoprost latanoprost latanoprostene levobunolol lumigan methazolamide metipranolol neptazane netarsudil netarsudil optipranolol pilocarpine pilopine rhopressa rocklatan simbrinza tafluprost timolol timoptic-xe travatan travoprost trusopt vyzulta xalatan zioptan"
foreach srt of local iop_meds {
    di "Checking for: `srt'"
    replace glaucoma_meds = 1 if regexm(lower(medicationname), "`srt'")
}
macro drop iop_meds
label val glaucoma_meds Lyesno
label var glaucoma_meds "glaucoma med this record"

/*
*isopto carbachol
replace glaucoma_meds=1 if regexm(lower(medicationname), "isopto carbachol")
replace glaucoma_meds=1 if regexm(lower(medicationname), "isopto")
replace glaucoma_meds=1 if regexm(lower(medicationname), "carbachol")
*/


replace glaucoma_meds=0 if glaucoma_meds==.
*(84,663 real changes made)

tab ded_meds glaucoma_meds,m
/* medication-level

         DED |     glaucoma_meds
  prescripts |        no        yes |     Total
-------------+----------------------+----------
Cyclosporine |    15,513          0 |    15,513 
    Restasis |     4,700          0 |     4,700 
      Xiidra |     3,276          0 |     3,276 
       Cequa |     1,365          0 |     1,365 
 Lifitegrast |     3,730          0 |     3,730 
     Tyrvaya |       817          0 |       817 
 Doxycycline |    17,832          0 |    17,832 
Azithromycin |    13,493          0 |    13,493 
           . |    23,937    127,920 |   151,857 
-------------+----------------------+----------
       Total |    84,663    127,920 |   212,583 


*/

codebook studyid if glaucoma_meds==1
*N=17,702/n=127,920

sort studyid visitdate glaucoma_meds
order visitdate ordereddate,after(studyid)

sort studyid visitdate
bys studyid visitdate: egen num_glau_meds=total(glaucoma_meds)
label var num_glau_meds "# glaucoma meds this visit"

sort studyid visitdate
bys studyid: egen use_glau_med=max(num_glau_meds)
label var use_glau_med "users of glaucoma meds"



codebook use_glau_med
/*
            Tabulation: Freq.  Value
                       59,614  0
                       50,427  1
                       50,098  2
                       36,905  3
                       11,698  4
                        3,024  5
                          527  6
                          290  7

*/

replace use_glau_med=1 if use_glau_med>1
label val use_glau_med Lyesno

codebook studyid if use_glau_med==1
*N=17702


tab ded_meds use_glau_med,m
/* visit-level

             |   users of glaucoma
         DED |         meds
  prescripts |        no        yes |     Total
-------------+----------------------+----------
Cyclosporine |    10,174      5,339 |    15,513 
    Restasis |     3,089      1,611 |     4,700 
      Xiidra |     2,324        952 |     3,276 
       Cequa |       906        459 |     1,365 
 Lifitegrast |     2,609      1,121 |     3,730 
     Tyrvaya |       607        210 |       817 
 Doxycycline |    12,980      4,852 |    17,832 
Azithromycin |     9,800      3,693 |    13,493 
           . |    17,125    134,732 |   151,857 
-------------+----------------------+----------
       Total |    59,614    152,969 |   212,583 

*/

*drop if ded_meds==. & glaucoma==0
*(23,136 observations deleted)

*codebook studyid
*N=33,487/n=187,447



codebook studyid
*N=39,155/n=212,583

sort studyid visitdate
save "T7_meds_s_longlong.dta",replace





**# now in the long-long form, 
**  with 1+ meds on the same-day
**  "collapse" into the same classes
** ====================================== **


use "T7_meds_s_longlong.dta",clear

keep studyid visitdate ded_meds use_glau_med

drop if ded_meds==.
*(127,920 observations deleted)
*(151,856 observations deleted)


sort studyid visitdate ded_meds
bys studyid visitdate ded_meds: gen seqno=_n
codebook seqno
/*
            Tabulation: Freq.  Value
                       59,788  1
                          906  2
                           28  3
                            3  4
                            2  5

*/


keep if seqno==1
*(939 observations deleted)
*same meds on the same date

drop seqno

codebook studyid
*N=21,104/n=59,789



** now in the long form (one person multiple records, medication list in columns)

sort studyid visitdate ded_meds,stable
bys studyid visitdate: gen seqno=_n

tab seqno
/*

      seqno |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |     58,380       97.64       97.64
          2 |      1,376        2.30       99.94
          3 |         31        0.05      100.00
          4 |          2        0.00      100.00
------------+-----------------------------------
      Total |     59,789      100.00

*/

	  
reshape wide ded_meds,i(studyid visitdate) j(seqno)

sort studyid visitdate
egen num_ded_meds=rownonmiss(ded_meds1 ded_meds2 ded_meds3 ded_meds4)
label var num_ded_meds "# DED meds this visit"
order num_ded_meds,after(visitdate)


tab num_ded_meds
/*
 # DED meds |
 this visit |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |     57,004       97.64       97.64
          2 |      1,345        2.30       99.95
          3 |         29        0.05      100.00
          4 |          2        0.00      100.00
------------+-----------------------------------
      Total |     58,380      100.00
*/

codebook studyid
*N=21104/n=58380

/*
sort studyid visitdate ded_meds
bys studyid: gen fu_d=visitdate-visitdate[1]
label var fu_d "FU time in days"

gen fu_m=fu_d/30.5
label var fu_m "FU time in months"

tabstat fu_d fu_m,stat(p50 p25 p75 mean sd min max n) c(s)
/*
    Variable |       p50       p25       p75      Mean        SD       Min       Max         N
-------------+--------------------------------------------------------------------------------
        fu_d |       107         0       743  472.5139  669.8732         0      2911     58798
        fu_m |  3.508197         0  24.36065  15.49226  21.96306         0  95.44262     58798
----------------------------------------------------------------------------------------------
*/

drop fu_d

gen tp=1*(fu_m>0 & fu_m<=3)+ ///
	   2*(fu_m>3&fu_m<=6)+ ///
	   3*(fu_m>6&fu_m<=12)+ ///
	   4*(fu_m>12&fu_m<=18)+ ///
	   5*(fu_m>18&fu_m<=24)+ ///
	   6*(fu_m>24&fu_m<=36)+ ///
	   7*(fu_m>36&fu_m<=48)+ ///
	   8*(fu_m>48&fu_m<=60)+ ///
	   9*(fu_m>60)

label var tp "timepoint"
label define Lfu 0"baseline" 1"3m" 2"6m" 3"12m" 4"18m" 5"24m" 6"36m" 7"48m" 8"60m" 9"5+yrs",modify
label val tp Lfu
*/



/** change in # DED meds
sort studyid visitdate ded_meds
bys studyid visitdate: gen seqno=_n
bys studyid visitdate: egen num_meds=max(seqno)

label var seqno "# DED prescripts this visit"

bys studyid visitdate: egen num_ded_meds=max(seqno)
reshape wide ded_meds,i(studyid visitdate) j(seqno)

order num_meds use_glau_med,after(visitdate)
label var num_meds "# DED prescripts this visit"
*/


sort studyid visitdate,stable
cd "/Users/alisonliu/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/New"
save "T7_cohort3.dta",replace

























** ======================== **
** merge with T102818.dta


merge m:m studyid visitdate using "working_T102818.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       743,427
        from master                    60,139  (_merge==1)
        from using                    683,288  (_merge==2)

    Matched                           160,147  (_merge==3)
    -----------------------------------------
*/

tab cohort2 cohort3,m
/*
   dry eye |
    cohort |     dryeye cohort
(secondary |       (primary)
         ) |       yes          . |     Total
-----------+----------------------+----------
       yes |   156,113    642,562 |   798,675 
         . |    64,173     40,726 |   104,899 
-----------+----------------------+----------
     Total |   220,286    683,288 |   903,574 

*/


codebook studyid if cohort2==1&cohort3==1
*N=40085/n=156113

keep if cohort2==1&cohort3==1
*(747,461 observations deleted)


sort studyid visitdate

save "cohort3-outcome.dta",replace






tab medication, missing
/*
 Medications |      Freq.     Percent        Cum.
-------------+-----------------------------------
Cyclosporine |    636,683        2.13        2.13
    Restasis |     86,881        0.29        2.42
      Xiidra |     45,831        0.15        2.57
       Cequa |     14,682        0.05        2.62
 Lifitegrast |     19,653        0.07        2.69
     Tyrvaya |      7,600        0.03        2.72
 Doxycycline |  7,610,958       25.47       28.18
Azithromycin |  3,169,321       10.61       38.79
Glucose meds |  4,651,396       15.57       54.35
           . | 13,640,213       45.65      100.00
-------------+-----------------------------------
       Total | 29,883,218      100.00
*/

* Of those medications identified what routes are they administered through
tab med_route if medication != .
/*
                       Route |      Freq.     Percent        Cum.
-----------------------------+-----------------------------------
                *Unspecified |  3,489,260       21.48       21.48
               As Instructed |     28,951        0.18       21.66
                   Both Eyes |  3,004,871       18.50       40.16
                      Buccal |         21        0.00       40.16
                   Each Nare |      7,264        0.04       40.20
                    Ear/Otic |         22        0.00       40.20
                Feeding Tube |     11,552        0.07       40.28
              Intra-catheter |         23        0.00       40.28
                 Intraocular |      1,942        0.01       40.29
                 Intravenous |      5,200        0.03       40.32
                  Irrigation |          1        0.00       40.32
                    Left Eye |    674,836        4.15       44.47
Misc.(Non-Drug; Combo Route) |          2        0.00       44.47
                       Nasal |         24        0.00       44.47
                  Ophthalmic |    198,782        1.22       45.70
                        Oral |  8,154,170       50.20       95.90
                       Other |        392        0.00       95.90
                  Per G Tube |         84        0.00       95.90
              Right Ear/Otic |          7        0.00       95.90
                   Right Eye |    664,853        4.09      100.00
                     Topical |        658        0.00      100.00
               Topical (Top) |         90        0.00      100.00
-----------------------------+-----------------------------------
                       Total | 16,243,005      100.00
*/

*Of those that were not identified as one of the dry eye meds or glucose meds, what route were they administered
tab med_route if medication ==.
/*
                       Route |      Freq.     Percent        Cum.
-----------------------------+-----------------------------------
                *Unspecified |  2,199,705       16.13       16.13
               As Instructed |     25,364        0.19       16.31
                   Both Eyes |     28,525        0.21       16.52
                   Each Nare |      2,484        0.02       16.54
                Feeding Tube |      3,369        0.02       16.56
                Infiltration |         30        0.00       16.56
                   Injection |          2        0.00       16.56
                 Intraocular |          6        0.00       16.56
                 Intravenous |         37        0.00       16.57
                  Irrigation |          5        0.00       16.57
                    Left Eye |      2,556        0.02       16.58
          Local Infiltration |         39        0.00       16.58
                       Nasal |          6        0.00       16.58
                  Ophthalmic |      3,172        0.02       16.61
                        Oral | 11,372,659       83.38       99.98
                   Right Eye |      2,246        0.02      100.00
                     Topical |          8        0.00      100.00
-----------------------------+-----------------------------------
                       Total | 13,640,213      100.00
*/

*looking at the data for those of missing meidcations after the above meds have been sorted out
tab medicationname if medication == .
/*
                         MedicationName |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
             AMOXICILLIN 500 MG CAPSULE |  3,457,428       25.35       25.35
           BIMATOPROST 0.01 % EYE DROPS |     20,412        0.15       25.50
BIMATOPROST 0.03 % DROPS WITH APPLICA.. |      6,292        0.05       25.54
           BIMATOPROST 0.03 % EYE DROPS |     14,976        0.11       25.65
              CEPHALEXIN 500 MG CAPSULE |  8,876,728       65.08       90.73
            CIPROFLOXACIN 750 MG TABLET |     28,980        0.21       90.94
         CLINDAMYCIN HCL 300 MG CAPSULE |    615,257        4.51       95.45
DORYX MPC 120 MG TABLET, DELAYED RELE.. |         11        0.00       95.45
                 GENGRAF 100 MG CAPSULE |        344        0.00       95.46
                  GENGRAF 25 MG CAPSULE |      2,104        0.02       95.47
             LEVOFLOXACIN 750 MG TABLET |    546,128        4.00       99.48
               LUMIFY 0.025 % EYE DROPS |        410        0.00       99.48
             MINOCYCLINE 100 MG CAPSULE |     65,560        0.48       99.96
                  NEORAL 100 MG CAPSULE |         96        0.00       99.96
                   NEORAL 25 MG CAPSULE |        480        0.00       99.96
ORACEA 40 MG CAPSULE,IMMEDIATE - DELA.. |        228        0.00       99.96
                              ORACEA PO |          3        0.00       99.96
              TIMOPTIC 0.25 % EYE DROPS |         48        0.00       99.97
               TIMOPTIC 0.5 % EYE DROPS |        207        0.00       99.97
TIMOPTIC OCUDOSE (PF) 0.25 % EYE DROP.. |         65        0.00       99.97
TIMOPTIC OCUDOSE (PF) 0.5 % EYE DROPS.. |        924        0.01       99.97
VARENICLINE TARTRATE 0.03 MG/SPRAY ME.. |      2,496        0.02       99.99
VERKAZIA 0.1 % EYE DROPS IN A DROPPER.. |         35        0.00       99.99
                 VUITY 1.25 % EYE DROPS |        234        0.00       99.99
      XELPROS 0.005 % EYE DROP EMULSION |        567        0.00      100.00
                ZITHROMAX 500 MG TABLET |         12        0.00      100.00
          ZITHROMAX Z-PAK 250 MG TABLET |         66        0.00      100.00
             ZZ EXTEMPORANEOUS TEMPLATE |        122        0.00      100.00
----------------------------------------+-----------------------------------
                                  Total | 13,640,213      100.00
*/

codebook studyid 
* N = 39,155

*drop if medication == . 
**don't want to drop any observations - analysis will find ded

duplicates tag studyid medication sessionid medicationepicid medt0 medt1 authorizingprovider authorizingbyspecialty, gen(dup)
 
bys studyid medication sessionid medicationepicid medt0 medt1 authorizingprovider authorizingbyspecialty: gen seqno=_n

keep if seqno==1

drop dup seqno code

sort studyid sessionid medt0 medt1

gen check=(ordereddate==medicationstartdate) if medicationstartdate!=""

tab check,m
/*
      check |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        982        3.81        3.81
          1 |     23,873       92.64       96.45
          . |        914        3.55      100.00
------------+-----------------------------------
      Total |     25,769      100.00
*/

*same as
*gen check2=(visitdate<medt0) if medt0!=.

gen check3=(medt0==medt1) if check==0
*same-day single-use medicationstartdate
*(1,157 missing values generated)

tab check3,m
/*
     check3 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        924        3.60        3.60
          1 |         47        0.18        3.79
          . |     24,665       96.21      100.00
------------+-----------------------------------
      Total |     25,636      100.00
*/

tab medication, missing

cd "Z:/OPH/DERegTL/Dry eye Registry/Data/Stata/New - 20250205"
save "T7_meds_long_17to24.dta",replace


cd "Z:/OPH/DERegTL/Dry eye Registry/Data/Stata/New - 20250205"
use "T7_meds_long_17to24.dta",clear

codebook studyid
*N=33,425

keep studyid arb_person_id medt0 medt1 medicationname source route frequency mode visitdate med_route medication

rename medt0 med_st
rename medt1 med_end

*duplicates tag studyid visitdate medicationname route, gen(dup)

sort studyid visitdate medicationname
bys studyid visitdate: gen seqno=_n

reshape wide med_st med_end medication medicationname source route frequency mode med_route ,i(studyid visitdate) j(seqno)

ds medication*
local allvars `r(varlist)'

// Step 2: Keep only those that exactly match "medication" followed by digits (i.e., medication1, medication2, ...)
local medlist
foreach var of local allvars {
    if regexm("`var'", "^medication[0-9]+$") {
        local medlist `medlist' `var'
    }
}

// Step 3: Combine them into one variable
egen all_medications = concat(`medlist'), punct(", ")
label var all_medications "All medication codes"

tab medication

local route_list med_route*
egen med_route = concat(`route_list'), punct(",")
label var med_route"all med routes"

gen calyear = year(visitdate)

codebook studyid

order arb_person_id, after(studyid)

sort studyid visitdate
rename all_medications medication
keep studyid visitdate medication med_route

cd "Z:/OPH/DERegTL/Dry eye Registry/Data/Stata/New - 20250205"
save "T7_Medications.dta",replace


**# Bookmark 1
** ================ **
** Table 8
** ================ ** 
*cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"

cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

import delimited "T8_Labs_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
*describe
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_ID
arb_encounter~d str12   %12s                  Arb_Encounter_Id
labepicid       str15   %15s                  LabEpicID
laborderepicid  long    %12.0g                LabOrderEpicId
labname         str67   %67s                  LabName
panelname       str85   %85s                  PanelName
componentname   str60   %60s                  ComponentName
numericvalue    double  %10.0g                NumericValue
unit            str27   %27s                  Unit
referencerange  str249  %249s                 ReferenceRange
collectiondate  str10   %10s                  CollectionDate
resultdate      str10   %10s                  ResultDate
authorizingprov str40   %40s                  AuthorizingProv
loinccode       str12   %12s                  LoincCode
*/

label define Lyesno 0"no" 1"yes",modify

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

/*
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
merge m:1 studyid using t1_person.dta
keep if _merge == 3
drop _merge 
*/

codebook studyid
* N=66,367/n=24,478,465

gen visitdate=date(collectiondate,"19YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate,before(collectiondate)

*gen calyear=year(visitdate)
*tab calyear, m


gen osmo_ind_os=1 if strpos(lower(componentname),"osmolarity - left")>0
label var osmo_ind_os "indicator for tear osmo results(os)"
label val osmo_ind_os Lyesno
*N=2220/n=2592

gen osmo_ind_od=1 if strpos(lower(componentname),"osmolarity - right")>0
label var osmo_ind_od "indicator for tear osmo results(od)"
label val osmo_ind_od Lyesno
*N=2221/n=2594

/*
gen ssa_ind=1 if strpos(lower(componentname),"syndrome-a igg")==10
label var ssa_ind "indicator for Sjogrens Syndrome-A IgG results"
label val ssa_ind Lyesno
*N=4920 /n=5565

gen ssb_ind=1 if strpos(lower(componentname),"syndrome-b igg")==10
label var ssb_ind "indicator for Sjogrens Syndrome-B results"
label val ssb_ind Lyesno
*N=4955 /n=5599
*/

codebook *ind*

*gen lab=(osmo_ind_os==1|osmo_ind_od==1|ssa_ind==1|ssb_ind==1) 

gen lab=(osmo_ind_os==1|osmo_ind_od==1) 

keep if lab==1
*(24,462,115 observations deleted)
*(11,164 observations deleted)

codebook studyid
*N=6,858/n=16,350
*N=2,222/n=5,186



/*
*cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
*log using Labs_Codebook_Single.log, replace
* Display codebook for each individual procedure and its label
display "Each individual lab "
levelsof test_result, local(levels)
foreach l in `levels' {
	local lbl : label Ltest_result `l'
    display "Codebook for medication == `l' `lbl' "
    codebook studyid if test_result == `l' 
}
*log close
*/"

sort studyid visitdate componentname
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

**# Bookmark 2
save "T8_tear_osmo_long.dta",replace




use "T8_tear_osmo_long.dta",clear

keep studyid visitdate componentname numericvalue osmo_ind_os osmo_ind_od
sort studyid visitdate componentname

gen osmo=numericvalue if osmo_ind_os!=.
replace osmo=numericvalue if osmo_ind_od!=.

sort studyid visitdate componentname
bys studyid visitdate: gen seqno=_n

drop *ind* componentname numericvalue

reshape wide osmo,i(studyid visitdate) j(seqno)

egen nomissing=rownonmiss(osmo1 osmo2 osmo3 osmo4 osmo5 osmo6)
tab nomissing
drop if nomissing==0
*n=3

codebook studyid if osmo1!=.
*N=2205
codebook studyid if osmo2!=.
*N=2210
codebook studyid if osmo3!=.
*N=15 (0.68%)
codebook studyid if osmo5!=.
*N=1

** unsure if additional measures on the same day were after intervention or simple repeats
** take only the first set measures

gen tear_osmo=(osmo1+osmo2)/2
*(28 missing values generated)
label var tear_osmo "ave tear osmolarity"
replace tear_osmo=osmo1 if osmo2==.
*(9 real changes made)
replace tear_osmo=osmo2 if osmo1==.
*(19 real changes made)

drop osmo3-osmo6

codebook studyid if tear_osmo!=.
*N=2219

sort studyid visitdate
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

save "T8_tear_osmo.dta",replace




** ============= **
** Table 18
** ============= ** 
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Raw/2025-02-05"

import delimited "T18_OphthamologyExams_20250205.csv", varnames(1) asdouble stringcols(1 2) clear

*describe
/*
Variable      Storage   Display    Value
    name         type    format    label      Variable label
---------------------------------------------------------------------
arb_person_id   str11   %11s                  Arb_Person_ID
arb_encounter~d str12   %12s                  Arb_Encounter_Id
smartdataelem~d str16   %16s                  SmartDataElementEpicId
examname        str109  %109s                 ExamName
abbreviation    str41   %41s                  Abbreviation
value           strL    %9s                   Value
date            str10   %10s                  Date
*/

/*
  +-------------------+
  |         # missing |
  |-------------------|
  | value        7427 |
  +-------------------+
*/

gen studyid=arb_person_id
order studyid, before(arb_person_id)
*destring arb_person_id, replace

/*
cd "Z:\OPH\DERegTL\Dry eye Registry\Data\Stata\New - 20250205"
merge m:1 studyid using t1_person.dta
keep if _merge == 3
drop _merge 
*/


codebook studyid
* N = 93,515 /n=8,796,061

gen visitdate=date(date,"19YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate,before(date)


/*
gen calyear=year(visitdate)
tab calyear, m
/*
    calyear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2017 |    989,391       11.25       11.25
       2018 |  1,046,625       11.90       23.15
       2019 |  1,019,062       11.59       34.73
       2020 |    900,384       10.24       44.97
       2021 |  1,138,507       12.94       57.91
       2022 |  1,182,736       13.45       71.36
       2023 |  1,233,802       14.03       85.38
       2024 |  1,285,554       14.62      100.00
------------+-----------------------------------
      Total |  8,796,061      100.00
*/
*keep if calyear >= 2017 & calyear <= 2024
*/

duplicates tag studyid visitdate examname value,gen(dupind)
tab dupind
/*
     dupind |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  8,581,754       97.56       97.56
          1 |    208,452        2.37       99.93
          2 |      5,178        0.06       99.99
          3 |        504        0.01      100.00
          4 |         95        0.00      100.00
          5 |         54        0.00      100.00
          6 |          7        0.00      100.00
          7 |          8        0.00      100.00
          8 |          9        0.00      100.00
------------+-----------------------------------
      Total |  8,796,061      100.00
*/

sort studyid visitdate examname value
bys studyid visitdate examname value: gen seqno=_n
keep if seqno==1
*(108,198 observations deleted)

drop dupind seqno

drop if value=="NA"
*(30 observations deleted)


** setting test indicators
gen csf_ind = 1 if strpos(lower(value), "corneal staining") > 1
replace csf_ind = 1 if strpos(lower(value), "pee") > 1
replace csf_ind = 1 if strpos(lower(value), "punctate epithelial") > 1
replace csf_ind=1 if strpos(lower(examname),"sle od cornea")>1 & csf_ind==.
replace csf_ind=1 if strpos(lower(examname),"sle os cornea")>1 & csf_ind==.
codebook studyid if csf_ind==1
*N=92611/n=1,049,360

gen conjstain_ind = 1 if strpos(lower(value), "conjunctival staining") > 1
replace conjstain_ind=1 if strpos(lower(examname), "sle od conjunct") > 1
replace conjstain_ind=1 if strpos(lower(examname), "sle os conjunct") > 1
codebook studyid if conjstain_ind==1
*N=92739/n=1,763,074


gen tbut_ind=1 if strpos(lower(value), "tear breakup") > 1 | strpos(lower(value), "tbut") > 1
replace tbut_ind=1 if strpos(lower(examname), "tbut") > 1| strpos(lower(examname),"tear break") >1
*(288 real changes made)
codebook studyid if tbut_ind==1
*N=4234/n=18293

gen schirmer_ind = 1 if strpos(lower(examname), "schirmers") > 1
*replace schirmer_ind=1 if strpos(lower(value), "sm tube") > 1
codebook studyid if schirmer_ind==1
*N=1265/n=2720



/*
gen tm_ind = 1 if strpos(lower(value), "tear meniscus") > 1
replace tm_ind = 1 if strpos(lower(examname), "tear meniscus") > 1
*(157 real changes made)
*replace tm_ind = 1 if strpos(lower(examname), "meniscus") > 1
codebook studyid if tm_ind==1
*N=211

gen osmo_ind = 1 if strpos(lower(examname), "tear osmolar") > 1
codebook studyid if osmo_ind==1
*N=14


replace test_result = 7 if strpos(lower(panelname), "anti-ssa") > 1

replace test_result = 7 if strpos(lower(panelname), "anti-ssb") > 1
*/


drop if (csf_ind==.& conjstain_ind==. & tbut_ind==.&schirmer_ind==.)
*(5,872,329 observations deleted)

codebook studyid
*N=92,778/n=2,815,534

drop arb_person_id arb_encounter_id smartdataelementepicid abbreviation date

sort studyid visitdate examname
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

save "T18.dta",replace


**# Bookmark #3
**consolidate different exam names

gen namelength=length(examname)
sort studyid visitdate namelength

sort studyid visitdate namelength examname
bys studyid visitdate namelength: gen test=examname[1]

bys studyid visitdate test: gen seqno=_n
bys studyid visitdate test: egen tltest=max(seqno)
label var tltest "total # lab results this visit"

keep if seqno==1
*(1,352,664 observations deleted)
drop seqno

sort studyid visitdate test 
bys studyid visitdate: egen csf=min(csf_ind)
label var csf "presence of CSF results"
bys studyid visitdate: egen conj=min(conjstain_ind)
label var conj "presence of conjunctival staining results"
bys studyid visitdate: egen tbut=min(tbut_ind)
label var tbut "presence of TBUT results"
bys studyid visitdate: egen schirmer=min(schirmer_ind)
label var schirmer "presence of Schirmer's scores"

sort studyid visitdate
bys studyid visitdate: gen seqno=_n
keep if seqno==1

drop seqno test csf_ind conjstain_ind tbut_ind schirmer_ind namelength examname

foreach y of var csf conj tbut schirmer{
	replace `y'=0 if `y'==.
	label val `y' Lyesno
}


sort studyid visitdate 
cd "/Users/liualis/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/Dry eye registry/SecureDriveMirror/Data/Stata/Alison/"

save "T18_small.dta",replace
















** skip extracting lab results for now
** too many descriptive results
/*
local test "csf tbut schirmer conjstain tm osmo"
foreach y of local test{
	gen `y'=value if `y'_ind==1
}
*/














/*
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
log using Exams_Codebook_Single.log, replace
* Display codebook for each individual procedure and its label
display "Each individual test "
levelsof test_result, local(levels)
foreach l in `levels' {
	local lbl : label Ltest_result `l'
    display "Codebook for medication == `l' `lbl' "
    codebook studyid if test_result == `l' 
}
log close
*/

*drop if test_result == .
*(8,766,067 observations deleted)
codebook studyid
* N = 2,091

gen tbut_text = value if strpos(lower(value), "tear breakup time") > 1 | strpos(value, "tbut") > 1
tab tbut_text
gen tbut_value = value if regexm(lower(value), ".*tbut.*")
replace tbut_value = substr(regexs(0), 1, 40) if regexm(lower(tbut_value), "tbut.*(seconds|secs|sec|s,)")
replace tbut_value = "quick" if regexm(lower(tbut_value), "(quick|quitck|quict)(,?) tbut")
replace tbut_value = "reduced" if regexm(lower(tbut_value), "(reduced|reducded)(,?) tbut")
replace tbut_value = "decreased" if regexm(lower(tbut_value), "(decreased|dec|decerased|decresed) tbut")
replace tbut_value = "instant" if regexm(lower(tbut_value), "(instant|instantaneous|immediate) tbut")
replace tbut_value = "fast" if regexm(lower(tbut_value), "(fast|rast) tbut")
replace tbut_value = "low" if regexm(lower(tbut_value), "low tbut")
replace tbut_value = "rapid" if regexm(lower(tbut_value), "rapid tbut")
tab tbut_value

gen corneal_staining_text = value if strpos(lower(value), "corneal staining") > 1
tab corneal_staining_text
gsort studyid visitdate +examname
bys studyid visitdate: gen seqno=_n
label var seqno "Exams per visit"
drop date

keep studyid visitdate test_result tbut_text tbut_value seqno
duplicates drop studyid visitdate test_result, force 

reshape wide test_result tbut_text tbut_value,i(studyid visitdate) j(seqno)

duplicates report studyid visitdate
duplicates drop studyid visitdate, force 

local results_list test_result*
egen test_result = concat(`results_list'), punct(",")
label var test_result "test result indicators"

local tt_list tbut_text*
egen tbut_text = concat(`tt_list'), punct(",")
label var tbut_text "tbut text"

local tv_list tbut_value*
egen tbut_value = concat(`tv_list'), punct(",")
label var tbut_value "tbut values"

order visitdate, after(studyid)

gsort studyid visitdate
bys studyid: gen visitno=_n
label var visitno "visit seqno"

keep studyid visitdate test_result tbut_text tbut_value

cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
save "T18_Exams.dta",replace


















**# ------------- **
** Table 11 & merge
** ------------- ** 

*cd "Z:/OPH/DERegTL/Dry eye Registry/Raw_data"
*import delimited "T11_Notes_20250205.csv", varnames(1) asdouble stringcols(1 2) clear
import delimited "T11_Notes_20250709.csv", varnames(1) asdouble stringcols(1 2) clear
describe

gen studyid=arb_person_id
order studyid, before(arb_person_id)
destring arb_person_id, replace

gen visitdate=date(dateofnote,"19YMD")
label var visitdate "date of visit"
format visitdate %td
order visitdate,before(dateofnote)

gen calyear=year(visitdate)
tab calyear
**# Number of years dropped did not match number in 2016 (did it drop a missing?)
keep if calyear >= 2017 & calyear <= 2024

*quality check to determine if there are any missing visitdates (there were none)
tab calyear, missing


**#Contact lens
** ==============

gen position_cl = strpos(lower(notetext), "contact lens")

gen contact_text = substr(notetext, max(1, position_cl - 25), 25) + substr(regexs(0), 1, 30) if position_cl > 0 & regexm(lower(notetext), "contact lens.*")
replace contact_text = "No/Not" if regexm(lower(contact_text), "(no |not a |non-)contact lens (wear.*|use)")
replace contact_text = "No/Not" if regexm(lower(contact_text), "(do no wear|no history of) contact lens")
replace contact_text = "No/Not" if regexm(lower(contact_text), "contact lens not recomend")
replace contact_text = "Soft Contacts" if regexm(lower(contact_text), "contact lens") & regexm(lower(contact_text), "soft")
replace contact_text = "Use/Wear" if regexm(lower(contact_text), "(uses|wears) contact lens")
replace contact_text = "Use/Wear" if regexm(lower(contact_text), "(does wear|currently wearing| is wearing) contact lens")
replace contact_text = "Use/Wear" if regexm(lower(contact_text), "yes contact lens")

tab contact_text
codebook studyid if contact_text == "Soft Contacts"
*N = 13,298


**#Preservatives
** ==============

gen position_pre = strpos(lower(notetext), "preservatives")

gen preservatives = substr(notetext, max(1, position_cl - 10), 10) + substr(regexs(0), 1, 30) if position_pre > 0 & regexm(lower(notetext), "preservatives")
codebook studyid if preservatives !=""
*N = 284


**# Use of artificial tears
*Look for Artifical tears in text
gen artifical_tears = strpos(lower(notetext), "artifical tears")
replace artifical_tears = 1 if artifical_tears > 0

gen symptoms = (dry == 1) + (gritty == 1) + (burning == 1) + (blurred == 1) + (hazy == 1)

codebook studyid if dry == 1
*37,245
codebook studyid if dry == 1 & (gritty == 1 | burning == 1 | blurred == 1 | hazy == 1)
*24,379
codebook studyid if symptoms !=0
*52,762  




**#Blink rate
** ==============

gen position_br = strpos(lower(notetext), "blink rate")

gen blink_rate = substr(notetext, max(1, position_br - 10), 10) + substr(regexs(0), 1, 30) if position_br > 0 & regexm(lower(notetext), "blink rate")
replace blink_rate = "Low" if regexm(lower(blink _rate), "(low|slow|poor) blink rate")
replace blink_rate = "Abnormal" if regexm(lower(blink _rate), "abnormal blink rate")
replace blink_rate = "Decrease" if regexm(lower(blink _rate), "(decreased|decr|reduced|decrease) blink rate")
replace blink_rate = "Normal" if regexm(lower(blink _rate), "normal blink rate")
tab blink_rate
codebook studyid if blink_rate == "Low" | blink_rate == "abnormal"
*N==55
codebook studyid if blink_rate == "Low" | blink_rate == "abnormal" | blink_rate == "Decrease"
*N=352



/**#Medication Searches in Notes
** =============================

gen cyclosporine = strpos(lower(notetext), "cyclosporine")
replace cyclosporine = 1 if cyclosporine > 0

gen restasis = strpos(lower(notetext), "restasis")
replace restasis = 1 if restasis > 0

gen cequa = strpos(lower(notetext), "cequa")
replace cequa = 1 if cequa > 0

gen xiidra = strpos(lower(notetext), "xiidra")
replace xiidra = 1 if xiidra > 0

gen lifitegrast = strpos(lower(notetext), "lifitegrast")
replace lifitegrast = 1 if lifitegrast > 0
*/


**#Corneal Staining:::
*drop staining_value left_staining right_staining 
gen staining_value = notetext if regexm(lower(notetext), "corneal staining")
gen position = strpos(lower(staining_value), "corneal staining")
replace staining_value = substr(staining_value, max(1, position - 20), 20) + substr(regexs(0), 1, 200) if position > 0 & regexm(lower(notetext), "corneal staining.*")
*8,233 values
drop position

replace staining_value = "No" if regexm(lower(staining_value), "no corneal staining")
*1,195 real changes made
replace staining_value = "No" if regexm(lower(staining_value), "without corneal staining")
*97 changes
replace staining_value = "No" if regexm(lower(staining_value), "no conjunctival or corneal staining")
*4
replace staining_value = "No" if regexm(lower(staining_value), "no conj or corneal staining")
*5
replace staining_value = "No" if regexm(lower(staining_value), "no lg or corneal staining")
*4
replace staining_value = "No" if regexm(lower(staining_value), "no significant corneal staining")
*2

/*
gen staining_abnormal = staining_value
replace staining_abnormal = "No" if regexm(lower(staining_value), "resolved corneal staining")
*520
*If the observation is not indicated as not having staing than it does and therefor is abnormal since normal is zero
replace staining_abnormal = "Yes" if staining_abnormal != "" & staining_abnormal != "No"
*6,400 
*/

*Not mentioed eye or both
replace staining_value = "Present" if regexm(lower(staining_value), " corneal staining at")
replace staining_value = "Present" if regexm(lower(staining_value), " corneal staining, mild")
replace staining_value = "Present" if regexm(lower(staining_value), "mild corneal staining from")
replace staining_value = "Present" if regexm(lower(staining_value), "mild corneal staining in each eye")
replace staining_value = "Present" if regexm(lower(staining_value), "mild corneal staining today")
replace staining_value = "Better" if regexm(lower(staining_value), "corneal staining has improved")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining of both eyes")
replace staining_value = "Better" if regexm(lower(staining_value), "far less central corneal staining")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining in both eyes")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining both eye")
replace staining_value = "Resolved" if regexm(lower(staining_value), "resolved corneal staining")
replace staining_value = "Worse" if regexm(lower(staining_value), "new inferior corneal staining")
replace staining_value = "Better" if regexm(lower(staining_value), "improved corneal staining .* both eyes")
replace staining_value = "Present" if regexm(lower(staining_value), "moderate corneal staining in each eye")
replace staining_value = "Present" if regexm(lower(staining_value), "dense corneal staining,")
replace staining_value = "Present" if regexm(lower(staining_value), "inferior corneal staining")
replace staining_value = "Present" if regexm(lower(staining_value), "diffuse use corneal staining,")
replace staining_value = "Worse" if regexm(lower(staining_value), "worse corneal staining today")
replace staining_value = "Worse" if regexm(lower(staining_value), "worsened corneal staining today")
replace staining_value = "Present" if regexm(lower(staining_value), "trace corneal staining")
replace staining_value = "Worse" if regexm(lower(staining_value), "displays worse corneal staining")
replace staining_value = "Better" if regexm(lower(staining_value), "reduction of corneal staining today")
replace staining_value = "No Change" if regexm(lower(staining_value), "no improvment in corneal staining.")
replace staining_value = "No Change" if regexm(lower(staining_value), "still with corneal staining.")
replace staining_value = "Better" if regexm(lower(staining_value), "improvement in corneal staining.")
replace staining_value = "Better" if regexm(lower(staining_value), "improved corneal staining today")
replace staining_value = "Better" if regexm(lower(staining_value), "good improvement in corneal staining")
replace staining_value = "Better" if regexm(lower(staining_value), "improving corneal staining")
replace staining_value = "No Change" if regexm(lower(staining_value), "no improvement with corneal staining  ")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining in each eye.")
replace staining_value = "Worse" if regexm(lower(staining_value), "corneal staining slightly worse today")
replace staining_value = "Present" if regexm(lower(staining_value), "lots of corneal staining")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining is severe")
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining present,")
replace staining_value = "Present" if regexm(lower(staining_value), "with mild corneal staining")
replace staining_value = "Present" if regexm(lower(staining_value), ", mild corneal staining")
replace staining_value = "Present" if regexm(lower(staining_value), "pt had corneal staining")
replace staining_value = "Better" if regexm(lower(staining_value), "less corneal staining today")
replace staining_value = "Better" if regexm(lower(staining_value), "reduction in corneal staining today")
replace staining_value = "Better" if regexm(lower(staining_value), "reduced tbut and corneal staining")

*Left eye_value
gen left_staining = ""
replace left_staining = staining_value if regexm(lower(staining_value), "left eye")
replace left_staining = "Worse" if regexm(lower(left_staining), "worse corneal staining of the left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "mild corneal staining of the left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "mild left eye")
replace left_staining = regexs(1) if regexm(lower(left_staining), "left eye: ([0-9]+)") 
replace left_staining = "Present" if regexm(lower(left_staining), "abnormal corneal staining left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "corneal staining le")
replace left_staining = "Present" if regexm(lower(left_staining), "corneal staining left eye")
replace left_staining = "Resolved" if regexm(lower(left_staining), "resolution of the corneal staining in the left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "minimal staining of the left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "severe corneal staining left eye")
replace left_staining = "Better" if regexm(lower(left_staining), "resolved staining of the left eye")
replace left_staining = "Better" if regexm(lower(left_staining), "improvment in corneal staining of the left eye")
replace left_staining = "Better" if regexm(lower(left_staining), "improvment in corneal staining of left eye")
replace left_staining = "Better" if regexm(lower(left_staining), "improvment in corneal staining in the left eye")
replace left_staining = "Present" if regexm(lower(left_staining), "corneal staining left eye")

*Right eye_value
gen right_staining = ""
replace right_staining = staining_value if regexm(lower(staining_value), "right eye")
replace right_staining = "Better" if regexm(lower(right_staining), "improved corneal staining of the right eye")
replace right_staining = "Better" if regexm(lower(right_staining), "improved corneal staining in the right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "right eye corneal staining")
replace right_staining = "Present" if regexm(lower(right_staining), "moderate staining of the right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "moderate corneal staining right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "mild corneal staining right eye")
replace right_staining = regexs(1) if regexm(lower(right_staining), "right eye: ([0-9]+)") 
replace right_staining = "Present" if regexm(lower(right_staining), "right eye has corneal staining")
replace right_staining = "No Change" if regexm(lower(right_staining), "no improvement in corneal staining right")
replace right_staining = "No Change" if regexm(lower(right_staining), "no changes in corneal staining of the right eye")
replace right_staining = "Better" if regexm(lower(right_staining), "improvement in corneal staining of the right eye")
replace right_staining = "Better" if regexm(lower(right_staining), "improvement in corneal staining right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "some central corneal staining on the right eye")
replace right_staining = "Worse" if regexm(lower(right_staining), "worsened corneal staining of the right eye")
replace right_staining = "Worse" if regexm(lower(right_staining), "worse corneal staining of the right eye")
replace right_staining = "Worse" if regexm(lower(right_staining), "worse corneal staining right eye")
replace right_staining = "Worse" if regexm(lower(right_staining), "more corneal staining right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "slight corneal staining centrally right eye")
replace right_staining = "Present" if regexm(lower(right_staining), "corneal staining right eye")

*combining left and right
replace staining_value = left_staining if regexm(lower(left_staining), "corneal staining") ///
							& (right_staining =="" |right_staining == left_staining)
replace staining_value = right_staining if regexm(lower(staining_value), "corneal staining") ///
							& (left_staining =="" |left_staining == right_staining)
replace staining_value = "Pres_Diff" if left_staining != right_staining & left_staining != ""

*replace all remaining with present if they have not otherwise been assigned
replace staining_value = "Present" if regexm(lower(staining_value), "corneal staining")

tab staining_value





**#Tear Break-Up Time (normal > 10 sec)
** ============

gen tbut_value = "" 
* Find entries that match any of the patterns you're looking for
replace tbut_value = notetext if regexm(lower(notetext), "tbut|tear breakup time|tear break up time")

* Find the position of the matched string
gen position = . 
replace position = strpos(lower(tbut_value), "tbut") if regexm(lower(tbut_value), "tbut")
replace position = strpos(lower(tbut_value), "tear breakup time") if regexm(lower(tbut_value), "tear breakup time")
replace position = strpos(lower(tbut_value), "tear break up time") if regexm(lower(tbut_value), "tear break up time")

* Extract the substring before and after the matched text for a cleaner value
replace tbut_value = substr(tbut_value, max(1, position - 10), 80) + substr(tbut_value, position, 130) if position > 0

* Drop the position variable now that we're done
drop position

codebook studyid if tbut_value != ""
*N = 5,260

sort tbut_value
tab tbut_value

*drop no_numeric_tbut numeric_tbut
gen no_numeric_tbut = tbut_value if !regexm(tbut_value, "([0-9]+)")
tab no_numeric_tbut
gen numeric_tbut = tbut_value if regexm(tbut_value, "([0-9]+)")
tab numeric_tbut 
*codebook studyid if no_numeric_tbut != "" & numeric_tbut != ""

**# TBUT Values Right Eye
*drop right_tbut
gen right_tbut = tbut_value if regexm(lower(numeric_tbut), "tbut.*(right|re:|re )")
tab right_tbut
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut  right eye: ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut right eye: ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut   right eye:  ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:  right eye: ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "([0-9]+)s right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:     right eye: ([0-9]+) ")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  ([0-9]+) ")
replace right_tbut = "0" if regexm(lower(right_tbut), "tbut:    right:  instant")
replace right_tbut = "0" if regexm(lower(right_tbut), "tbut immediate in the right")
replace right_tbut = "0" if regexm(lower(right_tbut), "tbut: immediate right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:   ([0-9]+) ")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  >([0-9]+) ")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:   right: ([0-9]+)sec")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+),([0-9]+),([0-9]+)")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+), ([0-9]+)+, ([0-9]+)")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(right_tbut), "tbut    right eye: ([0-9]+), ([0-9]+), ([0-9]+)")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(right_tbut), "tbut:  right: ([0-9]+),([0-9]+),([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(right_tbut), "tbut:    right:            ([0-9]+), ([0-9]+), ([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)sec ")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+),([0-9]+) ")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  > ([0-9]+)sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut   right eye: ([0-9]+)s")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut right ([0-9]+)-([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut ([0-9]+)-([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut: ([0-9]+) seconds right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut ~([0-9]+)sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:     right:  ~([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+).([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut >([0-9]+) seconds")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut is less than ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut <([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut: ([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut , ([0-9]+)sec ou")
replace right_tbut = regexs(1) if regexm(right_tbut, "TBUT now ([0-9]+)\+")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut   right eye: ([0-9]+) secs")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut < ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut ([0-9]+).")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut today: ([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  <([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right: ([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+),([0-9]+), ([0-9]+) ")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3) if ///
					regexm(lower(right_tbut), "tbut:  right: ([0-9]+), ([0-9]+), ([0-9]+)")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)/([0-9]+)/([0-9]+) ")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3) if ///
					regexm(lower(right_tbut), "tbut:    right:  >([0-9]+), >([0-9]+), >([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)\+,([0-9]+)\+,([0-9]+)\+")
replace right_tbut = regexs(1) + "," + regexs(2) if regexm(lower(right_tbut), "tbut ~([0-9]+)-([0-9]+) sec")
replace right_tbut = "0" if regexm(lower(right_tbut), "tbut  right eye: instantaneous")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "([0-9]+)sec tbut right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut has increased to ~([0-9]+) sec")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+).*, ([0-9]+)")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+),([0-9]+)\+ sec")
replace right_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)\-([0-9]+)sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)\+ sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  ([0-9]+)\+sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut = ([0-9]+) seconds right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:  >([0-9]+)sec ")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "([0-9]+) second tbut")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut       right left      ([0-9]+) seconds")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut      right left     ([0-9]+)seconds")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:                             right eye: ([0-9]+) seconds")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "([0-9]+)s tbut with")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "([0-9]+) seconds in the right eye")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut in the right eye is ([0-9]+) seconds")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:  right ([0-9]+) sec")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right: ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:  right:  ([0-9]+)")
replace right_tbut = regexs(1) if regexm(lower(right_tbut), "tbut:    right:            ([0-9]+)\+ x 3")

replace right_tbut = "quick" if regexm(lower(right_tbut), ", quick tbut")
replace right_tbut = "rapid" if regexm(lower(right_tbut), "  rapid tbut ")
replace right_tbut = "reduced" if regexm(lower(right_tbut), "reduced tbut")
replace right_tbut = "reduced" if regexm(lower(right_tbut), "mild tbut reduction")
replace right_tbut = "reduced" if regexm(lower(right_tbut), "tbut is still quite reduced left eye>right eye")
replace right_tbut = "improve" if regexm(lower(right_tbut), "vement in tbut of both eyes")
replace right_tbut = "irregular" if regexm(lower(right_tbut), "tbut:    right:  irregular")
replace right_tbut = "quick" if regexm(lower(right_tbut), "tbut quick today")
replace right_tbut = "fast" if regexm(lower(right_tbut), "fast tbut ")
replace right_tbut = "rapid" if regexm(lower(right_tbut), "rapid tbut ")
replace right_tbut = "rapid" if regexm(lower(right_tbut), "rapid tbut,")
replace right_tbut = "decreased" if regexm(lower(right_tbut), "decreased tbut")
replace right_tbut = "improved" if regexm(lower(right_tbut), " improved tbut on exam today")
replace right_tbut = "variable" if regexm(lower(right_tbut), " tbut:    right:  highly variable")
replace right_tbut = "poor" if regexm(lower(right_tbut), ", poor tbut")	
				
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:  unable")
replace right_tbut = "na" if regexm(right_tbut, "TBUT  Right eye:   Left")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:  -   ")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:  NA")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:  N/A")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    No data")
replace right_tbut = "na" if regexm(right_tbut, "working  TBUT:      Schirmer's")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:                    Left:")
replace right_tbut = "na" if regexm(right_tbut, "MGYLS and TBUT")
replace right_tbut = "na" if regexm(right_tbut, "Left: TBUT.")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:                  Left:")
replace right_tbut = "na" if regexm(right_tbut, "TBUT:    Right:                     Left: ")

*Generate averages for numbered values
gen num3_right = regexs(3) if regexm(right_tbut, "([0-9]+),([0-9]+),([0-9]+)")
gen num2_right = regexs(2) if regexm(right_tbut, "([0-9]+),([0-9]+)")
gen num1_right = regexs(1) if regexm(right_tbut, "([0-9]+)")
destring num3_right num2_right num1_right, replace
gen valid_avg_right = (num1_right + num2_right + num3_right) / 3 if num3_right!=. & num2_right!=. & num1_right !=.
replace valid_avg_right = (num1_right + num2_right) / 2 if num3_right==. & num2_right!=. & num1_right !=.
replace valid_avg_right = num1_right if num3_right==. & num2_right==. & num1_right !=.
replace right_tbut = "Normal" if valid_avg_right >= 10 & valid_avg_right != .
replace right_tbut = "Mild" if valid_avg_right <10 & valid_avg_right >=5
replace right_tbut = "Moderate" if valid_avg_right <5 & valid_avg_right >=2
replace right_tbut = "Severe" if valid_avg_right <2 & valid_avg_right != .
tab right_tbut
drop num3_right num2_right num1_right 
*at the end of this I have right_tbut scores that I will need to compare to left and valid_avg_right for numeric values

**# TBUT Value Left eye
*not done yet
*drop left_tbut
gen left_tbut = tbut_value if regexm(lower(numeric_tbut), "tbut.*left")
tab left_tbut
*replace left_tbut = regexs(1) if regexm(lower(no_numeric_tbut), "rapid[ \t]*(tbut|tear break[ -]?up time)")

replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left[ \t]*([0-9]+)[ \t]*sec")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left eye:[ \t]*([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ \t]*s[ \t]*left")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ \t]*secs[ \t]*left eye")
replace left_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(left_tbut), "left[ :]?[ \t]*([0-9]+)[+]?,([0-9]+)[+]?,([0-9]+)")
replace left_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(left_tbut), "left:[ \t]*([0-9]+),([0-9]+) ([0-9]+) sec")
replace left_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(left_tbut), "left:[ \t]*([0-9]+),[ \t]*([0-9]+),[ \t]*([0-9]+)")
replace left_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(left_tbut), "left eye:[ \t]*([0-9]+),[ \t]*([0-9]+),[ \t]*([0-9]+)")
replace left_tbut = regexs(1) + "," + regexs(2) + "," + regexs(3)  if ///
					regexm(lower(left_tbut), "left:[ \t]*([0-9]+)/[ \t]*([0-9]+)/[ \t]*([0-9]+)")
replace left_tbut = "0," + regexs(1) + "," + regexs(2)  if ///
					regexm(lower(left_tbut), "left:[ \t]*inst,[ \t]*([0-9]+),[ \t]*([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) + "," + regexs(2)  if ///
					regexm(lower(left_tbut), "left:[ \t]*([0-9]+),([0-9]+)[ +]?[ \t]*s")
replace left_tbut = regexs(1) + "," + regexs(2)  if ///
					regexm(lower(left_tbut), "left:[ \t]*([0-9]+)\-([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) + "," + regexs(2)  if ///
					regexm(lower(left_tbut), "left:[ \t]*highly[ \t]*variable[ \t]*([0-9]+)\-([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) seconds in the left")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) seconds left")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ +]?[ \t]*seconds left eye")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ +]?[ \t]*in the left eye")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*<([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*([0-9]+)\+[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*>[ \t]*([0-9]+)[ \t]*")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*~([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left[ \t]*([0-9]+)\+s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*([0-9]+\.[0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "left:[ \t]*greater than ([0-9]+) s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ \t]*on[ \t]*left")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ \t]*sec[ \t]*on[ \t]*left")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)[ \t]*on[ \t]*the[ \t]*left")

replace left_tbut = "0" if regexm(lower(left_tbut), "left:[ \t]*instant")
replace left_tbut = "0" if regexm(lower(left_tbut), "left eye:[ \t]*instant")
replace left_tbut = "0" if regexm(lower(left_tbut), "left:[ \t]*instand")
replace left_tbut = "0" if regexm(lower(left_tbut), "immediate .*left eye")

replace left_tbut = "10" if regexm(lower(left_tbut), "tbut[ \t]*<[ \t]*([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(left_tbut), "tbut[ \t]*([0-9]+)\-([0-9]+)[ \t]*s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) second tbut")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)s tbut")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut ([0-9]+) sec")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) sec both eyes")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) seconds in each eye")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+) seconds diffusely both eye")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut[ \t]*<<[ \t]*([0-9]+)[ \t]*sec")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut[ \t]*~([0-9]+)[ \t]*sec")
replace left_tbut = regexs(1) + "," + regexs(2) if ///
					regexm(lower(left_tbut), "tbut[ \t]*~([0-9]+)\-([0-9]+)[ \t]*s")
replace left_tbut = regexs(2) if regexm(lower(left_tbut), "tbut ([0-9]+)s/([0-9]+)s")
replace left_tbut = regexs(1) + "," + regexs(2)  if ///
					regexm(lower(left_tbut), "tbut approaching ([0-9]+)\-([0-9]+)")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut is[ \t]*~([0-9]+)s")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "([0-9]+)sec ou")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut less than ([0-9]+) sec")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut >([0-9]+) sec")
replace left_tbut = regexs(1) if regexm(lower(left_tbut), "tbut: ([0-9]+)s")

replace left_tbut = "irregular" if regexm(lower(left_tbut), "left:[ \t]*irregular")
replace left_tbut = "decreased" if regexm(lower(left_tbut), "dec tbut left eye")
replace left_tbut = "normal" if regexm(lower(left_tbut), "tbut normal both eyes")
replace left_tbut = "reduced" if regexm(lower(left_tbut), "reduced tbut")
replace left_tbut = "reduced" if regexm(lower(left_tbut), "tbut reduction left")
replace left_tbut = "reduced" if regexm(lower(left_tbut), "reduced in both eyes")
replace left_tbut = "reduced" if regexm(lower(left_tbut), "tbut is still quite reduced")
replace left_tbut = "rapid" if regexm(lower(left_tbut), "rapid tbut")
replace left_tbut = "fast" if regexm(lower(left_tbut), "fast tbut left")
replace left_tbut = "short" if regexm(lower(left_tbut), "tbut is quite short")
replace left_tbut = "improved" if regexm(lower(left_tbut), "improved tbut")
replace left_tbut = "decreased" if regexm(lower(left_tbut), "decreased tbut")
replace left_tbut = "quick" if regexm(lower(left_tbut), "quick tbut")
replace left_tbut = "poor" if regexm(lower(left_tbut), "poor tbut")
replace left_tbut = "fast" if regexm(lower(left_tbut), "fast tbut")

*unsure terms but putting something in for now
replace left_tbut = "" if regexm(lower(left_tbut), "ction and tbut")
replace left_tbut = "reasonable" if regexm(lower(left_tbut), "easonable tbut")
replace left_tbut = "deminished" if regexm(lower(left_tbut), "iminished tbut")

replace left_tbut = "na" if regexm(lower(left_tbut), "tbut:[ \t]*no data ")
replace left_tbut = "na" if regexm(lower(left_tbut), "tbut:[ \t]*schirmer")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*n/a")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*na")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*unable")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*schirmer")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*osd")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*question")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*not performed")
replace left_tbut = "na" if regexm(lower(left_tbut), "left:[ \t]*\-")
replace left_tbut = "na" if regexm(lower(left_tbut), "left eye:[ \t]*pee")

*Generate averages for numbered values
gen num3_left = regexs(3) if regexm(left_tbut, "([0-9]+),([0-9]+),([0-9]+)")
gen num2_left = regexs(2) if regexm(left_tbut, "([0-9]+),([0-9]+)")
gen num1_left = regexs(1) if regexm(left_tbut, "([0-9]+)")
destring num3_left num2_left num1_left, replace
gen valid_avg_left = (num1_left + num2_left + num3_left) / 3 if num3_left!=. & num2_left!=. & num1_left !=.
replace valid_avg_left = (num1_left + num2_left) / 2 if num3_left==. & num2_left!=. & num1_left !=.
replace valid_avg_left = num1_left if num3_left==. & num2_left==. & num1_left !=.
replace left_tbut = "Normal" if valid_avg_left >= 10 & valid_avg_left != .
replace left_tbut = "Mild" if valid_avg_left <10 & valid_avg_left >=5
replace left_tbut = "Moderate" if valid_avg_left <5 & valid_avg_left >=2
replace left_tbut = "Severe" if valid_avg_left <2 & valid_avg_left != .
tab left_tbut
drop num3_left num2_left num1_left
*left_tbut contains all the values for left_tbut numeric & characters
*valid_avg_left contains only the numeric values for tbut left eye 

*compare left and right sides
replace numeric_tbut = right_tbut if right_tbut != "" & left_tbut == ""
replace numeric_tbut = left_tbut if right_tbut == "" & left_tbut != ""
replace numeric_tbut = left_tbut if right_tbut == left_tbut & right_tbut != ""
replace numeric_tbut = "not same" if right_tbut != left_tbut & right_tbut != "" & left_tbut != ""

*generate a varaible to keep that will only contain the numeric values of the lower score eye
gen numeric_values_tbut = .
replace numeric_values_tbut = valid_avg_right if valid_avg_right !=.
replace numeric_values_tbut = valid_avg_left if numeric_values_tbut == .
replace numeric_values_tbut = valid_avg_left if valid_avg_left < valid_avg_right

**# Bookmark #3
*extract the values from numeric 
tab numeric_tbut
replace numeric_tbut = regexs(1) if regexm(lower(numeric_tbut), "tbut[ \t]*([0-9]+)[ \t]*s")
replace numeric_tbut = regexs(1) if regexm(lower(numeric_tbut), "tbut.*([0-9]+)[ \t]*sec")
replace numeric_tbut = regexs(1) if regexm(lower(numeric_tbut), "tbut.*([0-9]+)[ \t]*.")
replace numeric_tbut = regexs(1) if regexm(lower(numeric_tbut), "([0-9]+)[ \t]*s[ \t]*tbut")
replace numeric_tbut = regexs(1) + "," + regexs(2)  if ///
					regexm(lower(numeric_tbut), "tbut[ :]?[ \t]*([0-9]+)\-([0-9]+)")
					
					

					
					
					
					
					
					
					
					
					
					
					
					
**#Export TBUT data for manual verification
** =========================================					
					
tab no_numeric_tbut
preserve 
keep if left_tbut != "" & regexm(lower(left_tbut), "tbut")
keep left_tbut
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
export delimited using "left_tbut.csv", replace
restore

codebook studyid if numeric_tbut !="" | no_numeric_tbut !=""
*5260 

preserve 
keep if no_numeric_tbut != ""
sort no_numeric_tbut
keep in 1/200
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
export delimited using "no_numeric_200.csv", replace
restore




**# SCHIRMER TEST:::
gen schirmer = notetext if regexm(lower(notetext), "schirmer")
gen position = strpos(lower(schirmer), "schirmer")
replace schirmer = substr(schirmer, max(1, position - 20), 50) + substr(regexs(0), 1, 200) if position > 0 & regexm(lower(notetext), "schirmer.*")
replace schirmer = substr(regexs(0), 1, 50) if regexm(lower(notetext), "  schirmer.*")
drop position

gen schirmer_value_high = .

*determine if there is an abnormal value for right eye be >= 10
gen schirmer_right = schirmer
replace schirmer_right = regexs(1) if regexm(schirmer_right, "right: ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "right:  ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "right ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "right eye: ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "([0-9]+) right eye")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "re:([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "re: ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "re:  ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "re ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "r ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "od: ([0-9]+)")
replace schirmer_right = regexs(1) if regexm(schirmer_right, "od ([0-9]+)")
tab schirmer_right

replace schirmer_right = "" if regexm(schirmer_right, "schirmer")
destring schirmer_right, replace

replace schirmer_value_high = schirmer_right 

replace schirmer_right = 0 if schirmer_right <5 & schirmer_right != .
replace schirmer_right = 1 if schirmer_right >=5 & schirmer_right <10 & schirmer_right != .
replace schirmer_right = 2 if schirmer_right >=10 & schirmer_right <15 & schirmer_right != .
replace schirmer_right = 3 if schirmer_right >=15 & schirmer_right != .

*determine if there is an abnormal value for left eye be >= 10
gen schirmer_left = schirmer
replace schirmer_left = regexs(1) if regexm(schirmer_left, "left: ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "left:  ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "left ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "le:([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "le: ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "le:  ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "le ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "l ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "os: ([0-9]+)")
replace schirmer_left = regexs(1) if regexm(schirmer_left, "os ([0-9]+)")
tab schirmer_left

replace schirmer_left = "" if regexm(schirmer_left, "schirmer")
destring schirmer_left, replace

replace schirmer_value_high = schirmer_left if schirmer_value_high == .
replace schirmer_value_high = schirmer_right if schirmer_right > schirmer_value_high

replace schirmer_left = 0 if schirmer_left <5 & schirmer_left != .
replace schirmer_left = 1 if schirmer_left >=5 & schirmer_left <10 & schirmer_left != .
replace schirmer_left = 2 if schirmer_left >=10 & schirmer_left <15 & schirmer_left != .
replace schirmer_left = 3 if schirmer_left >=15 & schirmer_left != .

*Replace if both left and right match
replace schirmer = "Normal" if schirmer_left == 0 & schirmer_right == 0
replace schirmer = "Possible" if schirmer_left == 1 & schirmer_right == 1
replace schirmer = "Moderate" if schirmer_left == 2 & schirmer_right == 2
replace schirmer = "Extreme" if schirmer_left == 3 & schirmer_right == 3

*Replace if right is missing then left value is lead
replace schirmer = "Normal" if schirmer_left == 0 & schirmer_right == .
replace schirmer = "Possible" if schirmer_left == 1 & schirmer_right == .
replace schirmer = "Moderate" if schirmer_left == 2 & schirmer_right == .
replace schirmer = "Extreme" if schirmer_left == 3 & schirmer_right == .

*Replace if left is missing then right value it lead
replace schirmer = "Normal" if schirmer_left == . & schirmer_right == 0
replace schirmer = "Possible" if schirmer_left == . & schirmer_right == 1
replace schirmer = "Moderate" if schirmer_left == . & schirmer_right == 2
replace schirmer = "Extreme" if schirmer_left == . & schirmer_right == 3

*Replace if left is missing then right value it lead
replace schirmer = "Possible" if schirmer_left != 1 & schirmer_right == 1
replace schirmer = "Moderate" if schirmer_left != 2 & schirmer_right == 2
replace schirmer = "Extreme" if schirmer_left != 3 & schirmer_right == 3

*Extract remaining values for those with no left/right
gen schirmer_remaining = schirmer 
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "([0-9]+) mm")
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "([0-9]+)mm")
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "schirmers: ([0-9]+)")
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "schirmers test = ([0-9]+)")
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "([0-9]+) ([0-9]+)")
replace schirmer_remaining = regexs(1) if regexm(schirmer_remaining, "r-([0-9]+)")

replace schirmer_remaining = "" if regexm(schirmer_remaining, "schirmer|Normal|Possible|Moderate|Extreme")
destring schirmer_remaining, replace

replace schirmer_value_high = schirmer_remaining if schirmer_value_high == .

replace schirmer_remaining = 0 if schirmer_remaining <5 & schirmer_remaining != .
replace schirmer_remaining = 1 if schirmer_remaining >=5 & schirmer_remaining <10 & schirmer_remaining != .
replace schirmer_remaining = 2 if schirmer_remaining >=10 & schirmer_remaining <15 & schirmer_remaining != .
replace schirmer_remaining = 3 if schirmer_remaining >=15 & schirmer_remaining != .

replace schirmer = "Normal" if schirmer_remaining == 0 & schirmer_remaining != .
replace schirmer = "Possible" if schirmer_remaining == 1 & schirmer_remaining != .
replace schirmer = "Moderate" if schirmer_remaining == 2 & schirmer_remaining != .
replace schirmer = "Extreme" if schirmer_remaining == 3 & schirmer_remaining != .

replace schirmer = "Possible" if regexm(lower(schirmer), "low schirmer") 
replace schirmer = "Possible" if regexm(lower(schirmer), "possible sjo") 
replace schirmer = "Normal" if regexm(lower(schirmer), "normal schirmer.*")
replace schirmer = "Normal" if regexm(lower(schirmer), "low schirmer.*") 
replace schirmer = "Normal" if regexm(lower(schirmer), "schirmer i of zero") 
replace schirmer = "Normal" if regexm(lower(schirmer), "schirmer's normal") 

tab schirmer

replace schirmer = "" if regexm(schirmer, "schirmer")

drop schirmer_left schirmer_remaining schirmer_right
*************
gen meibum = strpos(lower(notetext), "meibum")
replace meibum = 1 if meibum > 0

gen tear_meniscus = strpos(lower(notetext), "tear meniscus height")
replace tear_meniscus = 1 if tear_meniscus > 0
gen tear_meniscus_value = notetext if regexm(lower(notetext), "tear meniscus height")
gen position = strpos(lower(tear_meniscus_value), "tear meniscus height")
replace tear_meniscus_value = substr(tear_meniscus_value, max(1, position - 30), 30) + "tear meniscus" if position > 0
tab tear_meniscus_value
drop position


**# Meiboian gland
gen meibography = strpos(lower(notetext), "meibography")
replace meibography = 1 if meibography > 0

**# Tear OSMOLARITY (Table 8 or Table 18) 
gen osmolarity_text = substr(regexs(0), 1, 100) if regexm(lower(notetext), "osmolarity.*")
gen osmo_value_high = .

*right osmolarity values extraction
gen right_osmo = substr(regexs(0), 1, 30) if regexm(lower(osmolarity_text), "(right|re|od).*(mosm/l|mosl|left|os|le)")
replace right_osmo = regexs(1) if regexm(right_osmo, "([0-9]+).*(mosml|mosm/l)")
replace right_osmo = regexs(1) if regexm(right_osmo, "([0-9]+) os")

replace right_osmo = "" if !regexm(right_osmo, "^[0-9]+$")
destring right_osmo , replace

replace osmo_value_high = right_osmo

*left osmolarity values extraction
gen left_osmo = substr(regexs(0), 1, 30) if regexm(lower(osmolarity_text), "(left|le|os).*(mosm/l|mosl|left|os|le)")
replace left_osmo = regexs(1) if regexm(left_osmo, "([0-9]+).*(mosml|mosm/l|mos)")

replace left_osmo = "" if !regexm(left_osmo, "^[0-9]+$")
destring left_osmo , replace

replace osmo_value_high = left_osmo if osmo_value_high == .
replace osmo_value_high = left_osmo if left_osmo > osmo_value_high

replace osmo_value_high = 326 if regexm(osmolarity_text, "326/")
replace osmo_value_high = 315 if regexm(osmolarity_text, "re 315")

drop osmolarity_text right_osmo left_osmo
****END OSMOLARITY



**# CONJUNCTIVAL STAINING
*drop conjunctival
gen conjunctival = notetext if regexm(lower(notetext), "conjunctival staining")
gen position = strpos(lower(conjunctival), "conjunctival")
replace conjunctival = substr(conjunctival, max(1, position - 20), 50) + substr(regexs(0), 1, 200) if position > 0 & regexm(lower(notetext), "conjunctival staining.*")
drop position

replace conjunctival = "No" if regexm(lower(conjunctival), "no conjunctival staining")
replace conjunctival = "No" if regexm(lower(conjunctival), "no corneal or conjunctival staining")
replace conjunctival = "No" if regexm(lower(conjunctival), "no corneal nor conjunctival staining")
replace conjunctival = "No" if regexm(lower(conjunctival), "no lid margin or conjunctival staining")
replace conjunctival = "Present" if regexm(lower(conjunctival), "found to have conjunctival staining")
replace conjunctival = "Present" if regexm(lower(conjunctival), "conjunctival staining present")
replace conjunctival = "Present" if regexm(lower(conjunctival), ", corneal and conjunctival staining")
replace conjunctival = "Present" if regexm(lower(conjunctival), "conjunctival staining on")
replace conjunctival = "Present" if regexm(lower(conjunctival), "likely conjunctival staining")
replace conjunctival = "Present" if regexm(lower(conjunctival), "trace conjunctival staining")
replace conjunctival = "Better" if regexm(lower(conjunctival), "esolved corneal and conjunctival staining")
replace conjunctival = "Better" if regexm(lower(conjunctival), "resolution of conjunctival staining")
replace conjunctival = "Present(term) " if regexm(lower(conjunctival), "conjunctival staining")

tab conjunctival

preserve 
keep conjunctival
cd "Z:\OPH\DERegTL\Dry eye registry\Data\Stata\New - 20250205"
export delimited using "conjunctival_staining_text.csv", replace
restore
**** END CONJUNCTIVAL


** ================================
**# patient-reported symptoms
** ================================

gen dry = strpos(lower(notetext), "dry")
replace dry = 1 if dry > 0
gen dry_surround = substr(regexs(0), 1, 10) if regexm(lower(notetext), "dry.*")
gen symptoms_note = strpos(lower(notetext), "symptoms")
gen chief = strpos(lower(notetext), "complaint")
gen comments = strpos(lower(notetext), "comments")
gen reports = strpos(lower(notetext), "reports")

tab dry_surround
drop dry_surround

gen gritty = strpos(lower(notetext), "gritty")
replace gritty = strpos(lower(notetext), "grittiness") if gritty == 0
replace gritty = 1 if gritty > 0

gen burning = strpos(lower(notetext), "burning")
replace burning = 1 if burning > 0

gen blurred = strpos(lower(notetext), "blurred")
replace blurred = 1 if blurred > 0

gen hazy = strpos(lower(notetext), "hazy")
replace hazy = 1 if hazy > 0



*look for test names in text
**#OSDI:::

gen osdi_value = notetext if regexm(lower(notetext), "osdi")
gen position = strpos(lower(osdi_value), "osdi")
replace osdi_value = substr(osdi_value, max(1, position - 10), 10) + substr(regexs(0), 1, 20) if position > 0 & regexm(lower(notetext), "osdi.*")
drop position

replace osdi_value = regexs(1) if regexm(lower(osdi_value), "osdi: ([0-9]+)  ")
replace osdi_value = regexs(1)+regexs(2) if regexm(lower(osdi_value), "osdi.*([0-9])([0-9])/100")
replace osdi_value = regexs(1) if regexm(lower(osdi_value), "osdi score = ([0-9]+)")
replace osdi_value = regexs(1) if regexm(lower(osdi_value), "osdi score: ([0-9]+)")

replace osdi_value = "" if regexm(lower(osdi_value), "osdi.*")
destring osdi_value, replace

gen osdi = ""
replace osdi = "Normal" if osdi_value < 13 & osdi_value != .
replace osdi = "Mild" if osdi_value >= 13 & osdi_value <= 22 & osdi_value !=.
replace osdi = "Moderate" if osdi_value >= 23 & osdi_value <= 32 & osdi_value !=.
replace osdi = "Severe" if osdi_value >= 33 & osdi_value <= 100 & osdi_value !=.

tab osdi_value

**#SPEED:::
gen speed_value = substr(regexs(0), 1, 50) if regexm(lower(notetext), "speed.*")
tab speed_value
replace speed_value = regexs(1)+regexs(2)+regexs(3) if ///
			regexm(lower(speed_value), "speed.*([0-9])([0-9])([0-9])/28")
replace speed_value = regexs(1)+regexs(2) if regexm(lower(speed_value), "speed.*([0-9])([0-9])/28")
replace speed_value = regexs(1) if regexm(lower(speed_value), "speed.*([0-9])/28")
replace speed_value = regexs(1) if regexm(lower(speed_value), "speed: ([0-9]+)  deq")
replace speed_value = regexs(1) if regexm(lower(speed_value), "speed:  ([0-9]+)  deq")
replace speed_value = regexs(1) if regexm(lower(speed_value), "speed score improved from 22 to ([0-9])")
replace speed_value = regexs(1) if regexm(lower(speed_value), "speed score has decreased from 20 to ([0-9])")

replace speed_value = "" if regexm(lower(speed_value), "speed.*")
destring speed_value, replace

gen speed = ""
replace speed = "Normal" if speed_value < 4
replace speed = "Mild" if speed_value >= 4 & speed_value <= 8
replace speed = "Moderate" if speed_value >= 9 & speed_value <= 12
replace speed = "Severe" if speed_value >= 13 & speed_value != .


**#VAS:::

gen vas_value = substr(regexs(0), 1, 20) if regexm(lower(notetext), "vas.*")
replace vas_value = regexs(1)+regexs(2) if regexm(lower(vas_value), "vas.*([0-9])([0-9])/10 ")
replace vas_value = regexs(1) if regexm(lower(vas_value), "vas.*([0-9])/10 ")

replace vas_value = "" if regexm(vas_value, "vas.*")
destring vas_value, replace

tab vas_value


*****END VALUE EXTRACTIONS 
duplicates drop studyid visitdate, force

drop notetext timeofnote dateofnote arb_encounter_id noteepicid
drop dry gritty burning blurred hazy 

* I want to keep all observations regardless of DED or not
*drop if corneal_staining == 0 & tbut == 0 & meibum == 0 & conjunctival_staining == 0 & tear_meniscus == 0 & meibography == 0 & symptoms == 0 & OSDI == 0 & osmolarity ==0 & lifitegrast == 0 & xiidra == 0 & cequa == 0 & restasis == 0 & cyclosporine == 0 & SPEED == 0 & VAS == 0

gsort studyid visitdate 
bys studyid visitdate: gen seqno=_n
label var seqno "Exams per visit"

gsort studyid visitdate
reshape wide symptoms notetype noteprovider staining_value osmo_value_high osdi_value speed_value schirmer vas_value,i(studyid visitdate) j(seqno)

local prefixes "symptoms notetype noteprovider osmos_value_high staining_value osdi_value speed_value schirmer vas_value"

* Loop over each prefix
foreach prefix of local prefixes {
    * Create the list of variables for the current prefix
    local var_list `prefix'*

    * Concatenate the variables into a single \New - 20250205 variable
    egen `prefix' = concat(`var_list'), punct(",")
}

keep studyid visitdate cyclosporine restasis cequa xiidra lifitegrast staining_value conjunctival schirmer schirmer_value_high osmo_value_high osmolarity osdi osdi_value vas_value speed speed_value symptoms artifical_tears meibum meibography no_numeric_tbut numeric_tbut

cd "Z:/OPH/DERegTL/Dry eye Registry/Data/Stata/New - 20250205"
save "T11_Notes.dta",replace
