/*==========================================================================
Project: Schoold District Capital
Authors: Eva Loaeza
Description: Creates balanced panel of SD.
---------------------------------------------------------------------------
Creation Date:      1/18/2023
Modification Date:  
Do-file version:    01
Output:             .dta
===========================================================================*/

clear	
set more off

gl rawdata "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/Raw"
gl temp "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/temp"
gl logs "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/logs"
gl data "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/replication/data"

* Save log file
log using "$logs/get_dataforanalysis", replace

*******************************************************************************
** Get county fips code
import excel "$rawdata/IndFin67_12/GOVS_to_FIPS_Codes_State_&_County_2007.xls", sheet("County Codes") cellrange(B16:H3238) clear
ren (B C D E F G H ) (id govs_state govs_cnty cnty_name fips_state fips_cnty_02 fips_cnty_07)
drop if govs_cnty=="000"
gen issame=fips_cnty_02==fips_cnty_07
tab issame
drop if cnty_name=="SKAGWAY-HOONAH-ANGOON CENSUS AREA [changed for 2007]"
duplicates report id
ren fips_cnty_07 fips_cnty
save "$temp/cntyfips_xwalk", replace

** Get MSA codes
import excel "$rawdata/czlma903.xls", sheet("CZLMA903") firstrow case(lower) clear
ren countyfipscode cntyfips
ren ruralurbancontinuumcode1993 ruralurban
keep cntyfips countyname ruralurban msa1993 msaname
save "$temp/temp_msa_codes", replace
/* 
Check: https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/documentation/
Rural-urban  Continuum Code 1993 (Beale Code)
Metro counties:
0	Central counties of metro areas of 1 million population or more.
1	Fringe counties of metro areas of 1 million population or more.
2	Counties in metro areas of 250,000 to 1 million population.
3	Counties in metro areas of fewer than 250,000 population.
Nonmetro counties:
4	Urban population of 20,000 or more, adjacent to a metro area.
5	Urban population of 20,000 or more, not adjacent to a metro area.
6	Urban population of 2,500 to 19,999, adjacent to a metro area.
7	Urban population of 2,500 to 19,999, not adjacent to a metro area.
8	Completely rural or less than 2,500 urban population, adjacent to a metro area.
9	Completely rural or less than 2,500 urban population, not adjacent to a metro area.
*/


** Import school district names from raw data
import delimited "$rawdata/IndFin67_12/ALLids.csv", stringcols(1 3 5 8) clear
keep if typecode==5
destring population, replace ignore(",")
ren id id_govs
ren name sd_name
drop version jacketunit
save "$temp/idgovs_name_xwalk", replace

* Import k created in matlab
import delimited "$data/k.txt", clear
keep panelid timeid capital
save "$temp/k", replace

**************************************************************************
* Merge all the variables for the analysis

use "$data/balanced_panel.dta", clear
drop totcur_var totcur_var_avg

gen govs_state= substr(id_govs, 1, 2)
gen govs_cnty= substr(id_govs, 4, 3)

order year id_govs govs_state govs_cnty

** Merge fips codes
merge m:1 govs_state govs_cnty using "$temp/cntyfips_xwalk", keepus(fips_state fips_cnty) keep(match master) nogen

merge m:1 id_govs using "$temp/idgovs_name_xwalk", keepus(sd_name) keep(match master) nogen

** Bring capital 
merge 1:1 panelid timeid using "$temp/k", nogen

drop name // keep only one name
gen cntyfips = fips_state+fips_cnty

** Bring income
merge m:1 year cntyfips using "$temp/bea_incomebycty.dta", keepus(PerCapitaCntyIncome popcnty) keep(match master) nogen

drop govs_state govs_cnty 

** Seems there is an error in enrollment in 1986 for one SD
replace enrollment=. if id_govs=="445003010" & year==1986
sort id_govs year
bys id_govs: ipolate enrollment year if id_govs=="445003010", gen(ienrollment)
replace enrollment=ienrollment if id_govs=="445003010" & enrollment==.
drop ienrollment

order year id_govs _fillin sd_name fips_state fips_cnty panelid timeid popcnty PerCapitaCntyIncome

** Convert all variables in per student

foreach v of varlist totalrevenue-capital {
	replace `v'=`v'/enrollment
}

label var capital "Capital stock"
mdesc

** Merge MSA codes
* Dade County, Florida (12-025): Renamed as Miami-Dade County (12-086) effective July 22, 1997.
replace cntyfips="12025" if cntyfips=="12086"

merge m:1 cntyfips using "$temp/temp_msa_codes", keepus(ruralurban msa1993) keep(match master) nogen

** Drop Nonmetro counties
tab ruralurban if msa1993=="0000"
drop if msa1993=="0000"

** How many schoold districts by MSA
egen sd_by_msa = count(id_govs), by(year msa1993)
unique msa1993 if sd_by_msa>=16
keep if sd_by_msa>=16

unique id_govs // How many School Districts
unique msa1993 // How many MSAs
unique cntyfips // How many counties 
unique fips_state // How many states

** Merge State name 
merge m:1 fips_state using "$rawdata/statenames_fips", keepus(state_name) keep(match master) nogen

** 75 % of number of school districts by MSA is 16. Take this as the cut-off
*collapse (mean) sd_by_msa, by (msa1993)
*sum sd_by_msa, d
*unique msa1993 if sd_by_msa>=`r(p75)'

drop sd_by_msa panelid fips_cnty
egen panelid = group(id_govs)
order year id_govs _fillin sd_name fips_state cntyfips ruralurban msa1993 state_name panelid timeid
save $data/schooldistrict_panel, replace

log close

erase "$temp/cntyfips_xwalk.dta"
erase "$temp/idgovs_name_xwalk.dta"
erase "$temp/k.dta"
erase "$temp/temp_msa_codes.dta"