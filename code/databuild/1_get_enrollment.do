* University of Houston
* Eva Loaeza
* Date: 11/08/2021

** INPUTS:
* Historical Finance Data Base (IndFin) only for independent School districts
* https://www2.census.gov/programs-surveys/gov-finances/datasets/historical/
* Period: 1967-1991

* elsec school district finance data fy 1987-91.zip
* https://www2.census.gov/programs-surveys/gov-finances/datasets/historical/
* Period: 1987-1991

* Data for All Data Items Tables from the Public Education Finances report
* Period: 1993-2019

********************************************************************************
clear
set more off
*ssc install mdesc
gl rawdata "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/Raw"
gl temp "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/temp"
gl logs "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/logs"


********************************************************************************

log using "$logs/get_enrollment", replace

********************************************************************************
** 1. Import enrollment from 1964-1991
********************************************************************************
import sas using $rawdata/enrollment/67-91/indfin67-91.sas7bdat, case(lower)
rename year4 year
* For SD in states<10, the id variable is 8 characters long, we need to add a leading zero
gen length_ID = strlen(id)
tab length_ID // ID is 9 character long
order year id, first
drop length_ID
duplicates report year id
* Form id_govs generate state, county, unit identifier
*gen govs_state= substr(id, 1, 2) // 2 digit state code
*gen govs_type = substr(id, 3, 1)  // 1 digit type of government
*gen govs_cnty = substr(id, 4, 3) // 3 digit county code
gen id_school = substr(id, 7, 3) // 3 digit government unit CODE
ren (id state type county) (id_govs govs_state govs_type govs_cnty)
order year id_govs govs_state govs_type govs_cnty id_school
sort year id_govs
unique id_govs  // 17,236 SD, only type 5
unique id_govs if year>1986 // 14,944 SD, only type 5
keep year id_govs govs_state govs_type govs_cnty id_school name yrdata yrpop schlvcod pop
drop if year<1979
rename (pop schlvcod) (enrollment schlev)
* 11 variables
save $temp/enrollment_ind_70_91, replace

********************************************************************************
** 2. Import enrollment from 1992-2019
********************************************************************************
gl data92_93 "$rawdata/enrollment/92-19/All_Data_Items/1992_1993"

*** Set your directory (where the xls files are)
*cd "$data9293"
clear
cd "$data92_93"

*** 1) Define xls files to include
local filepath = "`c(pwd)'" // Save path to current folder in a local
di "`c(pwd)'" // Display path to current folder
local files : dir "`filepath'" files "*.xls" // Save name of all files in folder ending with .xls in a local
di `"`files'"' // Display list of files to import data from

*** 2) Loop over all files to import and append each file
tempfile master // Generate temporary save file to store data in
save `master', replace empty

foreach x of local files {
	di "`x'" // Display file name

	* 2A) Import each file
	qui: import excel "`x'", firstrow case(lower) clear // Import xls file
	qui: gen fileyear = subinstr("`x'", ".xls", "", .)	// Generate id variable (same as file name but without .xls)

	* 2B) Append each file to masterfile
	append using `master', force
	save `master', replace
}

*** 3) Exporting final data
order fileyear, first
sort fileyear // 133 variables, 276 variables (1994-2019)
save $temp/allfin_92_93_raw.dta, replace

clear
gl data94_19 "$rawdata/enrollment/92-19/All_Data_Items/1994_2019"
cd "$data94_19"
*** 1) Define xls files to include
local filepath = "`c(pwd)'" // Save path to current folder in a local
di "`c(pwd)'" // Display path to current folder
local files : dir "`filepath'" files "*.xls" // Save name of all files in folder ending with .xls in a local
di `"`files'"' // Display list of files to import data from
*** 2) Loop over all files to import and append each file
tempfile master`i' // Generate temporary save file to store data in
save `master'`i', replace empty

