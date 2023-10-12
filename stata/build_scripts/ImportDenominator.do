clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

capture log close
log using "`analysis_dir'/build_logs/ImportDenominator", text replace

local lookup_dir "Z:\Database guidelines and info\CPRD\CPRD_Latest_Lookups_Linkages_Denominators\Aurum_Lookups_May_2021"
local linked_dir "E:\AUK-BLF COPD Prevalence\CPRD Full Linked Data (2)\21_000596_Results\Aurum_linked\Final"

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts



//Open and format denominator file

import delimited CPRD/Aurum_Denominators_May_2021/202105_CPRDAurum_AcceptablePats.txt, stringcols(1)


drop mob  //not needed - only children have month of birth

cprddate emis_ddate regstartdate regenddate cprd_ddate lcd

cprdlabel region, lookup("Region") location("`lookup_dir'")


tab1 gender patienttypeid acceptable region, missing

//reformat gender to have same numeric format as in Patient file
tab gender
replace gender = "1" if gender == "M"
replace gender = "2" if gender == "F"
replace gender = "3" if gender == "I"
replace gender = "4" if gender == "U"
destring gender, replace
cprdlabel gender, lookup("Gender") location("`lookup_dir'")
tab gender

//restrict to male and female patients
tab gender, missing
keep if gender == 1 | gender == 2
tab gender, missing

drop patienttypeid  //all "Regular"
drop acceptable  //all acceptable


summarize yob emis_ddate regstartdate regenddate cprd_ddate uts lcd, format

drop uts  //no up-to-standard date yet in Aurum
drop emis_ddate  //apparently not very reliable, use cprd_ddate instead


//Check all date variables & remove if after cut date (May 2021)
summarize yob regstartdate regenddate cprd_ddate lcd, format detail
drop if regstartdate >= mdy(5, 1, 2021)
drop if regenddate >= mdy(5, 1, 2021) & regenddate != .
drop if cprd_ddate >= mdy(5, 1, 2021) & cprd_ddate != .
drop if lcd >= mdy(5, 1, 2021)
summarize yob regstartdate regenddate cprd_ddate, format


//Assume born on 1st Jan for max follow-up
gen dob = mdy(1, 1, yob)
gen do40 = mdy(1, 1, yob+40)
order dob do40, after(yob)
format %td dob do40


preserve //=====================================================================

//Import linkage information

import delimited "CPRD/Aurum_Linkages_Set_21/linkage_eligibility.txt", clear stringcols(1)

drop death_e cr_e mh_e

cprddate linkdate
tab linkdate, missing
drop linkdate  //they're all the same and this does not affect follow-up time

compress
tempfile link_eligibility
save `link_eligibility'


import delimited "CPRD/Aurum_Linkages_Set_21/linkage_coverage.txt", clear varnames(1)

cprddate start end

compress
tempfile link_coverage
save `link_coverage'

restore //======================================================================


//Merge linkage information with denomiantor file

merge 1:1 patid using `link_eligibility'
keep if _merge == 3
drop _merge


tab1 hes_e lsoa_e, missing
keep if hes_e == 1 & lsoa_e == 1
tab1 hes_e lsoa_e, missing
drop hes_e lsoa_e

gen data_source = "hes_apc"
merge m:1 data_source using `link_coverage'
drop if _merge == 2
drop _merge data_source
rename start hes_start
rename end hes_end


preserve //=====================================================================

//Import HES COPD events provided by CPRD

import delimited "CPRD Linked HES Events (1)/21_000596_CI_Results/21_000596_HESAPC_ICD_events_Aurum.txt", clear stringcols(1)

cprddate epistart
summarize epistart, format detail

//Remove events before 2000 or after 2020
drop if epistart == .
//drop if epistart < `study_start'
drop if epistart > `study_end'

gsort patid epistart
drop icd
by patid: keep if _n == 1

count

gen byte hes_event = 1

tempfile HES_events
save `HES_events'


//Import HES COPD events from linked data (any position)

use builds/HES_episode_COPD, clear

