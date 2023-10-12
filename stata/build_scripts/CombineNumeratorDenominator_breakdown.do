clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CombineNumeratorDenominator_breakdown", text replace

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
	
	gen byte valhes_onetwo`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes_onetwo`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab valhes_onetwo`year'
}



//MRC grade
//MRC 1
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdmrc1`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdmrc1`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == 1
	
	tab copdmrc1`year'
}


//MRC 2
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdmrc2`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdmrc2`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == 2
	
	tab copdmrc2`year'
}

//MRC 3
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdmrc3`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdmrc3`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == 3
	
	tab copdmrc3`year'
}

//MRC 4
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdmrc4`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdmrc4`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == 4
	
	tab copdmrc4`year'
}

//MRC 5
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdmrc5`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdmrc5`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == 5
	
	tab copdmrc5`year'
}

//No MRC recorded
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte copdnomrc`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace copdnomrc`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& mrc`year' == .
	
	tab copdnomrc`year'
}



//IMD
//1st quintile
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte imd1`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace imd1`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == 1
	
	tab imd1`year'
}

//2nd quintile
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte imd2`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace imd2`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == 2
	
	tab imd2`year'
}

//3rd quintile
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte imd3`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace imd3`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == 3
	
	tab imd3`year'
}

//4th quintile
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte imd4`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace imd4`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == 4
	
	tab imd4`year'
}

//5th quintile
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte imd5`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace imd5`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == 5
	
	tab imd5`year'
}

//No IMD recorded
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte noimd`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace noimd`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& imd2015_5 == .
	
	tab noimd`year'
}



//Ethnicity
//White
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte white`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace white`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& ethnicity == 0
	
	tab white`year'
}

//South asian
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte southasian`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace southasian`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& ethnicity == 1
	
	tab southasian`year'
}

//Black
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte black`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace black`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& ethnicity == 2
	
	tab black`year'
}

//Other
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte other`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace other`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& ethnicity == 3
	
	tab other`year'
}

//Mixed
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte mixed`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace mixed`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& ethnicity == 4
	
	tab mixed`year'
}

//Not stated/Uknonwn
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte noeth`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace noeth`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& (ethnicity == 5 | ethnicity == .)
	
	tab noeth`year'
}



//PR status
//referred
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte prref`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace prref`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& pr_referred <= `date'
	
	tab prref`year'
}

//commenced
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte prcommence`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace prcommence`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& pr_commenced <= `date'
	
	tab prcommence`year'
}

//completed
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte prcomplete`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace prcomplete`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& pr_completed <= `date'
	
	tab prcomplete`year'
}



//Smoking status
//current
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte smokcurrent`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace smokcurrent`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& smoking_status`year' == 3
	
	tab smokcurrent`year'
}

//ex
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte smokex`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace smokex`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& smoking_status`year' == 2
	
	tab smokex`year'
}

//never
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte smoknever`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace smoknever`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& smoking_status`year' == 1
	
	tab smoknever`year'
}



//Exacerbations in past year
//0
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte exacer0`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace exacer0`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& (exacerbations`year' == 0 ///
										| exacerbations`year' == .)
	
	tab exacer0`year'
}

//1
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte exacer1`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace exacer1`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& exacerbations`year' == 1
	
	tab exacer1`year'
}


//2+
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte exacer2plus`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace exacer2plus`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& exacerbations`year' >= 2 ///
									& exacerbations`year' != .
	
	tab exacer2plus`year'
}



//Inhaled therapy
//dual
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte therapydual`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace therapydual`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& medication`year' == 1
	
	tab therapydual`year'
}

//triple
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte therapytriple`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace therapytriple`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& medication`year' == 2
	
	tab therapytriple`year'
}



//FEV1 %-predicted
//GOLD 1 (>= 80%)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte gold1`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace gold1`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& fev1pp`year' >= 80 ///
									& fev1pp`year' != .
	
	tab gold1`year'
}

//GOLD 2 (50-79%)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte gold2`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace gold2`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& fev1pp`year' >= 50 ///
									& fev1pp`year' < 80
	
	tab gold2`year'
}

//GOLD 3 (30-49%)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte gold3`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace gold3`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& fev1pp`year' >= 30 ///
									& fev1pp`year' < 50
	
	tab gold3`year'
}

