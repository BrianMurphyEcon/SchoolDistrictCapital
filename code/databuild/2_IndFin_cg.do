/*==========================================================================
Project: Schoold District Capital
Authors: Sameer & Eva
Description: Interpolates Financial data using constant growth rate.
---------------------------------------------------------------------------
Creation Date:      11/08/2022
Modification Date:  01/17/2023
Do-file version:    01
Output:             IndFin70_18_cg.dta
===========================================================================*/

clear	
set more off
cd "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/method_2_2"
gl rawdata "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/Raw"
gl temp "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/temp"
gl logs "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/logs"

* Save log file
log using "$logs/get_financial", replace

*******************************************************************************
gl Y0 1979 

use "./IndFin70_12_raw.dta", clear
gen govs_type  = substr(id_govs,3,1)
tab govs_type
keep if  govs_type=="5"
drop govs_type
drop if year<$Y0
**** Combine data after 2012 (imbalanced panel)
append using "./IndFin13_18_five_raw.dta" , force

** Drop SD with zero total expenditure
gen dzero_totexp=(totalexpenditure==0) // dummy for zero expenditure
tab dzero_totexp
egen HasZeroTotExp=max(dzero_totexp), by(id_govs) // if the SD has at least one year with zero expenditure
tab HasZeroTotExp
sum totalexpenditure if HasZeroTotExp==1
unique id_govs if HasZeroTotExp==1
drop if HasZeroTotExp==1
drop dzero_totexp HasZeroTotExp

** Drop SD with less than 12 year-obs in the data
egen NYears= count(year), by(id_govs)
tab NYear
unique id_govs if NYears<12
drop if NYears<12

egen panelid = group(id_govs)
//bysort panelid: egen x=count(_n) 
egen timeid = group(year)

** Keep main variables
keep year-miscgeneralrevenue totalexpenditure-generalexpenditure interestongendebt totaldebtoutstanding - othnoninfdcashsec timeid panelid
drop totallicensetaxes

**** calculate the constant growth rate

sort panelid timeid

bys panelid: gen gap_t = timeid[_n] - timeid[_n-1] 
tab gap_t

foreach i of var totalrevenue - othnoninfdcashsec {	
	bys panelid: gen gr_`i' = `i'[_n]/`i'[_n-1]      if `i'[_n]!=0 | `i'[_n-1]!=0
	bys panelid: gen gap_`i' = timeid[_n] - timeid[_n-1] 
	bys panelid: gen cg_`i' = gr_`i'^(1/gap_`i') // constant growth rate
}
sum 
xtset panelid timeid
fillin panelid timeid // tsfill, full 
label var _fillin "=1 if the obs was not in the original data"
sort panelid timeid

** How missing SD-year obs are distributed across years
replace year=($Y0 - 1) + timeid if year==.
tab year _fillin // Years 1970-1971, 1973 to 1976, and 1993 to 1996 have low sample

** fill in missing id_govs
sort panelid timeid 
bys panelid: replace id_govs = id_govs[_n-1] if panelid==panelid[_n-1] & _fillin==1 & id_govs[_n-1]!="."
gsort panelid -timeid 
bys panelid: replace id_govs = id_govs[_n-1] if panelid==panelid[_n-1] & _fillin==1 & id_govs[_n-1]!="."

sort panelid timeid
foreach i of var totalrevenue - othnoninfdcashsec {	
	forvalues k = 1(1)48{ // years
	gen cg_`i'_`k' = cond(cg_`i' == ., F.cg_`i', cg_`i') 
	replace cg_`i' = cg_`i'_`k'  if cg_`i'==.
	drop cg_`i'_`k'		
	}	
}

** Using constant growth for Interpolation
sort panelid timeid
foreach i of var totalrevenue - othnoninfdcashsec {	
	replace `i'=L.`i'*cg_`i' if `i' == . & L.`i'~=.
	replace `i'=0 if `i'==. // check this
}

drop gr_* gap_* cg_* 

**** Merge CPI2015 data
merge m:1 year using $rawdata/CPI/CPI2015.dta, keep(match master) nogen keepus(cpi)

*** Get real term variables
foreach v of varlist totalrevenue - othnoninfdcashsec {
	replace `v'=(1000*(`v')/cpi) // data was recorded in thousands of dollars; convert to dollars
}
drop cpi timeid panelid
order year id_govs _fillin
sort id_govs year
*egen InAllYears = max(_fillin), by(id_govs)


save "$temp/IndFin_cg.dta", replace

*******************************************************************************
log close