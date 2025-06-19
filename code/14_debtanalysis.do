use "$finaldata\SD_FinalData.dta", clear

distinct sd_name id_govs state_name msa1993 year

preserve
    bysort sd_name state_name: keep if _n == 1
    bysort state_name: gen district_count = _N
    bysort state_name: keep if _n == 1
    gsort -district_count
    list state_name district_count, noobs clean
restore

preserve 
	contract state id_govs
	destring id_govs, replace
	collapse (count) id_govs, by(state)
	texsave using "$outpath\SDbyState_table.tex", replace
restore

********************************************************************************
*** Table 3, Average Over Years ***
********************************************************************************

** Full Periods
preserve
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital, by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"
	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financing.tex", ///
		replace title("Mean State Capital Financing") varlabels
restore
	
** Pre 1994	
preserve
	keep if year <= 1994
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital, by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"
	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financing_pre1994.tex", ///
		replace title("Mean State Capital Financing Before 1994") varlabels
restore

** Post 1994
preserve
	keep if year > 1994
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital, by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"
	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	list

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financing_post1994.tex", ///
		replace title("Mean State Capital Financing After 1994") varlabels
restore

********************************************************************************	
* Weighted Means 

** Full Sample
preserve
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital [aweight=enrollment], by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"
	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financingWEIGHTED.tex", ///
		replace title("Mean State Capital Financing") varlabels
restore
	

** Pre-1994
preserve
	keep if year <= 1994
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital [aweight=enrollment], by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"

	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	list

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financing_pre1994WEIGHTED.tex", ///
		replace title("Mean State Capital Financing Before 1994") varlabels
restore

** Post 1994
preserve
	keep if year > 1994
	collapse (mean) CFC_no_debt self_financed_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital [aweight=enrollment], by(state_name)
	sort state_name

	gen current_minus_capital = CFC_no_debt - self_financed_capital
	label var current_minus_capital "(1) - (2)"

	label var CFC_no_debt "CF Current (1)"
	label var self_financed_capital "CF Capital (2)"
	label var totaldebtoutstanding "Total Debt"
	label var totalltdissued "New Debt"
	label var bondfd_change "Delta Bond Fund"
	label var totalcapitaloutlays "Capital Outlays"
	label var capital "Capital"
	label var state_name "State"

	// Format all numeric variables to show exactly 2 decimal places
	format CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued bondfd_change totalcapitaloutlays capital %9.0f

	list

	texsave state_name CFC_no_debt self_financed_capital current_minus_capital totaldebtoutstanding totalltdissued ///
		bondfd_change totalcapitaloutlays capital using "$outpath\state_capital_financing_post1994WEIGHTED.tex", ///
		replace title("Mean State Capital Financing After 1994") varlabels
restore
	
********************************************************************************
*** Further Analysis: Cyclicality ***
********************************************************************************

