clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/StratificationVars", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts

local month = 7


use builds/cohort_copd, clear

keep patid

//Merge with Observation file that includes codelists
merge 1:m patid using builds/Observation_compact_all
keep if _merge == 3
drop _merge

gsort patid obsdate


preserve


// Ethnicity
//===========
drop if eth5 == .
keep patid obsdate eth5

gsort patid -obsdate  //most recent first

by patid: gen patobs = _N

//count of each ethnicity
by patid: egen whitecount = count(eth5) if eth5 == 0
by patid: egen southasiancount = count(eth5) if eth5 == 1
by patid: egen blackcount = count(eth5) if eth5 == 2
by patid: egen othercount = count(eth5) if eth5 == 3
by patid: egen mixedcount = count(eth5) if eth5 == 4
by patid: egen notstatedcount = count(eth5) if eth5 == 5

//total columns for each patient
by patid: egen whitemax = max(whitecount)
by patid: egen southasianmax = max(southasiancount)
by patid: egen blackmax = max(blackcount)
by patid: egen othermax = max(othercount)
by patid: egen mixedmax = max(mixedcount)
by patid: egen notstatedmax = max(notstatedcount)

foreach var of varlist whitemax southasianmax blackmax othermax mixedmax notstatedmax {
	
	replace `var' = 0 if `var' == .
}

//generate global ethnicity
drop whitecount southasiancount blackcount othercount mixedcount notstatedcount

//if all ethnicities are the same, set that as ethnicity
gen ethnicity = eth5 if patobs == whitemax ///
					  | patobs == southasianmax ///
					  | patobs == blackmax ///
					  | patobs == othermax ///
					  | patobs == mixedmax ///
					  | patobs == notstatedmax

label values ethnicity eth5

//where there are multiple ethnicities, choose the most common one
replace ethnicity = 0 if whitemax > southasianmax ///
					   & whitemax > blackmax ///
					   & whitemax > othermax ///
					   & whitemax > mixedmax

replace ethnicity = 1 if southasianmax > whitemax ///
					   & southasianmax > blackmax ///
					   & southasianmax > othermax ///
					   & southasianmax > mixedmax

replace ethnicity = 2 if blackmax > whitemax ///
					   & blackmax > southasianmax ///
					   & blackmax > othermax ///
					   & blackmax > mixedmax

replace ethnicity = 3 if othermax > whitemax ///
					   & othermax > southasianmax ///
					   & othermax > blackmax ///
					   & othermax > mixedmax

replace ethnicity = 4 if mixedmax > whitemax ///
					   & mixedmax > southasianmax ///
					   & mixedmax > blackmax ///
					   & mixedmax > othermax
					   
//where there are 2 or more equally common ethnicities, choose the most recent
drop if ethnicity == . & eth5 == 5  //get rid of "Not stated" options
by patid: keep if _n == 1
replace ethnicity = eth5 if ethnicity == .

keep patid ethnicity

compress

tempfile temp_ethnicity
save `temp_ethnicity'


restore, preserve


// Pulmonary rehabilitation status
//=================================
drop if pr == .

//not interested in "considered" for referral
keep if referred == 1 | commenced == 1 | completed == 1

keep patid obsdate referred commenced completed

replace referred = obsdate if referred == 1
replace commenced = obsdate if commenced == 1
replace completed = obsdate if completed == 1

format %td referred commenced completed

by patid: egen pr_referred = min(referred)
by patid: egen pr_commenced = min(commenced)
by patid: egen pr_completed = min(completed)

format %td pr_referred pr_commenced pr_completed

by patid: keep if _n == 1

keep patid pr_referred pr_commenced pr_completed

//fix multiple classifications
replace pr_referred = . if pr_referred >= pr_commenced ///
						 | pr_referred >= pr_completed

replace pr_commenced = . if pr_commenced >= pr_completed

compress

tempfile temp_pr
save `temp_pr'


restore, preserve


// Smoking status
//================
drop if smoking_status == .
keep patid obsdate smoking_status

//most recent smoking status at time of prevalence calculation
forvalues year = 2000/2020 {
	
	gen smoking_status`year' = smoking_status if obsdate <= mdy(`month', 1, `year')
}

label values smoking_status20* smoking_status

//collapse to one row per patient
collapse (lastnm) smoking_status20*, by(patid)

label values smoking_status20* smoking_status

//change never smokers to ex-smokers if they have a history of smoking
forvalues year = 2000/2020 {
	
	if `year' > 2000 {
		
		local prev_year = `year'-1
		
		replace smoking_status`year' = 2 if smoking_status`year' == 1 ///
										  & (smoking_status`prev_year' == 2 ///
											 | smoking_status`prev_year' == 3)
	}
}

compress

tempfile temp_smoking
save `temp_smoking'


restore


// Exacerbations in the last year (categorical)
//==============================================

/* AECOPD ALGORITHM:
*
*	Excluding annual review days:
*		- ABX and OCS for 5–14 days; or
*		- Symptom (2+) definition with prescription of antibiotic or OCS; or
*		- LRTI code; or
*		- AECOPD code
*
*/

drop if copd_annualreview == . & cough == . & aecopd_breathlessness == . & sputum == . & lrti == . & aecopd == .
keep patid obsdate copd_annualreview cough aecopd_breathlessness sputum lrti aecopd

compress

tempfile aecopd_lrti
save `aecopd_lrti'


