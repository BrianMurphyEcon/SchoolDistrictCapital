/*==========================================================================
Project: Schoold District Capital
Authors: Sameer & Eva
Description: Creates balanced panel of SD.
---------------------------------------------------------------------------
Creation Date:      11/08/2022
Modification Date:  01/17/2023
Do-file version:    01
Output:             IndFin70_18_cg.dta
===========================================================================*/

clear	
set more off

gl rawdata "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/Raw"
gl temp "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/temp"
gl logs "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/logs"
gl data "C:/Users/edloaeza/Dropbox/SchoolDistrict2022/replication/data"

* Save log file
log using "$logs/get_sd_panel", replace

*******************************************************************************

use "$temp/IndFin_cg.dta", clear

** Merge enrollment, name of SD and school level indicator
merge 1:1 year id_govs using $temp/temp_enrollment, keepus(enrollment name schlev) keep(match master)
keep if _merge==3
drop _merge
unique id_govs

tab schlev if year==1979
tab schlev if year==2018

** SAMPLE RESTRICTIONS **

** Drop SD with missing enrollment
gen DMissEnroll=enrollment==.
egen YrsMissEnroll = total(DMissEnroll), by (id_govs)
tab YrsMissEnroll
keep if YrsMissEnroll==0
drop DMissEnroll YrsMissEnroll

** Keep only Unified SD
gen DUnifiedSD = schlev=="03"
egen YearsUnified = total(DUnifiedSD), by(id_govs)
tab YearsUnified
drop if YearsUnified<30 // most obs in initial years are coded as BB
unique id_govs
tab schlev
sort id_govs year

** Check enrollment
gen smallenroll = (enrollment<100)
egen YrsLess100 = total(smallenroll), by (id_govs)
tab YrsLess100
sum enrollment if YrsLess100==0
unique id_govs if YrsLess100==0
sum enrollment if YrsLess100>0
unique id_govs if YrsLess100>0
keep if YrsLess100==0
drop YrsLess100 smallenroll

** STABLE AVERAGE ENROLLMENT OVER THE MAIN PERIOD (1995-2017)
*bys id_govs: egen dist_avgenroll_tmp=mean(enrollment)
*bys id_govs: egen dist_avgenroll=max(dist_avgenroll_tmp)

*Drop districts with overly volatile enrollment -- 15% year-on-year changes, 15% off the trendline,
*or more than 1/3 of observations trimmed for one of the above;

gen v33 = enrollment
replace v33=. if v33<100
gen enrolltrim=(v33<.)
egen distnum=group(id_govs)
xtset distnum year
 
bys distnum (year): egen avgenroll=mean(v33)
 
replace enrolltrim=0 if v33>2*avgenroll & v33<.
bys distnum (year): gen denroll=(v33-v33[_n-1])/((v33+v33[_n-1])/2) if enrolltrim==1 & enrolltrim[_n-1]==1
bys distnum: replace enrolltrim=0 if abs(denroll)>0.15 & denroll<.
bys distnum: replace enrolltrim=0 if abs(denroll[_n+1])>0.15 & denroll[_n+1]<.
 
by distnum: egen sdenroll=sd(v33/avgenroll) if enrolltrim==1
 
*Take out a linear trend & drop if residual is too large;
gen lenroll=ln(v33) if enrolltrim==1
bys distnum: egen ybar=mean(lenroll) if enrolltrim==1
bys distnum: egen xbar=mean(year) if enrolltrim==1
gen xx=(year-xbar)^2 if enrolltrim==1
gen xy=(year-xbar)*(lenroll-ybar) if enrolltrim==1
by distnum: egen XX=sum(xx)
by distnum: egen XY=sum(xy)
gen b=XY/XX // by sd
gen resid=(lenroll-ybar)-(year-xbar)*b if enrolltrim==1
replace enrolltrim=0 if abs(resid)>0.1 & resid<.
drop avgenroll-resid
*And drop if more than 1/3 of obs have bad enrollment;
bys distnum: egen frenrolltrim=mean(enrolltrim)
replace enrolltrim=0 if frenrolltrim<0.67
unique id_govs if frenrolltrim<0.67
*drop frenrolltrim

sum enrollment if frenrolltrim<0.67
unique id_govs

drop DUnifiedSD YearsUnified

** Check if totalexpenditure==0
gen ZeroTotExp = (totalexpenditure==0)
egen YrsZeroExp = total(ZeroTotExp), by (id_govs)
tab YrsZeroExp
keep if YrsZeroExp==0
drop YrsZeroExp ZeroTotExp

order year id_govs _fillin name enrollment schlev 
drop v33 enrolltrim distnum frenrolltrim

mdesc

** Prepare variables for Matlab
sort id_govs year
egen panelid = group(id_govs)
egen timeid = group(year)
sum panelid timeid
xtset panelid timeid

** growth rate of current expenditures
bys panelid: gen totcur_var = (totalcurrentoper/totalcurrentoper[_n-1])-1
egen totcur_var_avg = mean(totcur_var), by(panelid) // average growth rate 

*Saving dataset into a txt file to be processed in Matlab
sort panelid timeid
export delimited panelid timeid totalcapitaloutlays totcur_var_avg enrollment using $data/data.txt, replace

save $data/balanced_panel.dta, replace


*****************************************************************************

log close