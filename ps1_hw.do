* Data Management ps1
* Thursday, September 19th, 2019
* Kristin Kelly
* This data is from the City of Philadelphia's Community Health Assessment
* Provided by Open Data Philly //nice preamble

cd /Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/Stata/ProblemSet1


insheet using https://github.com/CityOfPhiladelphia/community-health-explorer/raw/gh-pages/_data/2017/citywide_over_time.csv ,clear

//excellent!
outsheet using ps1.csv,  replace comma nolabel
export excel ps1.xls,  replace nolabel
save ps1.dta,  replace nolabel
save ps1_kk.dta,  replace nolabel

/***********/
/* looking */
/***********/

//good, and can briefly comment what is the interpretation of the output of these commands
edit 

describe

list, sepby(category)

list, sepby (datatype)

inspect

sort v10 
by v10: summarize category
 