preserve
	collapse (mean) self_financed_capital CFC_no_debt, by(state_name year)

	twoway (line self_financed_capital year, by(state_name)), ///
		title("Capital Financed Over Time") ///
		xlabel(#10) ylabel(#10) legend(off)
	graph export "$outpath\capitalfin_cyclical.jpg", replace

	twoway (line CFC_no_debt year, by(state_name)), ///
		title("Current Financed Over Time") ///
		xlabel(#10) ylabel(#10) legend(off)
	graph export "$outpath\currentfin_cyclical.jpg", replace
restore

********************************************************************************
*** Further Analysis: Outliers ***
********************************************************************************
preserve
	collapse (mean) self_financed_capital, by(state_name year)

	graph box self_financed_capital, over(year, sort(year)) ///
		title("Boxplot of Self-Financed Capital Over Time") ///
		ytitle("Self-Financed Capital") ///
		xsize(10) ysize(6)
	graph export "$outpath\self_financed_boxplot.jpg", replace
restore

preserve
	collapse (mean) CFC_no_debt, by(state_name year)

	graph box CFC_no_debt, over(year, sort(year)) ///
		title("Boxplot of Self-Financed Capital Over Time") ///
		ytitle("Self-Financed Capital") ///
		xsize(10) ysize(6)
	graph export "$outpath\current_financed_boxplot.jpg", replace
restore

preserve
	generate ratio_self_financed = self_financed_capital / totalcapitaloutlays
	generate ratio_CFC_no_debt = CFC_no_debt / totalcapitaloutlays
	generate ratio_ltdissued = totalltdissued / totalcapitaloutlays
	generate ratio_current_ops = totalcurrentoper / totalcapitaloutlays
	bysort year: summarize ratio_current_ops ratio_self_financed ratio_CFC_no_debt ratio_ltdissued

	collapse (mean) ratio_self_financed ratio_CFC_no_debt, by(year)

	label var ratio_self_financed "CF Capital Ratio"
	label var ratio_CFC_no_debt "CF Current Ratio"
	format ratio_self_financed ratio_CFC_no_debt %9.2f

	texsave year ratio_self_financed ratio_CFC_no_debt using "$outpath\tabratiobyyear.tex", replace title("Capital Financing Definitions by Year") varlabels


	twoway (line ratio_self_financed year, sort lcolor(blue) lpattern(solid)) ///
		   (line ratio_CFC_no_debt year, sort lcolor(red) lpattern(dash)), ///
		   legend(order(1 "CF Capital Ratio" 2 "CF Current Ratio")) ///
		   title("Ratios over Time") ///
		   ytitle("Ratio") xtitle("Year")
	graph export "$outpath\ratiobyyear.png", as(png) replace
restore

gen consistency_category = "Both Positive" if self_financed_capital >= 0 & CFC_no_debt >= 0
replace consistency_category = "Both Negative" if self_financed_capital < 0 & CFC_no_debt < 0
replace consistency_category = "Capital+ Current-" if self_financed_capital >= 0 & CFC_no_debt < 0
replace consistency_category = "Capital- Current+" if self_financed_capital < 0 & CFC_no_debt >= 0
drop if missing(consistency_category)

preserve
	collapse (mean) enrollment totalstateigrevenue totalcurrentoper totalcapitaloutlays totalltdissued, by(consistency_category)

	label var enrollment "Enrollment"
	label var totalstateigrevenue "State Revenue"
	label var totalcurrentoper "Operating Costs"
	label var totalcapitaloutlays "Total Capital Outlays"
	label var totalltdissued "Newly Issued Debt"

	format enrollment %9.0f
	format totalstateigrevenue %9.0f
	format totalcurrentoper %9.0f
	format totalcapitaloutlays %9.0f
	format totalltdissued %9.0f

	texsave consistency_category enrollment totalstateigrevenue totalcurrentoper totalcapitaloutlays totalltdissued using "$outpath\consistent_stats.tex", replace title("Characteristics by Consistency") varlabels
restore

preserve
	*tabulate state_name consistency_category

	estpost tabulate state_name consistency_category
	esttab . using "$outpath\consistent_states.tex", replace ///
	  cell(b(fmt(0))) unstack noobs nomtitle nonumber ///
	  booktabs ///
	  collabels(none) ///
	  coeflabels(`"Consistent (Both Positive)"' `"Consistent (Both Negative)"' /// 
				 `"Inconsistent (Capital+ Current-)"' `"Inconsistent (Capital- Current+)"') ///
	  title("States by Consistency Category")
restore 
 
preserve
	keep if year <= 1994  
	estpost tabulate state_name consistency_category
	
	esttab . using "$outpath\consistent_states_pre1994.tex", replace ///
	  cell(b(fmt(0))) unstack noobs nomtitle nonumber ///
	  booktabs ///
	  collabels(none) ///
	  coeflabels(`"Consistent (Both Positive)"' `"Consistent (Both Negative)"' /// 
				 `"Inconsistent (Capital+ Current-)"' `"Inconsistent (Capital- Current+)"') ///
	  title("States by Consistency Category")
restore

preserve
	keep if year > 1994  
	estpost tabulate state_name consistency_category
	
	esttab . using "$outpath\consistent_states_post1994.tex", replace ///
	  cell(b(fmt(0))) unstack noobs nomtitle nonumber ///
	  booktabs ///
	  collabels(none) ///
	  coeflabels(`"Consistent (Both Positive)"' `"Consistent (Both Negative)"' /// 
				 `"Inconsistent (Capital+ Current-)"' `"Inconsistent (Capital- Current+)"') ///
	  title("States by Consistency Category")
restore


preserve
	gen neg_self_fin = (self_financed_capital < 0)
	label var neg_self_fin "Negative Self-Financed Capital"
	label define neg_self_fin_lab 0 "Non-negative" 1 "Negative"
	label values neg_self_fin neg_self_fin_lab

	gen pos_cfc_no_debt = (CFC_no_debt > 0)
	label var pos_cfc_no_debt "Positive CFC No Debt"
	label define pos_cfc_no_debt_lab 0 "Non-positive" 1 "Positive"
	label values pos_cfc_no_debt pos_cfc_no_debt_lab

	eststo clear

	eststo: estpost tabstat totalltdissued totaldebtoutstanding enrollment totalcapitaloutlays, ///
			by(neg_self_fin) statistics(mean sd min max n) columns(statistics)

	eststo: estpost tabstat totalltdissued totaldebtoutstanding enrollment totalcapitaloutlays, ///
			by(pos_cfc_no_debt) statistics(mean sd min max n) columns(statistics)

	esttab using "$outpath\combined_tables.tex", ///
		   cells("mean(fmt(%9.2fc)) sd(fmt(%9.2fc) par) min(fmt(%9.2fc)) max(fmt(%9.2fc)) count(fmt(%9.0fc))") ///
		   noobs nonumber nomtitle nonote label booktabs alignment(S) ///
		   title("Comparison of School District Financial Characteristics") ///
		   replace
restore

** TRY
preserve
	gen neg_self_fin = (self_financed_capital < 0)
	label var neg_self_fin "Negative CF Capital"
	label define neg_self_fin_lab 0 "Non-negative" 1 "Negative"
	label values neg_self_fin neg_self_fin_lab

	gen pos_cfc_no_debt = (CFC_no_debt > 0)
	label var pos_cfc_no_debt "Positive CF Current"
	label define pos_cfc_no_debt_lab 0 "Non-positive" 1 "Positive"
	label values pos_cfc_no_debt pos_cfc_no_debt_lab

	eststo clear

	eststo: estpost tabstat totalltdissued totaldebtoutstanding enrollment totalcapitaloutlays, ///
			by(neg_self_fin) statistics(mean sd min max n) columns(statistics)

	esttab using "$outpath\self_fin_table.tex", ///
		   cells("mean(fmt(%9.2fc)) sd(fmt(%9.2fc) par) min(fmt(%9.2fc)) max(fmt(%9.2fc)) count(fmt(%9.0fc))") ///
		   noobs nonumber nomtitle nonote label booktabs ///
		   title("Comparison of School Districts by Self-Financed Capital Status") ///
		   replace

	eststo clear

	eststo: estpost tabstat totalltdissued totaldebtoutstanding enrollment totalcapitaloutlays, ///
			by(pos_cfc_no_debt) statistics(mean sd min max n) columns(statistics)

	esttab using "$outpath\cfc_no_debt_table.tex", ///
		   cells("mean(fmt(%9.2fc)) sd(fmt(%9.2fc) par) min(fmt(%9.2fc)) max(fmt(%9.2fc)) count(fmt(%9.0fc))") ///
		   noobs nonumber nomtitle nonote label booktabs ///
		   title("Comparison of School Districts by CFC No Debt Status") ///
		   replace
restore

********************************************************************************
*** Revisions

preserve
	egen district_id = group(id_govs), label
	tsset district_id year

	gen category = .
	replace category = 1 if self_financed_capital >= 0 & CFC_no_debt >= 0
	replace category = 2 if self_financed_capital < 0 & CFC_no_debt < 0
	replace category = 3 if self_financed_capital >= 0 & CFC_no_debt < 0
	replace category = 4 if self_financed_capital < 0 & CFC_no_debt >= 0

	label define catlbl 1 "Both Positive" 2 "Both Negative" 3 "Capital+ Current-" 4 "Capital- Current+"
	label values category catlbl

	gen cat_lag = L.category
	gen cat_lead = F.category

	label values cat_lead catlbl
	label values cat_lag catlbl

	tab category cat_lead, matcell(freqmat)

	matrix rownames freqmat = Both_Positive Both_Negative Capital+_Current- Capital-_Current+
	matrix colnames freqmat = Both_Positive Both_Negative Capital+_Current- Capital-_Current+

	esttab matrix(freqmat, fmt(%9.0g)) using ///
	"$outpath/transition_t_tplus1.tex", ///
	replace tex fragment nomtitles nonumber
restore

********************************************************************************
*** Revisions 2

gen rel_sfc = self_financed_capital / totalcapitaloutlays
gen rel_cfc = CFC_no_debt / totalcapitaloutlays
gen abs_rel_sfc = abs(rel_sfc)
gen abs_rel_cfc = abs(rel_cfc)
gen sfc_small = abs_rel_sfc <= 0.05
gen cfc_small = abs_rel_cfc <= 0.05
gen sfc_pos = self_financed_capital if self_financed_capital > 0
gen sfc_neg = self_financed_capital if self_financed_capital < 0
gen cfc_pos = CFC_no_debt if CFC_no_debt > 0
gen cfc_neg = CFC_no_debt if CFC_no_debt < 0

sum sfc_pos sfc_neg cfc_pos cfc_neg

gen sfc_pos_pct = rel_sfc if rel_sfc > 0
gen sfc_neg_pct = rel_sfc if rel_sfc < 0
gen cfc_pos_pct = rel_cfc if rel_cfc > 0
gen cfc_neg_pct = rel_cfc if rel_cfc < 0

sum sfc_pos_pct sfc_neg_pct cfc_pos_pct cfc_neg_pct

tab sfc_small
tab cfc_small

gen sfc_small_raw = abs(self_financed_capital) <= 100
gen cfc_small_raw = abs(CFC_no_debt) <= 100

tab sfc_small_raw
tab cfc_small_raw

gen both_small_raw = sfc_small_raw & cfc_small_raw
tab both_small_raw

preserve
	gen abs_sfc = abs(self_financed_capital)
	gen abs_cfc = abs(CFC_no_debt)

	collapse ///
		(mean) sfc_mean=self_financed_capital cfc_mean=CFC_no_debt ///
		(mean) abs_sfc abs_cfc ///
		(sd) sfc_sd=self_financed_capital cfc_sd=CFC_no_debt, ///
		by(state_name)

	gen sfc_norm_dev = sfc_mean / sfc_sd
	gen cfc_norm_dev = cfc_mean / cfc_sd

	label var sfc_mean "Avg\\\\Capital\\\\Financed Capital"
	label var sfc_sd "SD\\\\Capital\\\\Financed Capital"
	label var sfc_norm_dev "Normalized\\\\Deviation\\\\(CFCap)"
	label var cfc_mean "Avg\\\\Capital\\\\Financed Current"
	label var cfc_sd "SD\\\\Capital\\\\Financed Current"
	label var cfc_norm_dev "Normalized\\\\Deviation\\\\(CFCurr)"

	sort sfc_norm_dev

	format sfc_mean cfc_mean %9.0f
	format sfc_sd sfc_norm_dev cfc_sd cfc_norm_dev %9.2f

	texsave state_name sfc_mean sfc_sd sfc_norm_dev ///
					  cfc_mean cfc_sd cfc_norm_dev ///
		using "$outpath\norm_dev_by_state.tex", ///
		replace title("Normalized Deviations by State") varlabels
		
	graph bar sfc_norm_dev, over(state_name, sort(1) label(angle(45))) ///
		bar(1, color(gs10)) ///
		title("CFCapital Normalized Deviation by State") ///
		ytitle("Standard Deviations") ///
		
	graph export "$outpath/norm_dev_sfc.png", replace

	graph bar cfc_norm_dev, over(state_name, sort(1) label(angle(45))) ///
		bar(1, color(gs10)) ///
		title("CFCurrent Normalized Deviation by State") ///
		ytitle("Standard Deviations") ///
		
	graph export "$outpath/norm_dev_cfc.png", replace
restore
	
********************************************************************************
*** Revisions 3

preserve
	destring id_govs, replace

	tsset id_govs year

	gen delta_totaldebt = D.totaldebtoutstanding
	gen delta_newdebt = D.totalltdissued
	gen delta_capitalout = D.totalcapitaloutlays
	gen delta_totaltaxes = D.totaltaxes
	gen delta_propertytax = D.propertytax
	gen delta_totalrevenue = D.totalrevenue
	gen delta_totalexpend = D.totalexpenditure
	gen delta_totalcurrentoper = D.totalcurrentoper
	gen delta_stateigrevenue = D.totalstateigrevenue
	gen delta_totalcash = D.totalcashsecurities
	gen delta_bondfund = D.bondfd_change
	gen delta_sinkingfund = D.sinkingfd_change
	gen delta_enrollment = D.enrollment
	gen delta_income = D.PerCapitaCntyIncome
	gen delta_popcnty = D.popcnty

	rename CFC_no_debt CF_Current
	rename self_financed_capital CF_Capital

	reghdfe CF_Current delta_totaldebt delta_newdebt delta_capitalout, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Capital delta_totaldebt delta_newdebt delta_capitalout, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Current delta_totaldebt delta_newdebt delta_capitalout enrollment propertytax totalstateigrevenue borrowed_money, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Capital delta_totaldebt delta_newdebt delta_capitalout enrollment propertytax totalstateigrevenue borrowed_money, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Current delta_totaldebt delta_newdebt delta_capitalout totalcapitaloutlays bondfd_change sinkingfd_change debt_change totalcashsecurities, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Capital delta_totaldebt delta_newdebt delta_capitalout totalcapitaloutlays bondfd_change sinkingfd_change debt_change totalcashsecurities, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Current PerCapitaCntyIncome enrollment popcnty, absorb(state_name year) cluster(id_govs)

	reghdfe CF_Capital PerCapitaCntyIncome enrollment popcnty, absorb(state_name year) cluster(id_govs)
restore

********************************************************************************
*** Revisions 4

gen expend_check = totalcurrentoper + totalcapitaloutlays
gen match_flag = abs(totalexpenditure - expend_check) <= 20
tab match_flag

gen expend_check2 = totalcurrentoper + totalcapitaloutlays + totalsalarieswages 
gen match_flag2 = abs(totalexpenditure - expend_check2) <= 20
tab match_flag2

gen expend_check3 = totalcurrentoper + totalcapitaloutlays + totalsalarieswages + generalexpenditure
gen match_flag3 = abs(totalexpenditure - expend_check3) <= 20
tab match_flag3

gen expend_check4 = totalcurrentoper + totalsalarieswages 
gen match_flag4 = abs(totalexpenditure - expend_check4) <= 20
tab match_flag4

gen expend_check5 = totalcurrentoper 
gen match_flag5 = abs(totalexpenditure - expend_check5) <= 20
tab match_flag5

preserve
    collapse (mean) CFC_no_debt self_financed_capital sinkingfdcashsec totalcapitaloutlays ///
        totalexpenditure, by(id_govs)

    *gen expend_check = CFC_no_debt + totalcapitaloutlays
    *gen match_flag = (round(expend_check, 0.01) == round(totalexpend, 0.01))  // check match

    label var CFC_no_debt "CF Current"
    label var self_financed_capital "CF Capital"
    label var sinkingfdcashsec "Sinking Fund"
    label var totalcapitaloutlays "Capital Outlays"
    label var totalexpenditure "Total Expenditure"

    format CFC_no_debt self_financed_capital sinkingfdcashsec totalcapitaloutlays ///
        totalexpenditure %9.0f

    texsave id_govs CFC_no_debt self_financed_capital sinkingfdcashsec totalcapitaloutlays ///
        totalexpenditure using "$outpath/sd_capital_check.tex", replace ///
        title("District Capital and Expenditure Check") varlabels
restore
