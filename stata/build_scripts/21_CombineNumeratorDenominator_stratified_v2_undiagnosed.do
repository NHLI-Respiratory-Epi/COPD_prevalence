clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CombineNumeratorDenominator_stratified_v2_undiagnosed", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts

local month = 7


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



//Gender: Male
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte male`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& gender == 1
	
	replace male`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& gender == 1
	
	tab male`year'
}

//Gender: Female
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte female`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& gender == 2
	
	replace female`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& gender == 2
	
	tab female`year'
}



//Age
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen age`year' = `year' - yob if start_fu <= `date' & end_fu >= `date'
}

//40-49
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte age40`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 40 & age`year' < 50
	
	replace age40`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 40 & age`year' < 50
	
	tab age40`year'
}

//50-59
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte age50`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 50 & age`year' < 60
	
	replace age50`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 50 & age`year' < 60
	
	tab age50`year'
}

//60-69
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte age60`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 60 & age`year' < 70
	
	replace age60`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 60 & age`year' < 70
	
	tab age60`year'
}

//70-79
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte age70`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 70 & age`year' < 80
	
	replace age70`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 70 & age`year' < 80
	
	tab age70`year'
}

//80+
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte age80`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 80 & age`year' != .
	
	replace age80`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 80 & age`year' != .
	
	tab age80`year'
}


//Region
label list Region
local region_min = r(min)
local region_max = r(max)

forvalues region = `region_min'/`region_max' {

	forvalues year = 2000/2019 {
		
		local date = mdy(`month', 1, `year')
		
		gen byte region`region'`year' = 0 if (start_fu <= `date') ///
										& (end_fu >= `date') ///
										& region == `region'
		
		replace region`region'`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date') ///
										& region == `region'
		
		tab region`region'`year'
	}
}


compress
save copd_prevalence_strat_v2_undiagnosed, replace


preserve

collapse (count) copdsymp_nodiag20* male20* female20* age4020* age5020* age6020* age7020* age8020* region120* region220* region320* region420* region520* region620* region720* region820* region920* region1020*
generate var = "Denominator"

format %9.0g copdsymp_nodiag20* male20* female20* age4020* age5020* age6020* age7020* age8020* region120* region220* region320* region420* region520* region620* region720* region820* region920* region1020*

reshape long copdsymp_nodiag male female age40 age50 age60 age70 age80 region1 region2 region3 region4 region5 region6 region7 region8 region9 region10, i(var) j(year)

rename * *_denom
rename year_denom year
drop var_denom

tempfile denominator
save `denominator'

restore, preserve

collapse (sum) copdsymp_nodiag20* male20* female20* age4020* age5020* age6020* age7020* age8020* region120* region220* region320* region420* region520* region620* region720* region820* region920* region1020*
generate var = "Numerator"

reshape long copdsymp_nodiag male female age40 age50 age60 age70 age80 region1 region2 region3 region4 region5 region6 region7 region8 region9 region10, i(var) j(year)

rename * *_nume
rename year_nume year
drop var_nume

tempfile numerator
save `numerator'

restore

set type double

collapse (mean) copdsymp_nodiag20* male20* female20* age4020* age5020* age6020* age7020* age8020* region120* region220* region320* region420* region520* region620* region720* region820* region920* region1020*
generate var = "Prevalence (%)"

reshape long copdsymp_nodiag male female age40 age50 age60 age70 age80 region1 region2 region3 region4 region5 region6 region7 region8 region9 region10, i(var) j(year)

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

foreach var in copdsymp_nodiag male female age40 age50 age60 age70 age80 region1 region2 region3 region4 region5 region6 region7 region8 region9 region10 {
	
	if "`previous'" == "" {
		
		order `var'_nume `var'_denom `var'_prev, last
	}
	else {
		
		order `var'_nume `var'_denom `var'_prev, after(`previous'_prev)
	}
	
	local previous "`var'"
}


compress
save "`analysis_dir'/copd_prevalence_strat_collapsed_v2_undiagnosed", replace


xpose, clear varname
order _varname

export excel "`analysis_dir'/outputs/copd_prevalence_strat_v2_undiagnosed.xlsx", replace


use "`analysis_dir'/copd_prevalence_strat_collapsed_v2_undiagnosed", clear  //leave on this one as easier to work with


log close