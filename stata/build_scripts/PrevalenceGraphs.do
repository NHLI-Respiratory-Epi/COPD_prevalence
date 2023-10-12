clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

capture log close
log using "`analysis_dir'/build_logs/PrevalenceGraphs", text replace


use copd_prevalence_collapsed, clear


foreach var of varlist copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp {
	
	replace `var' = `var' * 100
}

line copd copdqof copdsymp copdsymp_nodiag hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo valhessymp valhes12symp year, title("COPD prevalence") ytitle("Prevalence (%)") legend(size(vsmall)) scale(0.75)
graph export "`analysis_dir'/graphs/prevalence.png", replace


line copd copdqof hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo year, title("COPD prevalence") ytitle("Prevalence (%)") legend(size(vsmall)) scale(0.75)
graph export "`analysis_dir'/graphs/prevalence_PC_SC.png", replace


set obs 26
replace year = _n + 1999

tsset year, yearly

foreach var of varlist copd copdqof copdsymp copdsymp_nodiag hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo valhessymp valhes12symp {
	
	var `var'
	varstable
	fcast compute fc_, step(6)
	replace fc_`var' = `var' if fc_`var' == .
	fcast graph fc_`var', observed
	graph export "`analysis_dir'/graphs/`var'.png", replace
	
	replace fc_`var' = . if year < 2019
}

line copd fc_copd copdqof fc_copdqof copdsymp fc_copdsymp hesany fc_hesany hes12_ fc_hes12_ valhes fc_valhes valhes_onetwo fc_valhes_onetwo valhessymp fc_valhessymp valhes12symp fc_valhes12symp year, lpattern(solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash) lcolor(navy navy maroon maroon forest_green forest_green teal teal cranberry cranberry khaki khaki sienna sienna emidblue emidblue emerald emerald) ytitle("Prevalence (%)") title("COPD prevalence") legend(size(vsmall) order(1 3 5 7 9 11 13 15 17)) scale(0.75)

graph export "`analysis_dir'/graphs/prevalence_projection.png", replace



foreach var of varlist copd copdqof copdsymp copdsymp_nodiag hesany hes12_ hes_nodiag valhes valhes_onetwo valhessymp valhes12symp {
	
	var `var'
	varstable
	fcast compute fc2_, step(16) dynamic(2010)
	fcast graph fc2_`var', observed
	graph export "`analysis_dir'/graphs/2010_`var'.png", replace
}

line copd fc2_copd copdqof fc2_copdqof copdsymp fc2_copdsymp hesany fc2_hesany hes12_ fc2_hes12_ valhes fc2_valhes valhes_onetwo fc2_valhes_onetwo valhessymp fc2_valhessymp valhes12symp fc2_valhes12symp year, lpattern(solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash) lcolor(navy navy maroon maroon forest_green forest_green teal teal cranberry cranberry khaki khaki sienna sienna emidblue emidblue emerald emerald) ytitle("Prevalence (%)") title("COPD prevalence") legend(size(vsmall) order(1 3 5 7 9 11 13 15 17)) scale(0.75)

graph export "`analysis_dir'/graphs/2010_prevalence_projection.png", replace


log close