foreach x of local files {
	di "`x'" // Display file name

	* 2A) Import each file
	qui: import excel "`x'", firstrow case(lower) clear // Import xls file
	qui: gen fileyear = subinstr("`x'", ".xls", "", .)	// Generate id variable (same as file name but without .xls)

	* 2B) Append each file to masterfile
	append using `master'`i', force
	save `master'`i', replace
}

*** 3) Exporting final data
order fileyear, first
sort fileyear // 133 variables, 276 variables (1994-2019)
save $temp/allfin_94_19_raw.dta, replace


***************************************************************************
* Clean 92-93 first
* Note that for years 1992-1993 the SD identifier is ID, and NCESID, SCHLEV code.
use $temp/allfin_92_93_raw.dta, clear 

* File has 133 variables
* Generate the variable year based on fileyear
*drop year
gen years = substr(fileyear, 6, .)
gen year="19"+years

destring year, replace
drop years fileyear
order year, first

* Generate id_govs variable so we can merge with Master_80_17_five.dta
***** Get id_govs variable
gen length_id= strlen(id)
sum length_* // 9 characters long
gen id_govs = id
drop length_id

sort year id_govs

* Generate state, county, unit identifier
*gen govs_state = substr(ID, 1, 2) // 2 digit state code
ren state govs_state
gen govs_type= substr(id, 3, 1)  // 1 digit type of government
gen govs_cnty= substr(id, 4, 3)  // 3 digit county code
gen id_school = substr(id, 7, 3)  // 3 digit government unit

order year id_govs id supid govs_state govs_type govs_cnty id_school, first

keep if govs_type=="5"

** Some SD does not have NCESID code
gen length_ncesid=strlen(ncesid) // 7 sd doesnt have NCESID code
tab length_ncesid
label variable length_ncesid "length of NCESID"
unique id if length_ncesid==1 // 997
gen dummy_noNCESID=length_ncesid==1 // dummy for SD with no NCESID
label variable dummy_noNCESID "=1 for SD with no NCESID"

* Incorrect NCESID codes
gen dummy_00_NCESID=ncesid=="0     0"
label variable dummy_00_NCESID "=1 if Incorrect NCESID codes"
unique id if dummy_00_NCESID==1 // 1

*drop dup_*
duplicates report year id
*duplicates tag year id, gen(dup_id)
duplicates tag year ncesid if (dummy_noNCESID==0 & dummy_00_NCESID==0), gen(dup_ncesid) // there are duplicates
duplicates report year id_govs
*duplicates tag year id_govs, gen(dup_idgovs) 
unique id_govs if dup_ncesid>0 // 232 SD have duplicates
duplicates tag year id_govs supid, gen(dup_idgovs_supid) 
sum dup_* 
drop dup_idgovs dup_idgovs_supid length_ncesid

** 141 variables
save $temp/allfin_idgovs_92_93.dta, replace

/* ========================================================================= */

* Clean allfin_94_19_raw.dta first
* Note that for years 1994-2019 the SD identifier is IDCENSUS, and NCESID, SCHLEV code.
use $temp/allfin_94_19_raw.dta, clear 
*drop if inlist(fileyear,"elsec92","elsec93")
*drop id supid yrdatind yrdatdep

* File has 276 variables
* Generate the variable year based on fileyear
gen years = substr(fileyear, 6, .)
gen dummy_nineties=cond(years=="94" | years=="95" | years=="96" | years=="97" | years=="98" | years=="99",1,0)
gen year="19"+years if dummy_nineties==1
replace year="20"+years if dummy_nineties==0
destring year, replace
drop years fileyear dummy_nineties
order year, first

* Generate id_govs variable so we can merge with Master_80_17_five.dta
***** Get id_govs variable
gen length_idcensus= strlen(idcensus)
sum length_* // 14 characters long
gen id_govs = substr(idcensus, 1, 9)
gen supid = substr(idcensus, 10, 5) // 10 to 14 ch
drop length_idcensus
sort year id_govs

