clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CombineNumeratorDenominator_v2", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts



use builds/Denominator_linked, clear
/*
rename regstartdate regstartdate_denom
rename regenddate regenddate_denom
rename cprd_ddate cprd_ddate_denom
rename start_fu start_fu_denom
rename end_fu end_fu_denom
*/

merge 1:1 patid using builds/cohort_copd_stratvars_value
/*
count if _merge == 3 & regstartdate_denom != regstartdate
count if _merge == 3 & regenddate_denom   != regenddate
count if _merge == 3 & cprd_ddate_denom   != cprd_ddate
count if _merge == 3 & start_fu_denom     != start_fu
count if _merge == 3 & end_fu_denom       != end_fu
*/
drop _merge


local month = 7


//Validated COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copd`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date')
	
	replace copd`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date') ///
									& (end_fu >= `date')
	
	tab copd`year'
}


//QOF COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdqof`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdqof`year' = 1 if (start_fu <= `date') ///
									& (copd_qof_1st <= `date') ///
									& (end_fu >= `date')
	
	tab copdqof`year'
}


//COPD Symptoms (in those with smoking history, an inhaler, and no asthma)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdsymp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdsymp`year' = 1 if (start_fu <= `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date')
	
	tab copdsymp`year'
}


//COPD Symptoms (in those with smoking history, an inhaler, and no asthma)
//IN THOSE WITHOUT A VALIDATED COPD DIAGNOSIS
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdsymp_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdsymp_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date')
	
	tab copdsymp_nodiag`year'
}


//HES COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte hes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes`year' = 1 if (start_fu <= `date') ///
									& (epistart <= `date') ///
									& (end_fu >= `date')
	
	tab hes`year'
}


//HES COPD (any position)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte hesany`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hesany`year' = 1 if (start_fu <= `date') ///
									& (epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab hesany`year'
}


//HES COPD (1st/2nd position only)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte hes12_`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes12_`year' = 1 if (start_fu <= `date') ///
									& (epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab hes12_`year'
}


//HES COPD (any)
//IN THOSE WITHOUT A DIAGNOSIS IN PRIMARY CARE
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte hes_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab hes_nodiag`year'
}


//HES COPD (1st/2nd)
//IN THOSE WITHOUT A DIAGNOSIS IN PRIMARY CARE
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte hes12_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes12_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab hes12_nodiag`year'
}


//Validated or HES (any) COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte valhes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab valhes`year'
}


//Validated or HES (1st/2nd) COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte valhes_onetwo`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes_onetwo`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab valhes_onetwo`year'
}


//QOF or HES COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte qofhes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace qofhes`year' = 1 if (start_fu <= `date') ///
									& (copd_qof_1st <= `date' ///
										| epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab qofhes`year'
}


//Validated or HES or Symptoms COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte valhessymp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhessymp`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_any <= `date' ///
										| ((cough_1st <= `date' ///
											| copd_chronic_breathlessness_1st <= `date' ///
											| sputum_1st <= `date') ///
											& (smoking_status`year' == 2 ///
												| smoking_status`year' == 3) ///
											& (inhaler_1st <= `date') ///
											& (asthma_1st > `date'))) ///
									& (end_fu >= `date')
	
	tab valhessymp`year'
}


//Validated or HES (1st/2nd) or Symptoms COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte valhes12symp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes12symp`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date' ///
										| ((cough_1st <= `date' ///
											| copd_chronic_breathlessness_1st <= `date' ///
											| sputum_1st <= `date') ///
											& (smoking_status`year' == 2 ///
												| smoking_status`year' == 3) ///
											& (inhaler_1st <= `date') ///
											& (asthma_1st > `date'))) ///
									& (end_fu >= `date')
	
	tab valhes12symp`year'
}


compress
save copd_prevalence_v2, replace


preserve

collapse (count) copd20* copdqof20* copdsymp20* copdsymp_nodiag20* hes20* hesany20*  hes12_20* hes_nodiag20* hes12_nodiag20* valhes20* valhes_onetwo20* qofhes20* valhessymp20* valhes12symp20*
generate var = "Denominator"

format %9.0g copd20* copdqof20* copdsymp20* copdsymp_nodiag20* hes20* hesany20*  hes12_20* hes_nodiag20* hes12_nodiag20* valhes20* valhes_onetwo20* qofhes20* valhessymp20* valhes12symp20*

reshape long copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp, i(var) j(year)

rename * *_denom
rename year_denom year
drop var_denom

tempfile denominator
save `denominator'

restore, preserve

collapse (sum) copd20* copdqof20* copdsymp20* copdsymp_nodiag20* hes20* hesany20*  hes12_20* hes_nodiag20* hes12_nodiag20* valhes20* valhes_onetwo20* qofhes20* valhessymp20* valhes12symp20*
generate var = "Numerator"

reshape long copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp, i(var) j(year)

rename * *_nume
rename year_nume year
drop var_nume

tempfile numerator
save `numerator'

restore

set type double

collapse (mean) copd20* copdqof20* copdsymp20* copdsymp_nodiag20* hes20* hesany20*  hes12_20* hes_nodiag20* hes12_nodiag20* valhes20* valhes_onetwo20* qofhes20* valhessymp20* valhes12symp20*

generate var = "Prevalence (%)"

reshape long copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp, i(var) j(year)

rename * *_prev
rename year_prev year
drop var_prev

//Convert to %
foreach var of varlist _all {
	
	if strmatch("`var'", "*_prev") {
		display "`var'"
		replace `var' = round(`var' * 100, 0.01)
		format %9.2f `var'
	}
}

merge 1:1 year using `denominator', nogenerate
merge 1:1 year using `numerator', nogenerate


//Order nicely
local previous ""

foreach var in copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp {
	
	if "`previous'" == "" {
		
		order `var'_nume `var'_denom `var'_prev, last
	}
	else {
		
		order `var'_nume `var'_denom `var'_prev, after(`previous'_prev)
	}
	
	local previous "`var'"
}


label var year "Year"
label var copd_prev "Validated COPD"
label var copdqof_prev "QOF COPD"
label var copdsymp_prev "Smoker with symptoms, inhaler, no asthma"
label var copdsymp_nodiag_prev "Smoker with symptoms, inhaler, no asthma w/o validated COPD"
label var hes_prev "HES COPD"
label var hesany_prev "HES COPD (any position)"
label var hes12__prev "HES COPD (1st / 2nd position)"
label var hes_nodiag_prev "HES COPD (any) w/o validated COPD"
label var hes12_nodiag_prev "HES COPD (1st / 2nd) w/o validated COPD"
label var valhes_prev "Validated OR HES (any) COPD"
label var valhes_onetwo_prev "Validated OR HES (1st / 2nd) COPD"
label var qofhes_prev "QOF OR HES COPD"
label var valhessymp_prev "Validated OR HES (any) OR smoker with symptoms, inhaler, no asthma"
label var valhes12symp_prev "Validated OR HES (1st / 2nd) OR smoker with symptoms, inhaler, no asthma"


compress
save "`analysis_dir'/copd_prevalence_collapsed_v2", replace


xpose, clear varname
order _varname

export excel "`analysis_dir'/outputs/copd_prevalence_v2.xlsx", replace


use "`analysis_dir'/copd_prevalence_collapsed_v2", clear  //leave on this one as easier to work with


log close