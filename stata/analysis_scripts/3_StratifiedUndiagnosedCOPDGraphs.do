cd "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

use copd_prevalence_strat_collapsed_v2_undiagnosed, clear


//Label variables

label var year "Year"

label var copdsymp_nodiag_prev "COPD Symptoms AND Smoker AND Inhaler AND No asthma AND No Validated COPD [Definition 3 minus Definition 1]"

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

line copdsymp_nodiag_prev year, yscale(range(0 3.5)) ylabel(0 "0" 0.5 "0.5" 1 "1.0" 1.5 "1.5" 2 "2.0" 2.5 "2.5" 3 "3.0" 3.5 "3.5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) title("Undiagnosed COPD prevalence in English adults aged ≥40 years", size(medium)) graphregion(margin(small))

graph save graphs/2023/undiagnosedCOPD_prevalence, replace
graph export graphs/2023/undiagnosedCOPD_prevalence.png, replace


line male_prev female_prev year, yscale(range(0 3.5)) ylabel(0 "0" 0.5 "0.5" 1 "1.0" 1.5 "1.5" 2 "2.0" 2.5 "2.5" 3 "3.0" 3.5 "3.5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("B.) Undiagnosed COPD prevalence stratified by gender", size(medium))*/ title("B.)", position(10) ring(7)) legend(rows(2) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/undiagnosedCOPD_strat_gender, replace
graph export graphs/2023/undiagnosedCOPD_strat_gender.png, replace


line age40_prev age50_prev age60_prev age70_prev age80_prev year, yscale(range(0 3.5)) ylabel(0 "0" 0.5 "0.5" 1 "1.0" 1.5 "1.5" 2 "2.0" 2.5 "2.5" 3 "3.0" 3.5 "3.5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("D.) Undiagnosed COPD prevalence stratified by age group", size(medium))*/ title("D.)", position(10) ring(7)) legend(rows(2) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/undiagnosedCOPD_strat_age, replace
graph export graphs/2023/undiagnosedCOPD_strat_age.png, replace


line region1_prev region2_prev region3_prev region4_prev region5_prev region6_prev region7_prev region8_prev region9_prev region10_prev year, yscale(range(0 3.5)) ylabel(0 "0" 0.5 "0.5" 1 "1.0" 1.5 "1.5" 2 "2.0" 2.5 "2.5" 3 "3.0" 3.5 "3.5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("F.) Undiagnosed COPD prevalence stratified by region", size(medium))*/ title("F.)", position(10) ring(7)) legend(rows(3) size(vsmall) position(6)) graphregion(margin(small)) legend(bmargin(zero))

graph save graphs/2023/undiagnosedCOPD_strat_region, replace
graph export graphs/2023/undiagnosedCOPD_strat_region.png, replace


graph combine graphs/2023/undiagnosedCOPD_strat_gender.gph graphs/2023/undiagnosedCOPD_strat_age.gph graphs/2023/undiagnosedCOPD_strat_region.gph, altshrink col(1) xcommon xsize(2) graphregion(margin(small)) imargin(medium) saving(graphs/2023/undiagnosedCOPD_strat_combined, replace)

graph export graphs/2023/undiagnosedCOPD_strat_combined.png, width(1000) replace



//Generate combined diagnosed/undiagnosed plot

graph combine graphs/2023/COPD_strat_gender.gph graphs/2023/undiagnosedCOPD_strat_gender.gph graphs/2023/COPD_strat_age.gph graphs/2023/undiagnosedCOPD_strat_age.gph graphs/2023/COPD_strat_region.gph graphs/2023/undiagnosedCOPD_strat_region.gph, altshrink graphregion(margin(small)) imargin(medium) xcommon col(2) xsize(26.25) ysize(30) saving(graphs/2023/diag_undiag_combined_fig3, replace)

graph export graphs/2023/diag_undiag_combined_fig3.png, width(1500) replace
graph export graphs/2023/diag_undiag_combined_fig3.pdf, replace