* Generate state, county, unit identifier
ren state govs_state
*gen govs_state = substr(idcensus, 1, 2) // 2 digit state code
gen govs_type= substr(idcensus, 3, 1)  // 1 digit type of government
gen govs_cnty= substr(idcensus, 4, 3)  // 3 digit county code
gen id_school = substr(idcensus, 7, 3)  // 3 digit government unit

order year id_govs idcensus supid govs_state govs_type govs_cnty id_school fips, first
keep if govs_type=="5"
keep if supid=="00000" // TO avoid duplicates

** Some SD does not have NCESID code
gen length_ncesid=strlen(ncesid) // 7 sd doesnt have NCESID code
tab length_ncesid
label variable length_ncesid "length of NCESID"
unique idcensus if length_ncesid==0 // 41
unique idcensus if length_ncesid==1 // 286
gen dummy_noNCESID=length_ncesid<7 // dummy for SD with no NCESID
label variable dummy_noNCESID "=1 for SD with no NCESID"

*drop dup_*
duplicates report year idcensus
*duplicates tag year idcensus, gen(dup_idcensus)
duplicates report year ncesid if dummy_noNCESID==0
*duplicates tag year ncesid if dummy_noNCESID==0, gen(dup_ncesid)
duplicates report year id_govs
*duplicates tag year id_govs, gen(dup_idgovs) // there are duplicates for id_govs
*unique id_govs if dup_idgovs>0 // 140 SD have duplicates id_govs, check SUPID
duplicates report year id_govs supid
*duplicates tag year id_govs supid, gen(dup_idgovs_supid) 
*sum dup_* 
*drop dup_idcensus dup_idgovs dup_idgovs_supid length_ncesid

** 284 variables
save $temp/allfin_idgovs_94_19.dta, replace

/* Identification Number (IDCENSUS field) Schema and Type of Government Code:
The first 2 characters of the IDCENSUS field stand for the state code. 
The 3rd character represents the "type of government" code, described below. 
Characters 4 through 6 represent the county code. 
Characters 7 through 14 uniquely identify the government unit. 
For an independent school system, this government unit is the system itself. 
For dependent school systems, characters 1 through 9 of the IDCENSUS field 
match that of the parent government on which the system is dependent. 
Characters 10 through 14 uniquely identify the dependent school system where
 more than one system is dependent on the parent government.*/

/*
* We label some variables that we want to keep
label variable TOTALREV "TOTAL ELEMENTARY-SECONDARY REVENUE"
label variable TFEDREV "Total Revenue from Federal Sources"
label variable TSTREV "Total Revenue from State Sources"
label variable TLOCREV "Total Revenue from Local Sources"
label variable LOCRTAX "All taxes"
label variable LOCRPROP "Property taxes"
label variable LOCRPAR "Parent government contributions"
label variable LOCRCICO "Revenue from cities and counties"
label variable LOCROSCH "Revenue from other school systems"
label variable LOCRCHAR "Charges"
label variable LOCROTHR "Other local revenues"
label variable TOTALEXP "TOTAL ELEMENTARY-SECONDARY EXPENDITURE"
label variable TCURSPND "Total Current Spending"
label variable TSALWAGE "Total salaries and wages"
label variable TEMPBENE "Total employee benefit payments"
label variable TCAPOUT "Total Capital Outlay Expenditure"
label variable TPAYOTH "Payments to Other Governments"
label variable TINTRST "Interest on School System Indebtedness"
label variable DEBTOUT "Long-term debt outstanding at end of the fiscal year"
label variable LONGISSU "Long-term debt issued during the fiscal year"
label variable LONGRET "Long-term debt retired during the fiscal year"
label variable IDCENSUS "School System Identification Number"
label variable NAME "School System Name"
label variable CONUM "ANSI State and County Code"
label variable CSA "Consolidated Statistical Area"
label variable CBSA "Core-Based Statistical Area"
label variable NCESID "NCES Indentification Number"

* Drop variables that start with
drop PP* PC* TCU* FED* STR*
*/

