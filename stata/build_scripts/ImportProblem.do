clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportProblem", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "Problem"
local parts = 2

local prefix = "copdme"
local cohorts = 5



forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
		
		local parts = 3
	}
	else if `cohort' == 2 {
		
		local parts = 3
	}
	else if `cohort' == 3 {
		
		local parts = 3
	}
	else if `cohort' == 4 {
		
		local parts = 3
	}
	else if `cohort' == 5 {
		
		local parts = 2
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
		
		import delimited raw_data/extract/`prefix'`cohort'_Extract_`file'_`str_part'.txt, stringcols(1 2 4) clear
		
		tempfile data`part'
		save `data`part''
	}

	local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
	display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"


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

	local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
	display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"


	//Format dates - requires cprddate ADO file (assumes DMY)
	cprddate probenddate lastrevdate


	//Label categorical vars using lookup files
	cprdlabel parentprobrelid, lookup("ParentProbRel") location("`lookup_dir'")
	cprdlabel probstatusid, lookup("ProbStatus") location("`lookup_dir'")
	cprdlabel signid, lookup("Sign") location("`lookup_dir'")


	label var patid           "Patient identifier"
	label var obsid           "Observation identifier"
	label var pracid          "CPRD practice identifier"
	label var parentprobobsid "Parent problem observation identifier"
	label var probenddate     "Problem end date"
	label var expduration     "Expected duration"
	label var lastrevdate     "Last review date"
	label var lastrevstaffid  "Last review staff identifier"
	label var parentprobrelid "Parent problem relationship identifier"
	label var probstatusid    "Problem status identifier"
	label var signid          "Significance"


	compress
	save stata_data/`file'`cohort', replace
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
