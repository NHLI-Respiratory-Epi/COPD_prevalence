clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/StratificationValueVars", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts

local first_year = 2000
local last_year = 2019
local month = 7


use builds/cohort_copd, clear

keep patid gender dob

//Merge with observation file that includes VALUE codelists
merge 1:m patid using builds/Observation_compactvalue_all
keep if _merge == 3
drop _merge

gsort patid obsdate


preserve


// MRC events
//============
keep if mrc_all != .

drop fev1 fev1_predicted fev1_percent_pred fvc fvc_predicted fvc_percent_pred fev1_fvc_ratio fev1_fvc_ratio_predicted fev1_fvc_ratio_percent_pred bronchdil generalspirom spirom_all


tab1 mrc mmrc emrc, missing
tab1 mrc_dyspnoea_scale mmrc_dyspnoea_scale emrc_dyspnoea_scale

//just keep the mrc values
drop if mrc == .


//fill in scores for value codes
replace mrc_dyspnoea_scale = value if mrc_dyspnoea_scale == .


//remove potentially erroneous values (based on units)
codebook numunitid
list value numunitid if numunitid != 144 & numunitid != .
drop if numunitid != 144 & numunitid != .


//remove values that don't match MRC grade stated by code
tab value
tab value if value != . & value != mrc_dyspnoea_scale
tab value mrc_dyspnoea_scale

drop if value != . & value != mrc_dyspnoea_scale

tab mrc_dyspnoea_scale


//most recent MRC at time of prevalence calculation
forvalues year = `first_year'/`last_year' {
	
	gen mrc`year' = mrc_dyspnoea_scale if obsdate <= mdy(`month', 1, `year')
}

//collapse to one row per patient
collapse (lastnm) mrc2000 mrc2001 mrc2002 mrc2003 mrc2004 mrc2005 mrc2006 mrc2007 mrc2008 mrc2009 mrc2010 mrc2011 mrc2012 mrc2013 mrc2014 mrc2015 mrc2016 mrc2017 mrc2018 mrc2019, by(patid)

compress

tempfile temp_mrc
save `temp_mrc'


restore, preserve


// Spirometry events
//===================
keep if spirom_all != .

drop mrc mmrc emrc mrc_dyspnoea_scale mmrc_dyspnoea_scale emrc_dyspnoea_scale mrc_all

//FEV1/FVC ratio **CHECK FOR SPECIFIC CODES** ie those hardcoded as eg FEV1/FVC < 0.7
**MANUAL CALCULATION REQUIRED AS WELL**
codebook bronchdil
keep if bronchdil == 2
keep if fev1_fvc_ratio == 1

//convert % values to ratios and remove implausible values
replace value = value/100 if value > 1
drop if value < 0.2
drop if value > 1


//most recent FEV1/FVC ratio at time of prevalence calculation
forvalues year = `first_year'/`last_year' {
	
	gen fev1fvc`year' = value if obsdate <= mdy(`month', 1, `year')
}

//collapse to one row per patient
collapse (lastnm) fev1fvc2000 fev1fvc2001 fev1fvc2002 fev1fvc2003 fev1fvc2004 fev1fvc2005 fev1fvc2006 fev1fvc2007 fev1fvc2008 fev1fvc2009 fev1fvc2010 fev1fvc2011 fev1fvc2012 fev1fvc2013 fev1fvc2014 fev1fvc2015 fev1fvc2016 fev1fvc2017 fev1fvc2018 fev1fvc2019, by(patid)

compress

