clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

capture log close
//log using "`analysis_dir'/build_logs/PrevalenceGraphs_v2", text replace


use copd_prevalence_collapsed, clear


foreach var of varlist copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp {
	
	replace `var' = `var' * 100
}

line copd copdqof copdsymp copdsymp_nodiag hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo valhessymp valhes12symp year, title("COPD prevalence") ytitle("Prevalence (%)") legend(size(vsmall)) scale(0.75)
graph export "`analysis_dir'/graphs/v2/prevalence.png", replace


line copd copdqof hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo year, title("COPD prevalence") ytitle("Prevalence (%)") legend(size(vsmall)) scale(0.75)
graph export "`analysis_dir'/graphs/v2/prevalence_PC_SC.png", replace


line copd copdqof copdsymp hes12_ valhes_onetwo year, title("COPD prevalence in English adults ≥40 years old") ytitle("Prevalence (%)") legend(size(vsmall))
graph save "`analysis_dir'/graphs/v2/prevalence_keydefinitions", replace
graph export "`analysis_dir'/graphs/v2/prevalence_keydefinitions.png", replace
graph export "`analysis_dir'/graphs/v2/prevalence_keydefinitions.jpg", replace


set obs 26
replace year = _n + 1999

tsset year, yearly

foreach var of varlist copd copdqof copdsymp copdsymp_nodiag hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo valhessymp valhes12symp {
	
	var `var'
	varstable
	fcast compute fc_, step(6)
	replace fc_`var' = `var' if fc_`var' == .
	fcast graph fc_`var', observed
	graph export "`analysis_dir'/graphs/v2/`var'.png", replace
	
	replace fc_`var' = . if year < 2019
}

line copd fc_copd copdqof fc_copdqof copdsymp fc_copdsymp hesany fc_hesany hes12_ fc_hes12_ valhes fc_valhes valhes_onetwo fc_valhes_onetwo valhessymp fc_valhessymp valhes12symp fc_valhes12symp year, lpattern(solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash) lcolor(navy navy maroon maroon forest_green forest_green teal teal cranberry cranberry khaki khaki sienna sienna emidblue emidblue emerald emerald) ytitle("Prevalence (%)") title("COPD prevalence") legend(size(vsmall) order(1 3 5 7 9 11 13 15 17)) scale(0.75)

graph export "`analysis_dir'/graphs/v2/prevalence_projection.png", replace


gen ln_valhes_onetwo = ln(valhes_onetwo)
line D.hes12_ year
dfuller D.hes12_

corrgram hes12_
corrgram D.hes12_

ac D.hes12_
pac hes12_

arima hes12_, arima(1,1,0)
estimates store arima110

arima copd, arima(2,2,0)
estimates store arima220
estat ic

arima copd, arima(1,2,0)
estimates store arima120
estat ic

arima copd, arima(1,1,0)
estimates store arima110
estat ic


forecast create, replace
forecast estimates arima110, names(hes12_110)
forecast solve

gen fc_million = hes12_[_n-1] + f_hes12_110 if hes12_ == .
replace fc_million = fc_million[_n-1] + f_hes12_110 if fc_million[_n-1] != .
line hes12_ fc3_hes12_ fc_million year

gen copd_D1 = D.copd
gen copd_D2 = D2.copd
gen forecast_copd = copd_D1[_n-1] + f_copd220 if copd_D1 == .
replace forecast_copd = forecast_copd[_n-1] + f_copd220 if forecast_copd[_n-1] != .
gen forecast2_copd = copd[_n-1] + forecast_copd if copd == .
replace forecast2_copd = forecast2_copd[_n-1] + forecast_copd if forecast2_copd[_n-1] != .

line copd forecast2_copd year


foreach var of varlist copd copdqof copdsymp_nodiag hes12_ valhes_onetwo {
	
	var `var'
	varstable
	fcast compute fc3_, step(6) dynamic(2020) replace
	fcast graph fc3_copd fc3_copdqof fc3_hes12_ fc3_valhes_onetwo, observed
	//graph export "`analysis_dir'/graphs/v2/2010_`var'.png", replace
}

line copd fc2_copd copdqof fc2_copdqof copdsymp fc2_copdsymp hesany fc2_hesany hes12_ fc2_hes12_ valhes fc2_valhes valhes_onetwo fc2_valhes_onetwo valhessymp fc2_valhessymp valhes12symp fc2_valhes12symp year, lpattern(solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash solid dash) lcolor(navy navy maroon maroon forest_green forest_green teal teal cranberry cranberry khaki khaki sienna sienna emidblue emidblue emerald emerald) ytitle("Prevalence (%)") title("COPD prevalence") legend(size(vsmall) order(1 3 5 7 9 11 13 15 17)) scale(0.75)

graph export "`analysis_dir'/graphs/v2/2010_prevalence_projection.png", replace


log close