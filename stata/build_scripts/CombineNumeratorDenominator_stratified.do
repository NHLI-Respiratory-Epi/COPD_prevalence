clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CombineNumeratorDenominator_stratified", text replace

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



//Validated or HES (1st/2nd) COPD
**THIS IS THE DIAGNOSIS DEFINITION USED**
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen valhes_onetwo`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes_onetwo`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab valhes_onetwo`year'
}



//Gender: Male
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen male`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& gender == 1
	
	replace male`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& gender == 1
	
	tab male`year'
}


//Gender: Female
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen female`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& gender == 2
	
	replace female`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
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
	
	gen age40`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 40 & age`year' < 50
	
	replace age40`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 40 & age`year' < 50
	
	tab age40`year'
}

//50-59
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen age50`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 50 & age`year' < 60
	
	replace age50`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 50 & age`year' < 60
	
	tab age50`year'
}

//60-69
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen age60`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 60 & age`year' < 70
	
	replace age60`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 60 & age`year' < 70
	
	tab age60`year'
}

//70-79
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen age70`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 70 & age`year' < 80
	
	replace age70`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 70 & age`year' < 80
	
	tab age70`year'
}

//80+
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen age80`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date') ///
									& age`year' >= 80 & age`year' != .
	
	replace age80`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_first <= `date' ///
										| epistart_firstsecond <= `date') ///
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
		
		gen region`region'`year' = 0 if (start_fu <= `date') ///
										& (end_fu >= `date') ///
										& region == `region'
		
		replace region`region'`year' = 1 if (start_fu <= `date') ///
										& (copd_validated_first <= `date' ///
											| epistart_firstsecond <= `date') ///
										& (end_fu >= `date') ///
										& region == `region'
		
		tab region`region'`year'
	}
}


save copd_prevalence_strat, replace


collapse (mean) valhes_onetwo20* male20* female20* age4020* age5020* age6020* age7020* age8020* region120* region220* region320* region420* region520* region620* region720* region820* region920* region1020*

gen index = 1
order index

reshape long valhes_onetwo male female age40 age50 age60 age70 age80 region1 region2 region3 region4 region5 region6 region7 region8 region9 region10, i(index) j(year)

drop index

label var year "Year"
label var male "Validated COPD (male)"
label var female "Validated COPD (female)"


save copd_prevalence_strat_collapsed, replace


xpose, clear varname
order _varname

export excel copd_prevalence_strat.xlsx, replace


use copd_prevalence_strat_collapsed, clear  //leave on this one as easier to work with


log close