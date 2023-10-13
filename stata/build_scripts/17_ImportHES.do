clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/ImportHES", text replace

local lookup_dir "Z:\Database guidelines and info\CPRD\CPRD_Latest_Lookups_Linkages_Denominators\Aurum_Lookups_May_2021"
local linked_dir "E:\AUK-BLF COPD Prevalence\CPRD Full Linked Data (2)\21_000596_Results\Aurum_linked\Final"

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts


import delimited "`linked_dir'/hes_diagnosis_epi_21_000596_request2_DM.txt", clear stringcols(1 3)

cprddate epistart epiend

compress
save stata_data/HES_episode_diagnoses, replace


merge m:1 icd using "`analysis_dir'/codelists/COPD_ICD10"
keep if _merge == 3
drop _merge desc

compress
save builds/HES_episode_COPD, replace


log close