clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CompactDrugIssue", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts


//For each of the cohorts
forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
	}

	//Shrink the size of the files to make merging easier
	forvalues part = 1/`split' {
		
		display "Importing cohort`cohort' split part: `part'"
		use stata_data/DrugIssue`cohort'_`part', clear
		
		count

		//remove any unneeded variables
		drop issueid pracid probobsid drugrecid enterdate staffid ///
		dosageid duration estnhscost
		
		//remove implausible dates to free up space
		drop if issuedate < date("01/01/1920", "DMY")
		drop if issuedate > `study_end'
		
		//Save for all parts except the last
		if `part' != `split' {
			
			tempfile obs`part'
			display "Saving cohort`cohort' split part: `part'"
			save `obs`part''
		}
	}

	forvalues part = `split'(-1)2 {
		
		local previous_part = `part' - 1
		
		display "Appending cohort`cohort' split part: `previous_part'"
		append using `obs`previous_part''
		erase `obs`previous_part''
	}
	
	count
	
	save stata_data/DrugIssue`cohort'_compact, replace
}


log close