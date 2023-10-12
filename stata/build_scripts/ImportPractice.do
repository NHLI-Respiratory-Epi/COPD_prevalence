clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportPractice", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "Practice"
local parts = 1

local prefix = "copdme"
local cohorts = 5



forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
	}


	//Import file
	forvalues part = 1/`parts' {
		
		if `part' < 10 {
			
			local str_part = "00`part'"
		}
		else if `part' < 100 {
			
			local str_part = "0`part'"
		}
		else {
			
			local str_part = "`part'"
		}

		display "Importing `file' part: `str_part'"
		
		import delimited raw_data/extract/`prefix'`cohort'_Extract_`file'_`str_part'.txt, clear
		
		tempfile data`part'
		save `data`part''
	}


	//Merge file parts in to one big file
	forvalues part = `parts'(-1)1 {
		
		if `part' > 1 {
			
			local previous_part = `part'-1
			
			display "Appending part `previous_part'"
			
			append using `data`previous_part''
		}
		else {
			
			display "Appending complete."
		}
	}


	//Format dates - requires cprddate ADO file (assumes DMY)
	cprddate lcd


	//Label categorical vars using lookup files
	cprdlabel region, lookup("Region") location("`lookup_dir'")


	label var pracid "CPRD practice identifier"
	label var lcd    "Last Collection Date"
	label var uts    "Up-to-standard date"
	label var region "Region"


	gsort pracid

	codebook uts   //not generated yet
	drop uts

	compress
	save stata_data/`file'`cohort', replace
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
