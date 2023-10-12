clear
set more off

cd "D:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportReferral", text replace

local lookup_dir "D:\AUK-BLF COPD Prevalence\CPRD\Aurum_Lookups_May_2021"

local file "Referral"
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
		
		import delimited raw_data/extract/`prefix'`cohort'_Extract_`file'_`str_part'.txt, stringcols(1 2) clear
		
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


	//Label categorical vars using lookup files
	cprdlabel refsourceorgid, lookup("OrgType") location("`lookup_dir'")
	cprdlabel reftargetorgid, lookup("OrgType") location("`lookup_dir'")
	cprdlabel refurgencyid, lookup("RefUrgency") location("`lookup_dir'")
	cprdlabel refservicetypeid, lookup("RefServiceType") location("`lookup_dir'")
	cprdlabel refmodeid, lookup("RefMode") location("`lookup_dir'")


	label var patid            "Patient identifier"
	label var obsid            "Observation identifier"
	label var pracid           "CPRD practice identifier"
	label var refsourceorgid   "Referral source organisation identifier"
	label var reftargetorgid   "Referral target organisation identifier"
	label var refurgencyid     "Referral urgency identifier"
	label var refservicetypeid "Referral service type identifier"
	label var refmodeid        "Referral mode identifier"


	codebook refsourceorgid reftargetorgid
	drop refsourceorgid reftargetorgid   //no lookup provided yet


	compress
	save stata_data/`file'`cohort', replace
}

local runtime = clock("$S_DATE $S_TIME", "DMY hms") - `start'
display "Runtime: " floor(`runtime'/60000) " minutes " mod(`runtime'/1000, 60) " seconds"

log close
