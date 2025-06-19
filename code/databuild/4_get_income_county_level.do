/*==========================================================================
Project: Schoold District Capital
Authors: Sameer & Eva
Description: Get real income per capita.
---------------------------------------------------------------------------
Creation Date:      11/08/2022
Modification Date:  01/17/2023
Do-file version:    01
Output:             
===========================================================================*/
* Data comes from https://apps.bea.gov/regional/downloadzip.cfm
* CAINC1: Annual Personal Income by County
* Period: 1969-2019

clear	
set more off

gl rawdata "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/Raw"
gl temp "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/temp"
gl logs "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/logs"
gl data "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/replication/data"

* Data comes from https://apps.bea.gov/regional/downloadzip.cfm
* CAINC1: Annual Personal Income by County
* Period: 1969-2019


* import data

import delimited "$rawdata\BEA_Personal Income\CAINC1__ALL_AREAS_1969_2019.csv", clear

drop in 9595/9598

drop tablename industryclassification

format %8s geofips
format %20s geoname

generate str cntyfips = substr(geofips,3,5)
order geofips cntyfips, first

destring cntyfips, g(vFIPSCountyCode)

gen cntyfips_l=strlen(cntyfips)
sum cntyfips_*

drop cntyfips_*

* Rename year variables
forvalues x=9(1)59 {
	local a = `x'+1960
	rename v`x' year`a'
}

forvalues x=1969(1)2019 {
	generate value`x' = real(year`x')
}

drop year* geofips

* For the United States
drop if cntyfips=="00000"
drop if mod(vFIPSCountyCode,1000)==0 // drop states
drop description unit

* Reshape data
reshape long value, i(cntyfips vFIPSCountyCode geoname region linecode) j(year)


* Reshape data
reshape wide value, i(year cntyfips geoname region) j(linecode)

label variable value1 "Personal income (thousands of dollars)"
label variable value2 "Population (persons)"
label variable value3 "Per capita personal income (dollars)"

rename value1 income_cnty
rename value2 popcnty
rename value3 income_cnty_pc

**** Merge CPI2015 data
merge m:1 year using $rawdata/CPI/CPI2015.dta, keep(match master) nogen keepus(cpi)

*** Get real term variables
foreach v of varlist income_cnty income_cnty_pc {
	gen `v'_r=`v'/cpi 
}

order year cntyfips vFIPSCountyCode , first

drop if year<1979 | year>2018

ren income_cnty_pc_r PerCapitaCntyIncome

label var PerCapitaCntyIncome "Per Capita Personal income (dollars of 2015)"

/* linecode description
Personal income (thousands of dollars) 1
Population (persons) 2
Per capita personal income (dollars) 3
*/

drop cpi income_cnty region 
save "$temp/bea_incomebycty.dta", replace




