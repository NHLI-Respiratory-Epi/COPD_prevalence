clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/MergeValueCodelists", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts


// Compact codelists
//===================

use "`analysis_dir'/codelists/mrc_dyspnoea_scale"

keep medcodeid mrc mmrc emrc mrc_dyspnoea_scale mmrc_dyspnoea_scale emrc_dyspnoea_scale

gen byte mrc_all = 1

compress
save "`analysis_dir'/codelists/compact/mrc_dyspnoea_scale", replace



use "`analysis_dir'/codelists/spirometry"

keep medcodeid fev1 fev1_predicted fev1_percent_pred fvc fvc_predicted fvc_percent_pred fev1_fvc_ratio fev1_fvc_ratio_predicted fev1_fvc_ratio_percent_pred bronchdil generalspirom

gen byte spirom_all = 1

compress
save "`analysis_dir'/codelists/compact/spirometry", replace



use "`analysis_dir'/codelists/Height_PWS"

keep medcodeid height

compress
save "`analysis_dir'/codelists/compact/height", replace



use "`analysis_dir'/codelists/Weight_PWS"

keep medcodeid weight

compress
save "`analysis_dir'/codelists/compact/weight", replace



// Reduce the size of the Observation file
//=========================================

forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
	}
	
	use stata_data/Observation`cohort'_compact, clear


	//Merge with compact codelists
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/mrc_dyspnoea_scale", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/spirometry", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/height", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/weight", ///
	nogenerate keep(match master)


	drop if mrc_all == . & spirom_all == . & height == . & weight == .

	compress
	save builds/Observation`cohort'_compactvalue_codelists, replace
}



// Combine Observation files
//===========================

use builds/Observation_compactvalue_codelists, clear

if `cohorts' > 1 {
	
	forvalues i = 2/`cohorts' {
		
		append using builds/Observation`i'_compactvalue_codelists
	}
}

save builds/Observation_compactvalue_all, replace


log close