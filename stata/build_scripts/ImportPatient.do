clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportPatient", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "Patient"
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
		
		import delimited raw_data/extract/`prefix'`cohort'_Extract_`file'_`str_part'.txt, stringcols(1) clear
		
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


	//Shouldn't be any month of birth data as everyone is over 16
	//no variable


	//Format dates - requires cprddate ADO file (assumes DMY)
	cprddate emis_ddate regstartdate regenddate cprd_ddate


	//Label categorical vars using lookup files
	cprdlabel gender, lookup("Gender") location("`lookup_dir'")
	cprdlabel patienttypeid, lookup("PatientType") location("`lookup_dir'")


	label var patid          "Patient identifier"
	label var pracid         "CPRD practice identifier"
	label var usualgpstaffid "Usual GP"
	label var gender         "Gender"
	label var yob            "Year of birth"
	label var mob            "Month of birth"
	label var emis_ddate     "Date of death"
	label var regstartdate   "Registration start date"
	label var patienttypeid  "Patient type"
	label var regenddate     "Registration end date"
	label var acceptable     "Acceptable flag"
	label var cprd_ddate     "CPRD death date"


	gsort patid


	//Remove patients that don't meet acceptable data quality standards
	tab acceptable, missing
	drop if acceptable == 0
	drop acceptable


	codebook mob
	drop mob  //COPD population - adults only


	compress
	save stata_data/`file'`cohort', replace
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close

