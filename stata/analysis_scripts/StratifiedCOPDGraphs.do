cd "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

use copd_prevalence_strat_collapsed_v2.dta, clear


//Label variables

label var year "Year"

label var valhes_onetwo_prev "Validated OR HES (1st/2nd) [Definition 1 OR Definition 5]"

label var male_prev "Male"
label var female_prev "Female"

label var age40_prev "40-49 years"
label var age50_prev "50-59 years"
label var age60_prev "60-69 years"
label var age70_prev "70-79 years"
label var age80_prev "80+ years"

label var region1_prev "North East"
label var region2_prev "North West"
label var region3_prev "Yorkshire and the Humber"
label var region4_prev "East Midlands"
label var region5_prev "West Midlands"
label var region6_prev "East of England"
label var region7_prev "South West"
label var region8_prev "South Central"
label var region9_prev "London"
label var region10_prev "South East Coast"


//Generate graphs

set scheme white_tableau

line valhes_onetwo_prev year, yscale(range(0 8)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8") ytitle("Prevalence (%)", size(medium)) xlabel(2000(2)2020, grid) title("COPD prevalence in English adults aged ≥40 years") graphregion(margin(small))

graph save graphs/2023/COPD_prevalence, replace
graph export graphs/2023/COPD_prevalence.png, replace


line male_prev female_prev year, yscale(range(0 8)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("A.) COPD prevalence stratified by gender", size(medium))*/ title("A.)", position(10) ring(7)) legend(rows(2) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/COPD_strat_gender, replace
graph export graphs/2023/COPD_strat_gender.png, replace


line age40_prev age50_prev age60_prev age70_prev age80_prev year, yscale(range(0 12)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 12 "12") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("C.) COPD prevalence stratified by age group", size(medium))*/ title("C.)", position(10) ring(7)) legend(rows(2) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/COPD_strat_age, replace
graph export graphs/2023/COPD_strat_age.png, replace


line region1_prev region2_prev region3_prev region4_prev region5_prev region6_prev region7_prev region8_prev region9_prev region10_prev year, yscale(range(0 8)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("E.) COPD prevalence stratified by region", size(medium))*/ title("E.)", position(10) ring(7)) legend(rows(3) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/COPD_strat_region, replace
graph export graphs/2023/COPD_strat_region.png, replace


graph combine graphs/2023/COPD_strat_gender.gph graphs/2023/COPD_strat_age.gph graphs/2023/COPD_strat_region.gph, altshrink col(1) xcommon xsize(2) graphregion(margin(small)) imargin(medium) saving(graphs/2023/COPD_strat_combined, replace)

graph export graphs/2023/COPD_strat_combined.png, width(1000) replace