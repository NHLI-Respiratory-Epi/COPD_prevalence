clear all
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"


do build_scripts/ImportPractice
do build_scripts/ImportStaff
do build_scripts/ImportPatient
do build_scripts/ImportReferral
do build_scripts/ImportProblem
do build_scripts/ImportConsultation
do build_scripts/ImportDrugIssue
do build_scripts/ImportObservation