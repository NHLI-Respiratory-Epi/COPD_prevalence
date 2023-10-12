clear all
set more off

cd "E:\AUK-BLF COPD Prevalence"

local start = clock("$S_DATE $S_TIME", "DMY hms")

local analysis_dir "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

/* Create log file */
capture log close
log using "`analysis_dir'/build_logs/CombineNumeratorDenominator", text replace

local study_start = date("01/01/2000", "DMY")
local study_end = date("31/12/2020", "DMY")

local split = 4   //number of part file is split in to
local cohorts = 5 //number of cohorts



use builds/Denominator_linked, clear
/*
rename regstartdate regstartdate_denom
rename regenddate regenddate_denom
rename cprd_ddate cprd_ddate_denom
rename start_fu start_fu_denom
rename end_fu end_fu_denom
*/

merge 1:1 patid using builds/cohort_copd_stratvars_value
/*
count if _merge == 3 & regstartdate_denom != regstartdate
count if _merge == 3 & regenddate_denom   != regenddate
count if _merge == 3 & cprd_ddate_denom   != cprd_ddate
count if _merge == 3 & start_fu_denom     != start_fu
count if _merge == 3 & end_fu_denom       != end_fu
*/
drop _merge


local month = 7


//Validated COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen copd`year' = 0 if (start_fu <= `date') ///
								& (end_fu >= `date')
	
	replace copd`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date') ///
									& (end_fu >= `date')
	
	tab copd`year'
}


//QOF COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen copdqof`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdqof`year' = 1 if (start_fu <= `date') ///
									& (copd_qof_1st <= `date') ///
									& (end_fu >= `date')
	
	tab copdqof`year'
}


//COPD Symptoms (in those with smoking history, an inhaler, and no asthma)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen copdsymp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdsymp`year' = 1 if (start_fu <= `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date')
	
	tab copdsymp`year'
}


//COPD Symptoms (in those with smoking history, an inhaler, and no asthma)
//IN THOSE WITHOUT A VALIDATED COPD DIAGNOSIS
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen copdsymp_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace copdsymp_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (cough_1st <= `date' ///
										| copd_chronic_breathlessness_1st <= `date' ///
										| sputum_1st <= `date') ///
									& (smoking_status`year' == 2 ///
										| smoking_status`year' == 3) ///
									& (inhaler_1st <= `date') ///
									& (asthma_1st > `date') ///
									& (end_fu >= `date')
	
	tab copdsymp_nodiag`year'
}


//HES COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen hes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes`year' = 1 if (start_fu <= `date') ///
									& (epistart <= `date') ///
									& (end_fu >= `date')
	
	tab hes`year'
}


//HES COPD (any position)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen hesany`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hesany`year' = 1 if (start_fu <= `date') ///
									& (epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab hesany`year'
}


//HES COPD (1st/2nd position only)
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen hes12_`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes12_`year' = 1 if (start_fu <= `date') ///
									& (epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab hes12_`year'
}


//HES COPD (any)
//IN THOSE WITHOUT A DIAGNOSIS IN PRIMARY CARE
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen hes_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab hes_nodiag`year'
}


//HES COPD (1st/2nd)
//IN THOSE WITHOUT A DIAGNOSIS IN PRIMARY CARE
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen hes12_nodiag`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace hes12_nodiag`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st > `date') ///
									& (epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab hes12_nodiag`year'
}


//Validated or HES (any) COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen valhes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab valhes`year'
}


//Validated or HES (1st/2nd) COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen valhes_onetwo`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes_onetwo`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date') ///
									& (end_fu >= `date')
	
	tab valhes_onetwo`year'
}


//QOF or HES COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen qofhes`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace qofhes`year' = 1 if (start_fu <= `date') ///
									& (copd_qof_1st <= `date' ///
										| epistart_any <= `date') ///
									& (end_fu >= `date')
	
	tab qofhes`year'
}


//Validated or HES or Symptoms COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen valhessymp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhessymp`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_any <= `date' ///
										| ((cough_1st <= `date' ///
											| copd_chronic_breathlessness_1st <= `date' ///
											| sputum_1st <= `date') ///
											& (smoking_status`year' == 2 ///
												| smoking_status`year' == 3) ///
											& (inhaler_1st <= `date') ///
											& (asthma_1st > `date'))) ///
									& (end_fu >= `date')
	
	tab valhessymp`year'
}


//Validated or HES (1st/2nd) or Symptoms COPD
forvalues year = 2000/2019 {
	
	local date = mdy(`month', 1, `year')
	
	gen valhes12symp`year' = 0 if (start_fu <= `date') ///
									& (end_fu >= `date')
	
	replace valhes12symp`year' = 1 if (start_fu <= `date') ///
									& (copd_validated_1st <= `date' ///
										| epistart_firstsecond <= `date' ///
										| ((cough_1st <= `date' ///
											| copd_chronic_breathlessness_1st <= `date' ///
											| sputum_1st <= `date') ///
											& (smoking_status`year' == 2 ///
												| smoking_status`year' == 3) ///
											& (inhaler_1st <= `date') ///
											& (asthma_1st > `date'))) ///
									& (end_fu >= `date')
	
	tab valhes12symp`year'
}


save copd_prevalence, replace


collapse (mean) copd2000 copd2001 copd2002 copd2003 copd2004 copd2005 copd2006 copd2007 copd2008 copd2009 copd2010 copd2011 copd2012 copd2013 copd2014 copd2015 copd2016 copd2017 copd2018 copd2019 copdqof2000 copdqof2001 copdqof2002 copdqof2003 copdqof2004 copdqof2005 copdqof2006 copdqof2007 copdqof2008 copdqof2009 copdqof2010 copdqof2011 copdqof2012 copdqof2013 copdqof2014 copdqof2015 copdqof2016 copdqof2017 copdqof2018 copdqof2019 copdsymp2000 copdsymp2001 copdsymp2002 copdsymp2003 copdsymp2004 copdsymp2005 copdsymp2006 copdsymp2007 copdsymp2008 copdsymp2009 copdsymp2010 copdsymp2011 copdsymp2012 copdsymp2013 copdsymp2014 copdsymp2015 copdsymp2016 copdsymp2017 copdsymp2018 copdsymp2019 copdsymp_nodiag2000 copdsymp_nodiag2001 copdsymp_nodiag2002 copdsymp_nodiag2003 copdsymp_nodiag2004 copdsymp_nodiag2005 copdsymp_nodiag2006 copdsymp_nodiag2007 copdsymp_nodiag2008 copdsymp_nodiag2009 copdsymp_nodiag2010 copdsymp_nodiag2011 copdsymp_nodiag2012 copdsymp_nodiag2013 copdsymp_nodiag2014 copdsymp_nodiag2015 copdsymp_nodiag2016 copdsymp_nodiag2017 copdsymp_nodiag2018 copdsymp_nodiag2019 hes2000 hes2001 hes2002 hes2003 hes2004 hes2005 hes2006 hes2007 hes2008 hes2009 hes2010 hes2011 hes2012 hes2013 hes2014 hes2015 hes2016 hes2017 hes2018 hes2019 hesany2000  hesany2001  hesany2002  hesany2003  hesany2004  hesany2005  hesany2006  hesany2007  hesany2008  hesany2009  hesany2010  hesany2011  hesany2012  hesany2013  hesany2014  hesany2015  hesany2016  hesany2017  hesany2018  hesany2019  hes12_2000  hes12_2001  hes12_2002  hes12_2003  hes12_2004  hes12_2005  hes12_2006  hes12_2007  hes12_2008  hes12_2009  hes12_2010  hes12_2011  hes12_2012  hes12_2013  hes12_2014  hes12_2015  hes12_2016  hes12_2017  hes12_2018  hes12_2019 hes_nodiag2000 hes_nodiag2001 hes_nodiag2002 hes_nodiag2003 hes_nodiag2004 hes_nodiag2005 hes_nodiag2006 hes_nodiag2007 hes_nodiag2008 hes_nodiag2009 hes_nodiag2010 hes_nodiag2011 hes_nodiag2012 hes_nodiag2013 hes_nodiag2014 hes_nodiag2015 hes_nodiag2016 hes_nodiag2017 hes_nodiag2018 hes_nodiag2019 hes12_nodiag2000 hes12_nodiag2001 hes12_nodiag2002 hes12_nodiag2003 hes12_nodiag2004 hes12_nodiag2005 hes12_nodiag2006 hes12_nodiag2007 hes12_nodiag2008 hes12_nodiag2009 hes12_nodiag2010 hes12_nodiag2011 hes12_nodiag2012 hes12_nodiag2013 hes12_nodiag2014 hes12_nodiag2015 hes12_nodiag2016 hes12_nodiag2017 hes12_nodiag2018 hes12_nodiag2019 valhes2000 valhes2001 valhes2002 valhes2003 valhes2004 valhes2005 valhes2006 valhes2007 valhes2008 valhes2009 valhes2010 valhes2011 valhes2012 valhes2013 valhes2014 valhes2015 valhes2016 valhes2017 valhes2018 valhes2019 valhes_onetwo2000 valhes_onetwo2001 valhes_onetwo2002 valhes_onetwo2003 valhes_onetwo2004 valhes_onetwo2005 valhes_onetwo2006 valhes_onetwo2007 valhes_onetwo2008 valhes_onetwo2009 valhes_onetwo2010 valhes_onetwo2011 valhes_onetwo2012 valhes_onetwo2013 valhes_onetwo2014 valhes_onetwo2015 valhes_onetwo2016 valhes_onetwo2017 valhes_onetwo2018 valhes_onetwo2019 qofhes2000 qofhes2001 qofhes2002 qofhes2003 qofhes2004 qofhes2005 qofhes2006 qofhes2007 qofhes2008 qofhes2009 qofhes2010 qofhes2011 qofhes2012 qofhes2013 qofhes2014 qofhes2015 qofhes2016 qofhes2017 qofhes2018 qofhes2019 valhessymp2000 valhessymp2001 valhessymp2002 valhessymp2003 valhessymp2004 valhessymp2005 valhessymp2006 valhessymp2007 valhessymp2008 valhessymp2009 valhessymp2010 valhessymp2011 valhessymp2012 valhessymp2013 valhessymp2014 valhessymp2015 valhessymp2016 valhessymp2017 valhessymp2018 valhessymp2019 valhes12symp2000 valhes12symp2001 valhes12symp2002 valhes12symp2003 valhes12symp2004 valhes12symp2005 valhes12symp2006 valhes12symp2007 valhes12symp2008 valhes12symp2009 valhes12symp2010 valhes12symp2011 valhes12symp2012 valhes12symp2013 valhes12symp2014 valhes12symp2015 valhes12symp2016 valhes12symp2017 valhes12symp2018 valhes12symp2019

gen index = 1
order index

reshape long copd copdqof copdsymp copdsymp_nodiag hes hesany hes12_ hes_nodiag hes12_nodiag valhes valhes_onetwo qofhes valhessymp valhes12symp, i(index) j(year)

drop index

label var year "Year"
label var copd "Validated COPD"
label var copdqof "QOF COPD"
label var copdsymp "Smoker with symptoms, inhaler, no asthma"
label var copdsymp_nodiag "Smoker with symptoms, inhaler, no asthma w/o validated COPD"
label var hes "HES COPD"
label var hesany "HES COPD (any position)"
label var hes12_ "HES COPD (1st / 2nd position)"
label var hes_nodiag "HES COPD (any) w/o validated COPD"
label var hes12_nodiag "HES COPD (1st / 2nd) w/o validated COPD"
label var valhes "Validated OR HES (any) COPD"
label var valhes_onetwo "Validated OR HES (1st / 2nd) COPD"
label var qofhes "QOF OR HES COPD"
label var valhessymp "Validated OR HES (any) OR smoker with symptoms, inhaler, no asthma"
label var valhes12symp "Validated OR HES (1st / 2nd) OR smoker with symptoms, inhaler, no asthma"


save copd_prevalence_collapsed, replace


xpose, clear varname
order _varname

export excel copd_prevalence.xlsx, replace


use copd_prevalence_collapsed, clear  //leave on this one as easier to work with


log close