summarize epistart, format detail

//Remove events before 2000 or after 2020
drop if epistart == .
//drop if epistart < `study_start'
drop if epistart > `study_end'

gsort patid epistart

by patid: keep if _n == 1
count

keep patid epistart
rename epistart epistart_any
gen byte hes_copd_any = 1

tempfile HES_COPD_any
save `HES_COPD_any'


//Import HES COPD events from linked data (1st/2nd position only)

use builds/HES_episode_COPD, clear

summarize epistart, format detail

//Remove events before 2000 or after 2020
drop if epistart == .
//drop if epistart < `study_start'
drop if epistart > `study_end'

gsort patid epistart

drop if d_order > 2
tab d_order, missing

by patid: keep if _n == 1
count

keep patid epistart
rename epistart epistart_firstsecond
gen byte hes_copd_firstsecond = 1

tempfile HES_COPD_12
save `HES_COPD_12'


//Import NEW QOF+symptoms extracted CPRD patients

import delimited "Original extracts/define_extra/copdphilam_Define_results.txt", clear stringcols(1)

cprddate indexdate
summarize indexdate, format detail

gen byte cprd_event = 1

tempfile cprd_events
save `cprd_events'


//Import extracted CPRD patients

import delimited "Original extracts/define/copd_Define_results.txt", clear stringcols(1)

cprddate indexdate
summarize indexdate, format detail

gen byte cprdold_event = 1

tempfile cprdold_events
save `cprdold_events'


//Import IMD Data

import delimited "`linked_dir'/patient_imd2015_21_000596_request2.txt", clear stringcols(1)

tempfile imd
save `imd'

restore //======================================================================


//Merge CPRD provided HES patids
merge 1:1 patid using `HES_events'
drop if _merge == 2
drop _merge


//Merge new CPRD primary care events
merge 1:1 patid using `cprd_events'
drop if _merge == 2
drop _merge

//Merge old CPRD primary care events (just for comparison)
merge 1:1 patid using `cprdold_events'
drop if _merge == 2
drop _merge


count
count if cprd_event == 1 | hes_event == 1  //values of interest
compress
save builds/denominator_preexclusions, replace


//Calculate follow-up
//require to be at least 40
//require 1 year of follow-up before entering cohort?
gen start_fu = max(regstartdate+365.25, hes_start, `study_start', do40)
gen end_fu = min(regenddate, cprd_ddate, lcd, hes_end, `study_end')
format %td start_fu end_fu
drop if start_fu >= end_fu

summarize start_fu end_fu, format detail


tab1 cprd_event cprdold_event hes_event, missing

//Patients in either CPRD or HES
count if cprd_event == 1 | hes_event == 1  //values of interest
count if cprdold_event == 1 | hes_event == 1
count if cprd_event == 1 | cprdold_event == 1 | hes_event == 1

//Patients in CPRD but not HES
count if cprd_event == 1 & hes_event == .
count if cprdold_event == 1 & hes_event == .

//Patients in HES but not CPRD
count if cprd_event == . & hes_event == 1
count if cprdold_event == . & hes_event == 1


//Patients in the new cohort but not the old
count if cprd_event == 1 & cprdold_event == .

//Patients in the old cohort but not the new
count if cprd_event == . & cprdold_event == 1


compress
save builds/Denominator, replace


preserve

keep if cprd_event == 1 | hes_event == 1
count
keep patid
export delimited 21_000596_ImperialCollegeLondon_patientlist.txt, delim(tab) replace

restore


//Merge with linked IMD data
merge 1:1 patid using `imd'
drop if _merge == 2
drop _merge


//Merge with linked HES data
merge 1:1 patid using `HES_COPD_any'
drop if _merge == 2
drop _merge

merge 1:1 patid using `HES_COPD_12'
drop if _merge == 2
drop _merge


//Remove excluded patients
merge 1:1 patid using builds/patients_to_exclude, nogenerate keep(match master)
drop if exclude == 1
drop exclude


compress
save builds/Denominator_linked, replace


log close