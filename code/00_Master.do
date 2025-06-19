** Master
clear all
set more off

global name "BM" 

** Define User
if "${name}" == "EL" {
    global user "C:/Users/edloaeza/Dropbox/SchoolDistrict2022"
}
else if "${name}" == "SAM" {
    global user "/Users/sam/Dropbox/Shared Folder/SchoolDistrict2022"
}
else if "${name}" == "BM" {
    global user "C:/Users/bmmur/UH-ECON Dropbox/Brian Murphy/Papers/SchoolDistrict2022"
}
else if "${name}" == "MS" {
    global user "C:/Users/Mashrur/Dropbox/IntraSDProject"
}

** Define Paths
global temp "${user}/temp"
global input "${user}/Replication/data"
global outpath "${user}/Output"
global code  "${user}/Code & Tables/code/analysis"
global finaldata "${user}/Final Data"

** Run .do files
do "${code}/10_summary_stats.do"
do "${code}/11_unit_root_test_coint.do"
do "${code}/12_ECM_regressions.do"
do "${code}/13_impulse_response_graphs.do"
do "${code}/14_debtanalysis.do"
