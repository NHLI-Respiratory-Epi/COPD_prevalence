clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/BuildCOPDCohort", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts


use builds/cohort, clear


//Merge with observation file that includes codelists
merge 1:m patid using builds/Observation_compact_all
keep if _merge == 3
drop _merge

gsort patid obsdate


//Get first event for each definition in Observation file
foreach var in copd_validated copd_qof cough copd_chronic_breathlessness sputum smoking_status asthma {
	
	preserve

	keep if `var' != .
	
	if inlist("`var'", "copd_validated", "copd_qof") {
		
		display "Number of `var' events before year of 40th birthday."
		
		//Remove events before year of 40th birthday
		count if obsdate < mdy(1, 1, yob+40)
		//drop if obsdate < mdy(1, 1, yob+40)
	}
	else if inlist("`var'", "cough", "copd_chronic_breathlessness", "sputum") {
		
		display "Removing `var' events before year of 40th birthday..."
		
		drop if obsdate < mdy(1, 1, yob+40)
	}
	else if "`var'" == "smoking_status" {
		
		display "Removing non-smoker events."
		
		label list smoking_status
		tab smoking_status
		drop if smoking_status == 1
	}
	
	by patid: keep if _n == 1

	generate `var'_1st = obsdate
	format %td `var'_1st

	keep patid `var'_1st
	
	tempfile tmp_`var'
	save `tmp_`var''

	restore
}


use builds/cohort, clear


//Merge with Drug Issue file that includes codelists
merge 1:m patid using builds/DrugIssue_compact_all
keep if _merge == 3
drop _merge

gsort patid issuedate


//Give the label a better name
label list lab1
label copy lab1 copd_meds
label values groups copd_meds
label drop lab1

//Get first event for each definition in DrugIssue file
keep if groups > 2 & groups < 9
tab groups

by patid: keep if _n == 1

tab groups, missing

generate inhaler_1st = issuedate
format %td inhaler_1st

keep patid inhaler_1st

tempfile tmp_inhaler
save `tmp_inhaler'


//Add vars to cohort
use builds/cohort, clear

foreach var in copd_validated copd_qof cough copd_chronic_breathlessness sputum smoking_status asthma inhaler {
	
	merge 1:1 patid using `tmp_`var'', nogenerate keep(match master)
	
	if inlist("`var'", "copd_validated", "copd_qof") {
		
		gen `var'_age = year(`var'_1st) - yob  //everyone born on 1st Jan
	}
}

//Make sure at least 40 years old at diagnosis
summarize copd_validated_age copd_qof_age, detail

count if copd_validated_age < 40
count if copd_qof_age < 40
//replace copd_validated_1st = . if copd_validated_age < 40
//replace copd_qof_1st = . if copd_qof_age < 40

preserve

keep if copd_validated_age < 40 | copd_qof_age < 40
keep patid
count

gen byte exclude = 1

save builds/patients_to_exclude, replace

restore

drop if copd_validated_age < 40 | copd_qof_age < 40


compress
save builds/cohort_copd, replace

log close