//GOLD 4 (<30%)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen byte gold4`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date') ///
								& (copd_validated_1st <= `date' ///
									| epistart_firstsecond <= `date') ///
	
	replace gold4`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date') ///
									& fev1pp`year' < 30
	
	tab gold4`year'
}


compress
save copd_prevalence_break, replace


preserve


collapse (count) valhes_onetwo20* copdmrc120* copdmrc220* copdmrc320* copdmrc420* copdmrc520* copdnomrc20* imd120* imd220* imd320* imd420* imd520* noimd20* white20* southasian20* black20* other20* mixed20* noeth20* prref20* prcommence20* prcomplete20* smokcurrent20* smokex20* smoknever20* exacer020* exacer120* exacer2plus20* therapydual20* therapytriple20* gold120* gold220* gold320* gold420*

generate var = "Denominator"

format %9.0g valhes_onetwo20* copdmrc120* copdmrc220* copdmrc320* copdmrc420* copdmrc520* copdnomrc20* imd120* imd220* imd320* imd420* imd520* noimd20* white20* southasian20* black20* other20* mixed20* noeth20* prref20* prcommence20* prcomplete20* smokcurrent20* smokex20* smoknever20* exacer020* exacer120* exacer2plus20* therapydual20* therapytriple20* gold120* gold220* gold320* gold420*

reshape long valhes_onetwo copdmrc1 copdmrc2 copdmrc3 copdmrc4 copdmrc5 copdnomrc imd1 imd2 imd3 imd4 imd5 noimd white southasian black other mixed noeth prref prcommence prcomplete smokcurrent smokex smoknever exacer0 exacer1 exacer2plus therapydual therapytriple gold1 gold2 gold3 gold4, i(var) j(year)

rename * *_denom
rename year_denom year
drop var_denom

tempfile denominator
save `denominator'


restore, preserve


collapse (sum) valhes_onetwo20* copdmrc120* copdmrc220* copdmrc320* copdmrc420* copdmrc520* copdnomrc20* imd120* imd220* imd320* imd420* imd520* noimd20* white20* southasian20* black20* other20* mixed20* noeth20* prref20* prcommence20* prcomplete20* smokcurrent20* smokex20* smoknever20* exacer020* exacer120* exacer2plus20* therapydual20* therapytriple20* gold120* gold220* gold320* gold420*

generate var = "Numerator"

reshape long valhes_onetwo copdmrc1 copdmrc2 copdmrc3 copdmrc4 copdmrc5 copdnomrc imd1 imd2 imd3 imd4 imd5 noimd white southasian black other mixed noeth prref prcommence prcomplete smokcurrent smokex smoknever exacer0 exacer1 exacer2plus therapydual therapytriple gold1 gold2 gold3 gold4, i(var) j(year)

rename * *_nume
rename year_nume year
drop var_nume

tempfile numerator
save `numerator'


restore


set type double

collapse (mean) valhes_onetwo20* copdmrc120* copdmrc220* copdmrc320* copdmrc420* copdmrc520* copdnomrc20* imd120* imd220* imd320* imd420* imd520* noimd20* white20* southasian20* black20* other20* mixed20* noeth20* prref20* prcommence20* prcomplete20* smokcurrent20* smokex20* smoknever20* exacer020* exacer120* exacer2plus20* therapydual20* therapytriple20* gold120* gold220* gold320* gold420*

gen var = "Prevalence (%)"

reshape long valhes_onetwo copdmrc1 copdmrc2 copdmrc3 copdmrc4 copdmrc5 copdnomrc imd1 imd2 imd3 imd4 imd5 noimd white southasian black other mixed noeth prref prcommence prcomplete smokcurrent smokex smoknever exacer0 exacer1 exacer2plus therapydual therapytriple gold1 gold2 gold3 gold4, i(var) j(year)

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

foreach var in valhes_onetwo copdmrc1 copdmrc2 copdmrc3 copdmrc4 copdmrc5 copdnomrc imd1 imd2 imd3 imd4 imd5 noimd white southasian black other mixed noeth prref prcommence prcomplete smokcurrent smokex smoknever exacer0 exacer1 exacer2plus therapydual therapytriple gold1 gold2 gold3 gold4 {
	
	if "`previous'" == "" {
		
		order `var'_nume `var'_denom `var'_prev, last
	}
	else {
		
		order `var'_nume `var'_denom `var'_prev, after(`previous'_prev)
	}
	
	local previous "`var'"
}


label var year "Year"


compress
save "`analysis_dir'/copd_prevalence_breakdown_collapsed", replace


xpose, clear varname
order _varname

export excel "`analysis_dir'/outputs/copd_prevalence_breakdown.xlsx", replace


use "`analysis_dir'/copd_prevalence_breakdown_collapsed", clear  //leave on this one as easier to work with


log close