/* *********** MERGE FINAL DATASET FOR ENROLLMENT 1980-2017 ********** */
clear
append using $temp/allfin_idgovs_92_93.dta $temp/allfin_idgovs_94_19.dta

keep year id_govs govs_state govs_type govs_cnty id_school name schlev ncesid yrdatind v33 
rename v33 enrollment
*drop if year>2017
save $temp/enrollment_all_92_19, replace

**************** MERGE FINAL DATASET FOR ENROLLMENT 1980-2017 ***********
clear
append using $temp/enrollment_ind_70_91.dta $temp/enrollment_all_92_19.dta

format %30s name
sort id_govs year
order year id_govs govs_state govs_type govs_cnty id_school ncesid name enrollment, first
* 12 variables/

** Make panel full
egen vSchoolID = group(id_govs)
xtset vSchoolID year
*tsfill, full

/* There are school districts that does not appear in certain years*/
bys vSchoolID: egen n_years = count(year) // max 38 years
label variable n_years "# of years that sd appears in data"
tab n_years
*drop if n_years<12
unique id_govs if n_years==41 // 7,994
unique id_govs if n_years==37 // 953
unique id_govs if n_years==1 // 285

/*
/* Drop SD with less than 100 students in every year they appear */
gen dummy_less100=enrollment<100 
bys id_govs: egen yrs_less100=sum(dummy_less100)
gen dummy_all_less100=n_years==yrs_less100
label variable dummy_less100 "=1 if enrollment<100"
label variable yrs_less100 "Number of years with enrollment<100"
label variable dummy_all_less100 "=1 if enrollment<100 for all years the SD appears in data"
unique id_govs if dummy_all_less100==1 // 2,865 SD
tab schlev if dummy_all_less100==1 
drop if dummy_all_less100==1
unique id_govs // 14,034 SD
*/

** Check for SD with Zero enrollment **
gen dummy_zeroenrollment=enrollment==0
egen HasZeroEnroll=max(dummy_zeroenrollment), by(id_govs)
tab HasZeroEnroll
drop if HasZeroEnroll==1
tab yrs_zeroenroll
drop HasZeroEnroll yrs_zeroenroll dummy_zeroenrollment

unique id_govs // 13,820 SD

*label variable dummy_zeroenrollment "=1 if enrollment is zero"
*label variable yrs_zeroenroll "Number of years with zero enrollment"

*drop n_years dummy_less100 yrs_less100 dummy_all_less100 dummy_zeroenrollment yrs_zeroenroll

*drop n_years dummy_zeroenrollment yrs_zeroenroll

/* We want to fill those missing years by interpolation. 
Step 1: Rectangularize dataset
_fillin is 1 for observations created by using fillin and 0 for previously 
existing observations.*/
fillin vSchoolID year 
label variable _fillin "=1 if the obs was not in the original data"

tab year _fillin

/* Step 2: Linear Interpolation */
bys vSchoolID: ipolate enrollment year, gen(enrollment_ipolate)
*ipolate enrollment year, gen(li_enrollment) epolate by(id_govs)

/* We need to round enrollment */
replace enrollment = round(enrollment_ipolate,1) if _fillin==1
label variable enrollment "enrollment with original & obs interpolated"

*gen dummy_enrol_interpolated = cond(_fillin==1 & ENROLLMENT~=enrollment,1,0)
ren _fillin dummy_enrol_interpolated
label variable dummy_enrol_interpolated "=1 if enrollment was interpolated"

bys vSchoolID: egen sum_interpolated = sum(dummy_enrol_interpolated)
tab sum_interpolated
label variable sum_interpolated "Number of year with enrollment interpolated"
drop enrollment_ipolate

unique id_govs if sum_interpolated==19 // 1 SD
unique id_govs if sum_interpolated==16 // 2 SD
unique id_govs if sum_interpolated==11 // 3 SD
unique id_govs if sum_interpolated==10 // 638 SD

** How many missing values we have in the data
mdesc

