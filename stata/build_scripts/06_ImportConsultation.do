clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportConsultation", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "Consultation"
//local parts = 22   //for multiple cohorts update in loop

local prefix = "copdme"
local cohorts = 5



forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
		
		local parts = 23
	}
	else if `cohort' == 2 {
		
		local parts = 25
	}
	else if `cohort' == 3 {
		
		local parts = 23
	}
	else if `cohort' == 4 {
		
		local parts = 24
	}
	else if `cohort' == 5 {
		
		local parts = 21
	}


	//Import file parts
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
		
		import delimited raw_data/extract/`prefix'`cohort'_Extract_`file'_`str_part'.txt, stringcols(1 2 9) clear
		
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
	cprddate consdate enterdate


	//Label categorical vars using lookup files
	//cprdlabel conssourceid, lookup("ConsSource") location("`lookup_dir'")
	
	//command above does not work because too many values
	//so run manually and remove "Awaiting review" entries
	preserve

	local lookup "ConsSource"
	import delimited "`lookup_dir'/`lookup'.txt", varnames(nonames) rowrange(2) clear
	drop if v2 == "Awaiting review"

	quietly count
	local n = `r(N)'
	forvalues i = 1/`n' {

		label define `lookup' `=v1[`i']' "`=v2[`i']'", add
	}

	tempfile `lookup'lbl
	label save using ``lookup'lbl', replace

	restore

	//Apply labels
	do ``lookup'lbl'
	label values conssourceid `lookup'


	label var patid         "Patient identifier"
	label var consid        "Consultation identifier"
	label var pracid        "CPRD practice identifier"
	label var consdate      "Event date"
	label var enterdate     "Entered date"
	label var staffid       "Staff identifier"
	label var conssourceid  "EMIS consultation source identifier"
	label var cprdconstype  "CPRD consultation source identifier"
	label var consmedcodeid "Consultation source code identifier (medcodeid)"


	tab cprdconstype, missing
	drop cprdconstype   //not included in initial release - useless


	compress
	save stata_data/`file'`cohort', replace
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