tempfile temp_fev1fvc
save `temp_fev1fvc'


restore


//GOLD stage  **check for hardcoded codes as well**
**NOT POSSIBLE TO DO MANUAL CALCULATION WITHOUT HEIGHT & WEIGHT**
keep if fev1_percent_pred == 1 | fev1 == 1 | fev1_predicted == 1 | height == 1
keep patid gender dob obsdate value numunitid fev1 fev1_predicted fev1_percent_pred bronchdil height

drop if value == .
drop if value == 0


//FEV1
tab numunitid if fev1 == 1, missing
tab numunitid if fev1 == 1 ///
				& (numunitid == 160 ///
					| numunitid == 166 ///
					| numunitid == 167 ///
					| numunitid == 200 ///
					| numunitid == 315)
//L - 160 (l), 166 (litre), 167 (Litres)
//ml - 200 (ml), 315 (mls)
replace value = value/1000 if numunitid == 200 | numunitid == 315
gen fev1_L = value if fev1 == 1 & (numunitid == 160 | numunitid == 166 | numunitid == 167 | numunitid == 200 | numunitid == 315)


//FEV1 predicted
tab numunitid if fev1_predicted == 1, missing
tab numunitid if fev1_predicted == 1 ///
				& (numunitid == 160 ///
					| numunitid == 166 ///
					| numunitid == 167 ///
					| numunitid == 200 ///
					| numunitid == 315)
//L - 160 (l), 166 (litre), 167 (Litres)
//ml - 200 (ml), 315 (mls)
**already converted ml to l**
gen fev1pred_L = value if fev1_predicted == 1 & (numunitid == 160 | numunitid == 166 | numunitid == 167 | numunitid == 200 | numunitid == 315)


//FEV1 % predicted
tab numunitid if fev1_percent_pred == 1, missing
tab numunitid if fev1_percent_pred == 1 ///
				& (numunitid == 1 ///
					| numunitid == 246 ///
					| numunitid == 1727 ///
					| numunitid == 2629 ///
					| numunitid == 7344)
//% - 1 (%), 246 (per cent), 1727 (% predicted), 2629 (% Pred FEV1), 7344 (%predicted)
gen fev1_pp = value if numunitid == 1 | numunitid == 246 | numunitid == 1727 | numunitid == 2629 | numunitid == 7344


//Height
tab numunitid if height == 1, missing
tab numunitid if height == 1 ///
				& (numunitid == 122 ///
					| numunitid == 173 ///
					| numunitid == 408 ///
					| numunitid == 432)
//cm - 122 (cm), 408 (cms)
//m - 173 (m), 432 (metres)
replace value = value*100 if numunitid == 173 | numunitid == 432
gen height_cm = value if height == 1 & (numunitid == 122 | numunitid == 173 | numunitid == 408 | numunitid == 432)


codebook fev1_L fev1pred_L fev1_pp height_cm

drop if fev1_L == . & fev1pred_L == . & fev1_pp == . & height_cm == .


//clean values
sum fev1_L, detail
replace fev1_L = . if value > 7
replace fev1_L = . if value < 0.1
drop if fev1 == 1 & fev1_L == .

sum fev1pred_L, detail
replace fev1pred_L = . if value > 7
replace fev1pred_L = . if value < 0.1
drop if fev1_predicted == 1 & fev1pred_L == .

sum fev1_pp, detail
replace fev1_pp = . if value > 151
replace fev1_pp = . if value < 8
drop if fev1_percent_pred == 1 & fev1_pp == .

sum height_cm, detail
replace height_cm = . if value > 250
replace height_cm = . if value < 50
drop if height == 1 & height_cm == .

sum fev1_L fev1pred_L fev1_pp height_cm, detail


//Calulcate age at measurement
gen age_at_spirom = obsdate - dob
replace age_at_spirom = round(age_at_spirom/365.25)

//calculcate predicted FEV1
gen pred_fev1 = (4.3*height_cm) - (0.0290*age_at_spirom) - 2.490 if gender == 1
replace pred_fev1 = (3.95*height_cm) - (0.025*age_at_spirom) - 2.6 if gender == 2

/*
**COLLAPSE TO GET FEV1 and predicted FEV1 on the same row**


//calculated FEV1 % predicted
gen fev1pp_calc = round((fev1_L/fev1pred_L)*100) if fev1 == 1

sum fev1_pp fev1pp_calc, detail

replace fev1pp_calc = . if fev1pp_calc > 151 
replace fev1pp_calc = . if fev1pp_calc < 8 

sum fev1_pp fev1pp_calc, detail

replace fev1pp_calc = fev1_pp if fev1pp_calc == . 
drop if fev1pp_calc == .
*/

//most recent FEV1 % predicted at time of prevalence calculation
forvalues year = `first_year'/`last_year' {
	
	gen fev1pp`year' = fev1_pp if obsdate <= mdy(`month', 1, `year')
}


//collapse to one row per patient
collapse (lastnm) fev1pp2000 fev1pp2001 fev1pp2002 fev1pp2003 fev1pp2004 fev1pp2005 fev1pp2006 fev1pp2007 fev1pp2008 fev1pp2009 fev1pp2010 fev1pp2011 fev1pp2012 fev1pp2013 fev1pp2014 fev1pp2015 fev1pp2016 fev1pp2017 fev1pp2018 fev1pp2019, by(patid)

compress

tempfile temp_fev1pp
save `temp_fev1pp'


// Merge in variables
//====================
use builds/cohort_copd_stratvars, clear


foreach var in mrc fev1fvc fev1pp {
	
	merge 1:1 patid using `temp_`var'', nogenerate keep(match master)
}


compress
save builds/cohort_copd_stratvars_value, replace

log close