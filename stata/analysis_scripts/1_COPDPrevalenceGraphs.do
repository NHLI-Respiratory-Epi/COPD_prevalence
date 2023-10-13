clear all
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\AUK-BLF COPD Prevalence"

use copd_prevalence_collapsed_v2, clear


label var copd_prev "[1] Validated COPD"
label var copdqof_prev "[2] QOF COPD"
label var copdsymp_prev "[3] Smoker with symptoms, inhaler, no asthma"
label var copdsymp_nodiag_prev "[3 - 1] Smoker with symptoms, inhaler, no asthma w/o validated COPD"
label var hesany_prev "[4] HES COPD (any position)"
label var hes12__prev "[5] HES COPD (1st / 2nd position)"
label var hes_nodiag_prev "[4 - 1] HES COPD (any) w/o validated COPD"
label var hes12_nodiag_prev "[5 - 1] HES COPD (1st / 2nd) w/o validated COPD"
label var valhes_prev "[1 OR 4] Validated OR HES (any) COPD"
label var valhes_onetwo_prev "[1 OR 5] Validated OR HES (1st / 2nd) COPD"
label var valhessymp_prev "[1 OR 4 OR 3] Validated OR HES (any) OR smoker with symptoms, inhaler, no asthma"
label var valhes12symp_prev "[1 OR 5 OR 3] Validated OR HES (1st / 2nd) OR smoker with symptoms, inhaler, no asthma"


//Generate graphs

set scheme white_tableau

line copd_prev copdqof_prev copdsymp_prev copdsymp_nodiag_prev hesany_prev hes12__prev year, yscale(range(0 5)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("Prevalence of COPD in English adults aged ≥40 years", size(medium))*/ legend(cols(2) size(vsmall) position(6)) legend(bmargin(zero)) graphregion(margin(small)) xsize(30) ysize(20)

graph save graphs/2023/multidef_prevalence_fig1, replace
graph export graphs/2023/multidef_prevalence_fig1.png, replace
graph export graphs/2023/multidef_prevalence_fig1.pdf, replace


line copd_prev valhes_prev valhes_onetwo_prev valhessymp_prev valhes12symp_prev year, yscale(range(0 8)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("Prevalence of COPD in English adults aged ≥40 years (combined definitions)", size(medium))*/ legend(size(vsmall) position(6)) legend(bmargin(zero)) graphregion(margin(small))  xsize(30) ysize(20)

graph save graphs/2023/combidef_prevalence_fig2, replace
graph export graphs/2023/combidef_prevalence_fig2.png, replace
graph export graphs/2023/combidef_prevalence_fig2.pdf, replace


label var copdqof_prev "Quality and Outcomes Framework COPD"
label var hes12__prev "Hospital Episode Statistics (HES) COPD (primary/secondary diagnosis)"
label var valhes_onetwo_prev "Validated OR HES (primary/secondary diagnosis) COPD"

twoway connected copd_prev copdqof_prev copdsymp_prev hes12__prev valhes_onetwo_prev year, mlabel(copd_prev copdqof_prev copdsymp_prev hes12__prev valhes_onetwo_prev) mlabstyle(p1bar p2bar p3bar p4bar p5bar) mlabsize(tiny tiny tiny tiny tiny) yscale(range(0 5)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("Prevalence of COPD in English adults aged ≥40 years", size(medium))*/ legend(cols(2) size(vsmall) position(6)) legend(bmargin(zero)) graphregion(margin(small)) xsize(30) ysize(20)

graph save graphs/2023/ats_poster, replace
graph export graphs/2023/ats_poster.png, replace
graph export graphs/2023/ats_poster.svg, replace
graph export graphs/2023/ats_poster.emf, replace


set scheme cblind1

twoway connected copd_prev copdqof_prev copdsymp_prev hes12__prev valhes_onetwo_prev year, mlabel(copd_prev copdqof_prev copdsymp_prev hes12__prev valhes_onetwo_prev) mlabstyle(p1bar p2bar p3bar p4bar p5bar) mlabsize(tiny tiny tiny tiny tiny) yscale(range(0 5)) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5") ytitle("Prevalence (%)") xlabel(2000(2)2020, grid) /*title("Prevalence of COPD in English adults aged ≥40 years", size(medium))*/ legend(cols(2) size(vsmall) position(6)) legend(bmargin(zero)) graphregion(margin(small)) xsize(30) ysize(20)

graph save graphs/2023/ats_poster_cblind, replace
graph export graphs/2023/ats_poster_cblind.png, replace
graph export graphs/2023/ats_poster_cblind.svg, replace
graph export graphs/2023/ats_poster_cblind.emf, replace