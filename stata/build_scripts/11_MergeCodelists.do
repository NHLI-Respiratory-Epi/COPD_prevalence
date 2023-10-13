clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/MergeCodelists", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts


//= Compact codelists ==========================================================

//Lists for COPD diagnosis

use "`analysis_dir'/codelists/COPD_validated_aurum_2021-10-21", clear

keep medcodeid

generate byte copd_validated = 1

compress
save "`analysis_dir'/codelists/compact/COPD_validated_aurum_2021-10-21", replace



use "`analysis_dir'/codelists/COPD_QOF_v46", clear

keep medcodeid

generate byte copd_qof = 1

compress
save "`analysis_dir'/codelists/compact/COPD_QOF_v46", replace



use "`analysis_dir'/codelists/COPD_symptoms", clear

keep medcodeid cough dyspnoea sputum

compress
save "`analysis_dir'/codelists/compact/COPD_symptoms", replace



use "`analysis_dir'/codelists/smoking_status_update/smoking_status", clear

codebook smoking_status

keep if smoking_status != .

keep medcodeid smoking_status

compress
save "`analysis_dir'/codelists/compact/smoking_status", replace



use "`analysis_dir'/codelists/asthma_codes_for_current_cases_189", clear

keep medcodeid asthma

compress
save "`analysis_dir'/codelists/compact/asthma_codes_for_current_cases_189", replace



use "`analysis_dir'/codelists/COPD_meds_combined", clear

keep prodcodeid groups   //DrugIssue codelist

compress
save "`analysis_dir'/codelists/compact/COPD_meds_combined", replace


//Stratification vars

use "`analysis_dir'/codelists/pulmonary_rehabilitation_referral"

keep medcodeid referred considered commenced completed

gen byte pr = 1

compress
save "`analysis_dir'/codelists/compact/pulmonary_rehabilitation_referral", replace



use "`analysis_dir'/codelists/ethnicity"

keep medcodeid eth5

compress
save "`analysis_dir'/codelists/compact/ethnicity", replace



use "`analysis_dir'/codelists/Exacerbations"

keep medcodeid category

compress
save "`analysis_dir'/codelists/compact/Exacerbations", replace



use "`analysis_dir'/codelists/Exacerbations_prescriptions"

rename prodcode prodcodeid
keep prodcodeid category_rx   //DrugIssue codelist

compress
save "`analysis_dir'/codelists/compact/Exacerbations_prescriptions", replace


//Additional  vars

use "`analysis_dir'/codelists/new/AECOPD"

keep medcodeid aecopd

keep if aecopd == 1

compress
save "`analysis_dir'/codelists/compact/AECOPD", replace



use "`analysis_dir'/codelists/new/breathlessness"

keep medcodeid aecopd_breathlessness copd_chronic_breathlessness

keep if aecopd_breathlessness == 1 | copd_chronic_breathlessness == 1

compress
save "`analysis_dir'/codelists/compact/breathlessness", replace



use "`analysis_dir'/codelists/new/COPD_annual_review"

keep medcodeid

gen byte copd_annualreview = 1

compress
save "`analysis_dir'/codelists/compact/annual_review", replace



use "`analysis_dir'/codelists/new/COPD_incident"

keep medcodeid

gen byte copd_incident = 1

compress
save "`analysis_dir'/codelists/compact/COPD_incident", replace



use "`analysis_dir'/codelists/new/LRTI_bacterial_viral"

keep medcodeid pneumonia lrti bacterial viral

compress
save "`analysis_dir'/codelists/compact/LRTI_bacterial_viral", replace



use "`analysis_dir'/codelists/new/respiratory_bacteria_infection"

keep medcodeid

gen byte bacteria = 1

compress
save "`analysis_dir'/codelists/compact/respiratory_bacteria", replace



use "`analysis_dir'/codelists/new/respiratory_virus_infection"

keep medcodeid

gen byte virus = 1

compress
save "`analysis_dir'/codelists/compact/respiratory_viruses", replace


//==============================================================================


//Reduce the size of the Observation file

forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
	}
	
	use stata_data/Observation`cohort'_compact, clear

	//this is needed for stratifying vars - split in to 2 do files
	drop value numunitid  //not needed to define cohorts


	//Merge with compact codelists
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/COPD_validated_aurum_2021-10-21", ///
	nogenerate keep(match master)

	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/COPD_QOF_v46", ///
	nogenerate keep(match master)

	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/COPD_symptoms", ///
	nogenerate keep(match master)

	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/smoking_status", ///
	nogenerate keep(match master)

	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/asthma_codes_for_current_cases_189", ///
	nogenerate keep(match master)

	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/pulmonary_rehabilitation_referral", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/ethnicity", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/Exacerbations", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/AECOPD", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/breathlessness", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/annual_review", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/COPD_incident", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/LRTI_bacterial_viral", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/respiratory_bacteria", ///
	nogenerate keep(match master)
	
	merge m:1 medcodeid using ///
	"`analysis_dir'/codelists/compact/respiratory_viruses", ///
	nogenerate keep(match master)


	drop if copd_validated == . ///
			& copd_qof == . ///
			& cough == . & dyspnoea == . & sputum == . ///
			& smoking_status == . ///
			& asthma == . ///
			& pr == . ///
			& eth5 == . ///
			& category == . ///
			& aecopd == . ///
			& aecopd_breathlessness == . & copd_chronic_breathlessness == . ///
			& copd_annualreview == . ///
			& copd_incident == . ///
			& pneumonia == . & lrti == . & bacterial == . & viral == . ///
			& bacteria == . ///
			& virus == .

	compress
	save builds/Observation`cohort'_compact_codelists, replace
}



//Reduce the size of the DrugIssue file

forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
	}
	
	use stata_data/DrugIssue`cohort'_compact, clear


	drop quantity quantunitid  //not needed to define cohorts


	//Merge with compact codelists
	merge m:1 prodcodeid using ///
	"`analysis_dir'/codelists/compact/COPD_meds_combined", ///
	nogenerate keep(match master)
	
	merge m:1 prodcodeid using ///
	"`analysis_dir'/codelists/compact/Exacerbations_prescriptions", ///
	nogenerate keep(match master)


	drop if groups == . & category_rx == .

	compress
	save builds/DrugIssue`cohort'_compact_codelists, replace
}



//Combine Observation and DrugIssue files
foreach file in Observation DrugIssue {

	use builds/`file'_compact_codelists, clear

	if `cohorts' > 1 {
		
		forvalues i = 2/`cohorts' {
			
			append using builds/`file'`i'_compact_codelists
		}
	}

	save builds/`file'_compact_all, replace
}


log close