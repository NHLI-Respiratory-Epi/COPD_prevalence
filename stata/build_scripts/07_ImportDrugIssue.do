clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local tstart = clock("$S_DATE $S_TIME", "DMY hms")

local data_dir "E:\AUK-BLF COPD Prevalence"
local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportDrugIssue", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "DrugIssue"
//local parts = 96
local split = 4

local prefix = "copdme"
local cohorts = 5


forvalues cohort = 1/`cohorts' {
	
	if `cohort' == 1 {
		
		local cohort = ""
		
		local parts = 83
	}
	else if `cohort' == 2 {
		
		local parts = 79
	}
	else if `cohort' == 3 {
		
		local parts = 76
	}
	else if `cohort' == 4 {
		
		local parts = 76
	}
	else if `cohort' == 5 {
		
		local parts = 71
	}
	
	
	if `split' > `parts' {
	
		display as error "More splits than files. Please change the number of splits."
		error
	}


	forvalues split_part = 1/`split' {
		
		display "Split part: " `split_part'
		
		local start = floor(`parts'/`split') * (`split_part' - 1) + 1
		display "Start part: " `start'
		
		if `split_part' == `split' {
			
			local end = `parts'
		}
		else {
			
			local end = floor(`parts'/`split') * (`split_part')
		}
		
		display "End part: " `end'
		display


		//Import file
		forvalues part = `start'/`end' {
			
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
			
			import delimited ///
			"`data_dir'/raw_data/`prefix'`cohort'_Extract_`file'_`str_part'.txt", ///
			stringcols(1 2 4 9) clear
			
			tempfile data`part'
			save `data`part''
		}

		local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `tstart'
		display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"


		//Merge file parts in to one big file
		forvalues part = `end'(-1)`start' {
			
			if `part' > `start' {
				
				local previous_part = `part'-1
				
				display "Appending part `previous_part'"
				
				append using `data`previous_part''
			}
			else {
				
				display "Appending complete."
			}
		}

		local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `tstart'
		display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"


		//Format dates - requires cprddate ADO file (assumes DMY)
		cprddate issuedate enterdate


		//Label categorical vars using lookup files
		cprdlabel quantunitid, lookup("QuantUnit") location("`lookup_dir'")


		label var patid       "Patient identifier"
		label var issueid     "Issue record identifier"
		label var pracid      "CPRD practice identifier"
		label var probobsid   "Problem observation identifier"
		label var drugrecid   "Drug record identifier"
		label var issuedate   "Event date"
		label var enterdate   "Entered date"
		label var staffid     "Staff identifier"
		label var prodcodeid  "Drug code identifier"
		label var dosageid    "Dosage identifier"
		label var quantity    "Quantity"
		label var quantunitid "Quantity unit identifier"
		label var duration    "Course duration in days"
		label var estnhscost   "Estimated NHS cost"

		
		display
		display "Useless observations:"
		count if issuedate == .
		drop if issuedate == .


		compress
		save stata_data/`file'`cohort'_`split_part', replace
		
		
		//Clear uneeded tempfiles to free up space
		forvalues part = `start'/`end' {
			
			erase `data`part''
		}
		
		
		local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `tstart'
		display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"
	}
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `tstart'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
