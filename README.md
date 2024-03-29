[![DOI:10.2147/COPD.S411739](https://img.shields.io/badge/DOI-10.2147%2FCOPD.S411739-blue)](https://doi.org/10.2147/COPD.S411739)
# Prevalence of chronic obstructive pulmonary disease in England from 2000 to 2019

## Publication
https://doi.org/10.2147/COPD.S411739

## COPD definitions

| COPD Definition  | Data source | Definition | Codelist |
| --- | --- | --- | --- |
| **Validated COPD**  | Primary care ([CPRD Aurum](https://doi.org/10.48329/q2n0-4n14)) | Algorithm 4 (specific COPD code only) from [Quint JK, et al. BMJ Open 2014;4:e005540](https://doi.org/10.1136/bmjopen-2014-005540) mapped from Read v2 to SNOMED CT | [`copd_validated_aurum_2021-10-21.dta.csv`](codelists/CSV/copd_validated_aurum_2021-10-21.dta.csv) |
| **Quality and Outcomes Framework (QOF)[^1] COPD** | Primary care ([CPRD Aurum](https://doi.org/10.48329/q2n0-4n14)) | [QOF v46 COPD business rules](https://digital.nhs.uk/data-and-information/data-collections-and-data-sets/data-collections/quality-and-outcomes-framework-qof/quality-and-outcome-framework-qof-business-rules/qof-business-rules-v46.0-2021-2022-baseline-release) | [`copd_qof_v46.dta.csv`](codelists/CSV/copd_qof_v46.dta.csv) |
| **Possible undiagnosed COPD** | Primary care ([CPRD Aurum](https://doi.org/10.48329/q2n0-4n14)) | <ul><li>A history of tobacco smoking,</li><li>At least 1 respiratory symptom (cough, dyspnoea, or sputum production),</li><li>A prescription for an inhaler,</li><li>AND no asthma diagnosis</li></ul> | <ul><li>[`smoking_status.dta.csv`](codelists/CSV/smoking_status.dta.csv) (smoking_status == "Current smoker" OR "Ex-smoker")</li><li>[`copd_symptoms.dta.csv`](codelists/CSV/copd_symptoms.dta.csv)</li><li>[`copd_meds_combined.dta.csv`](codelists/CSV/copd_meds_combined.dta.csv) (groups == "lama" OR "laba" OR "lama_laba" OR "ics" OR "laba_ics" OR "triple")</li><li>[`asthma_codes_for_current_cases_189.dta.csv`](codelists/CSV/asthma_codes_for_current_cases_189.dta.csv) (exclude if present in patient record)</li></ul> |
| **Any hospital admission with COPD or emphysema as a listed diagnosis** | Secondary care ([Hospital Episode Statistics](https://doi.org/10.48329/14gk-m942)) | A COPD or emphysema diagnosis code anywhere in the HES record | [`ICD10_COPD.tsv`](codelists/ICD10_COPD.tsv) |
| **COPD or emphysema hospital admission (primary/secondary diagnosis)** | Secondary care ([Hospital Episode Statistics](https://doi.org/10.48329/14gk-m942)) | COPD or emphysema diagnosis code in the first or second position in the HES record | [`ICD10_COPD.tsv`](codelists/ICD10_COPD.tsv) |
[^1]: The [Quality and Outcomes Framework (QOF)](https://digital.nhs.uk/data-and-information/data-collections-and-data-sets/data-collections/quality-and-outcomes-framework-qof) is a primary care pay-for-performance scheme. General practices receive points for completing specific items of care within a certain timeframe. The proportion of maximum possible points received in a year determines the size of financial bonus received at the end of the year.

## Codelists
All other variable definitions can be found in [/codelists](/codelists) in both [stata](/codelists/DTA) and [text](/codelists/CSV) formats.

## Data management and analysis scripts
All Stata scripts used to build the datasets and complete analyses can be found in [/stata](/stata).
