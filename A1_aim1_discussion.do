**
**
** for Discussion: additional "possible" dry eye patients identified by
**					(1) other disease ICD
** 					(2) symptom ICD
**					(3) other CPT
**					



**#aim1.do
**line 1294


drop if cohort2==0


drop if visitdate==.
*(38,565 observations deleted)


codebook studyid
*N=131,268/n=419259
*N=92789/n=536929

sort studyid visitdate
bys studyid: egen temp=min(visitdate)
replace index_date=temp if index_date==.
format index_date %td

replace entry_yr=year(index_date) if entry_yr==.
replace yr2017=(entry_yr==2017)




local test "csf conj tbut osmo schirmer"
foreach y of var schirmer {
	tab tp yr2017 if `y'==1&cohort3==0,m
	
	forval z=0/4{
		codebook studyid if `y'==1 & tp==`z'&cohort3==0
	}
	
}

* denominators by year
forval z=0/4{
		codebook studyid if tp==`z'&cohort3==0
}