//Get drug codes
use builds/cohort_copd, clear

keep patid

//Merge with DrugIssue file that includes codelists
merge 1:m patid using builds/DrugIssue_compact_all
keep if _merge == 3
drop _merge

gsort patid issuedate


preserve


drop if category_rx == .
keep patid issuedate category_rx

rename issuedate obsdate
append using `aecopd_lrti'

gsort patid obsdate

label list category_rx

gen byte abx = 1 if category_rx == 1
gen byte ocs = 1 if category_rx == 2
order cough aecopd_breathlessness sputum, after(ocs)

//collapse to get all events on the same day
collapse (max) copd_annualreview abx ocs cough aecopd_breathlessness sputum lrti aecopd, by(patid obsdate)

//remove events on an annual review day
drop if copd_annualreview == 1
drop copd_annualreview

egen symptoms = rowtotal(cough aecopd_breathlessness sputum)
order symptoms, after(sputum)

//only keep days where both antibiotics and oral corticosteroids were prescribed, patient had 2 symptoms and an antibiotic or oral corticosteroid prescribed, or a patient received an AECOPD or LRTI code
keep if (abx == 1 & ocs == 1) ///
	  | (symptoms >= 2 & (abx == 1 | ocs == 1)) ///
	  | aecopd == 1 ///
	  | lrti == 1

//count events as exacerbations, excluding those closer together than 14 days
by patid: gen exacerbation = 1 if _n == 1 | obsdate[_n-1] < obsdate-14

//exacerbations in each year
forvalues year = 2000/2020 {
	
	gen exacerbations`year' = 1 if exacerbation == 1 ///
								& obsdate > mdy(`month', 1, `year'-1) ///
								& obsdate <= mdy(`month', 1, `year')
}

//collapse to get exacerbation count per year for each patient
collapse (sum) exacerbations20*, by(patid)

compress

tempfile temp_aecopd
save `temp_aecopd'


restore


// Inhaled therapy (dual therapy vs. triple therapy)
//===================================================
drop if groups == .
keep patid issuedate groups

label list lab1

//just keep LABA, LAMA, and ICS inhalers
tab groups, missing
keep if groups >= 3 & groups <= 8
tab groups, missing

gen ics = issuedate if groups == 6 | groups == 7 | groups == 8
gen laba = issuedate if groups == 4 | groups == 5 | groups == 7 | groups == 8
gen lama = issuedate if groups == 3 | groups == 5 | groups == 8

format %td ics laba lama

//Therapy received in year until time of prevalence calculation
forvalues year = 2000/2020 {
	
	gen ics`year' = 1 if ics > mdy(`month', 1, `year'-1) ///
					   & ics <= mdy(`month', 1, `year')
	
	gen laba`year' = 1 if laba > mdy(`month', 1, `year'-1) ///
						& laba <= mdy(`month', 1, `year')
	
	gen lama`year' = 1 if lama > mdy(`month', 1, `year'-1) ///
						& lama <= mdy(`month', 1, `year')
}

//collapse to one row per patient
collapse (max) ics20* laba20* lama20*, by(patid)

order ics2000 laba2000 lama2000 ics2001 laba2001 lama2001 ics2002 laba2002 lama2002 ics2003 laba2003 lama2003 ics2004 laba2004 lama2004 ics2005 laba2005 lama2005 ics2006 laba2006 lama2006 ics2007 laba2007 lama2007 ics2008 laba2008 lama2008 ics2009 laba2009 lama2009 ics2010 laba2010 lama2010 ics2011 laba2011 lama2011 ics2012 laba2012 lama2012 ics2013 laba2013 lama2013 ics2014 laba2014 lama2014 ics2015 laba2015 lama2015 ics2016 laba2016 lama2016 ics2017 laba2017 lama2017 ics2018 laba2018 lama2018 ics2019 laba2019 lama2019 ics2020 laba2020 lama2020, after(patid)

//Determine whether on dual or triple therapy
forvalues year = 2000/2020 {
	
	gen medication`year' = 1 if ics`year' == . & laba`year' != . & lama`year' != .
	replace medication`year' = 2 if ics`year' != . & laba`year' != . & lama`year' != .
	
	order medication`year', after(lama`year')
}

label define medication 1 "Dual therapy (LABA & LAMA)" 2 "Triple therapy (LABA & LAMA & ICS)"
label values medication20* medication

keep patid medication20*

compress

tempfile temp_medication
save `temp_medication'



// Merge in variables
//====================
use builds/cohort_copd, clear


foreach var in ethnicity pr smoking aecopd medication {
	
	merge 1:1 patid using `temp_`var'', nogenerate keep(match master)
}


order ethnicity, after(imd2015_5)


compress
save builds/cohort_copd_stratvars, replace


log close