*** Fill in missing variables names and codes
bys vSchoolID: replace ncesid = ncesid[_N] if vSchoolID==vSchoolID[_N] & inrange(year,1979,1991)
mdesc 

foreach var in id_govs govs_state govs_type govs_cnty id_school ncesid name schlev {
	sort vSchoolID year
	replace `var' = `var'[_n-1] if vSchoolID==vSchoolID[_n-1] & `var'=="" & `var'[_n-1]!=""  & dummy_enrol_interpolated==1
	gsort vSchoolID -year
	replace `var' = `var'[_n-1] if vSchoolID==vSchoolID[_n-1] & `var'==""  & `var'[_n-1]!=""  & dummy_enrol_interpolated==1
}

mdesc

*** Check enrollment again
gen dummy_less100=enrollment<100 
bys vSchoolID: egen yrs_less100=total(dummy_less100)
tab yrs_less100
gen dummy_miss_enrollment=enrollment==.
bys vSchoolID: egen yrs_missenrollment=total(dummy_miss_enrollment)
tab yrs_missenrollment if year~=2019
label variable dummy_less100 "=1 if enrollment<100"
label variable yrs_less100 "Number of years with enrollment<100"
unique id_govs // 13,820 SD

** Check for SD with Zero enrollment **
gen dummy_zeroenrollment=enrollment==0
egen yrs_zeroenroll=total(dummy_zeroenrollment), by(id_govs)
tab yrs_zeroenroll
unique id_govs // 13,365 SD
*drop yrs_zeroenroll dummy_zeroenrollment

sort vSchoolID year
duplicates report year id_govs
drop if year>2018
save $temp/temp_enrollment, replace

*******************************************************************************

erase $temp/enrollment_ind_70_91.dta
erase $temp/allfin_92_93_raw.dta
erase $temp/allfin_94_19_raw.dta
erase $temp/allfin_idgovs_92_93.dta
erase $temp/allfin_idgovs_94_19.dta
erase $temp/enrollment_all_92_19.dta

log close

/*
/* ====================== final prueba ================================ */ 
****** Merge
use "$datafolder\indsdfin_idgovs_67_91.dta", clear
keep year-pop t01 f12 id_govs id_school

* Merge data from 87-91
merge 1:1 year id_govs using "$data\87-91\elsec_87_91_clean.dta", ///
keepusing(NCESID NAME ENROLLMENT YRENROLLMENT dummmy_enrollment_corr89 V33 T01)

unique id_govs if year>1986 & _merge==3 // 14,519 matched
unique id_govs if year>1986 & _merge==1 // 483 in data 67-91 but not 87-91
unique id_govs if year>1986 & _merge==2 // 607 in data 87-91 but not in 67-91

gen dummy_equal=cond(pop==ENROLLMENT,1,0) if year>1986 & _merge==3
unique id_govs if dummy_equal==1 // 14,499 SD equal match of enrollment in both datasets
unique id_govs if dummy_equal==0

order year id_govs NCESID name pop ENROLLMENT YRENROLLMENT yrpop dummy_equal, first
*br year id_govs pop ENROLLMENT dummy_equal if dummy_equal==1

* Check if enrollment stats are similar
sum pop ENROLLMENT  if year>1986 & _merge==3

* Bring a dummy for id_govs in our sample
merge m:1 id_govs using "$enrollment\827sd.dta", ///
keepusing(dummy_827sd) nogen

sort id_govs year

sum pop ENROLLMENT if year>1986 & dummy_827sd==1

br if year>1986 & dummy_827sd==1 & dummmy_equal==0 // check year 89

* Bring enrollment variable from our sample
merge 1:1 year id_govs using "$datafolder\INTRAL06_Master_827sd.dta", ///
keep(match master) keepusing(enrollment enrollmentdummy) nogen

sum pop ENROLLMENT enrollment if year>1986 & dummy_827sd==1

* Next: check individual tables for 1991-2019. Check how much they change from all units tables

*/