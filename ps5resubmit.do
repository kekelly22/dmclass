* Data Management ps5 resubmission
* Due: Tuesday, November 26th, 2019
* Kristin Kelly
* Stata version 16

/*
commented out for submission 
cd "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/New" */

/************/
/*   DATA   */
/************/
/* 
Dataset #1: From the CDC, "500 Cities: Census Tract-level Data" (2018)
https://chronicdata.cdc.gov/500-Cities/500-Cities-Census-Tract-level-Data-GIS-Friendly-Fo/k86t-wghb
https://www.cdc.gov/500cities/
"The 500 Cities project is a collaboration between CDC, the Robert Wood Johnson Foundation, and the CDC Foundation. The purpose of the 500 Cities Project is to provide city- and census tract-level small area estimates for chronic disease risk factors, health outcomes, and clinical preventive service use for the largest 500 cities in the United States."

Dataset #2: From the U.S. Census & City of Philadelphia and imported from OpenDataPhilly: "Census Tracts (2010)". 
This is a data set of census tracts with their name, ID, XY coord. I'm merging this into my master set in order to widen the geographic information I have for other health data sets with only one or two geo-identifiers.
https://www.opendataphilly.org/dataset/census-tracts
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
"For matching and analyzing demographic data collected and compiled by the U.S. Census Bureau & American Community Survey(ACS) to the geography of Census Block Group boundaries within the City of Philadelphia."

Dataset #3: From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Philadelphia Hospitals", last updated in 2019. 
https://www.opendataphilly.org/dataset/philadelphia-hospitals
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This is a list of Philly hospitals and locations by zip, address, and XY coordinates. I'm utilizing this dataset to create a count of how many hospitals are provided in different neighborhoods of Philly.

Dataset #4: From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Healthy Start Community Resource Centers", last updated in 2017.
https://www.opendataphilly.org/dataset/healthystart-crcs
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This data originally contains information on street location, hours and contact information of 4 PDPH-affiliated HealthyStart Community Resource Centers. I'm utilizing this dataset to create a count of how many health resources are provided in different neighborhoods of Philly.

Dataset #5: From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Health Centers", last updated in 2017.
https://www.opendataphilly.org/dataset/health-centers
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This data originally contains information on street location, hours and contact information of 55 Health Centers in Philly. I'm utilizing this dataset to create a count of how many health resources are provided in different neighborhoods of Philly.

Dataset #6: From Healthy People 2020 census data provided by the city of Philadelphia.
https://www.health.pa.gov/topics/HealthStatistics/HealthyPeople/Documents/current/county/index.aspx
ealthyPeople.gov
https://www.healthypeople.gov/2020/data-search/Search-the-Data#topic-area=3495;topic-area=3505;topic-area=3498;topic-area=3502
This dataset includes prevalence statistics for a variety of major health concerns in the U.S. I'm cleaning it to include data for the city of Philadelphia.

Dataset #7: Created a report of ACS 5-year census data from Social Explorer. This data set is geoidentified by census tract. 
It includes data reports of poverty, income, housing, race, age, sex, and health insurance coverage by census tract in the city of Philadelphia. 

Dataset #8: I have a US census data set with organized census tracts with zip codes. I plan to use this to help clean and merge my different prevalence datasets with census tracts or zips if they're missing one or the other. This is my next dataset plan, but I'm still trying to work through my challenges outlined below first.
*/

/******************/
/*     LOOKING    */
/******************/
mkdir ~\kristinkellyPS5
cd ~\kristinkellyPS5

* MACROS ?
/* trying to call a macro to remove spaces between values. I've spent at least 3 hours trying to figure this out using slides and google. Here are some of the versions of what I've tried.
global s replace `values' = subinstr(`values', " ", "", .)
global s replace `values' = subinstr(`values', " ", "", .)
global s replace var = subinstr( , " ", "", .)
global s replace var = subinstr(variables, " ", "", .)

* even tried some of th combos above within a loop like:
foreach var of varlist _all {
$s
}
- or -
foreach var of varlist {
$s
}
- or -
foreach var of varlist*{
$s
}
- or -
foreach var in varlist topic measure year county_fips County rate { 
replace var = subinstr('var', " ", "", .)
}

* I also asked for help from Shibin, Lili, and Ryan to try to troubleshoot. Between these examples and a few more attempts- I didn't have success yet.
*/

* bringing in data set #1: CDC 500 cities data (details above)
insheet using "https://github.com/kekelly22/dmclass/blob/master/500cities.csv?raw=true", clear
edit
keep if placename=="Philadelphia"
*376 observations left in dataset, data specific to Philadelphia

/* the original data set provided one variable for a number string that included state, county, and tract codes. The following code breaks up that variable into three new var that will help me merge with other data sets with tract id later. */
gen tract=substr(place_tractid,9,.)
gen statecode=substr(tract,1,2)
gen countycode=substr(tract,3,3)
gen tractcode=substr(tract,6,.)

* creating a loop to drop the unnecessary confidence interval variables
foreach var of varlist *crude95ci placefips geolocation {
drop `var'
}

* created a loop to replace any missing values with a .
foreach var of varlist *crudeprev {
replace `var'=. if `var'==-9
}
* 0 observations changed
   
rename access2_crudeprev access2hc
rename bphigh_crudeprev highbp
rename casthma_crudeprev asthma
rename checkup_crudeprev ancheckup
rename csmoking_crudeprev smoking
rename dental_crudeprev dentalvis
rename obesity_crudeprev obesity
rename paptest_crudeprev pap
rename mammouse_crudeprev mammo
rename stateabbr State
* I realize that I could have used a loop to create uniform renames for above. But I needed them to be renamed in particular ways that didn't fit a pattern that's worth a loop. I also went through during this step and updated all of their labels.

keep State placename tractfips place_tractid population2010 access2hc highbp asthma ancheckup smoking dentalvis obesity pap mammo
* I kept the relevant variables for my final data set exploring healthcare access and visits

save 500cities, replace

*bringing in dataset #2: Census Tracts (2010) - details above

clear
insheet using "https://github.com/kekelly22/dmclass/raw/master/Census_Tracts_2010.csv"
edit
rename geoid10 tractfips /* for merging purposes */
keep tractfips intptlat10 intptlon10 /*keeping geo ID for merging and XY coord to strengthen other geo data with merge */
rename intptlat10 latitude
rename intptlon10 longitude
save ODP_censustracts, replace

/* MERGE 1 */
use 500cities, clear
merge 1:1 tractfips using ODP_censustracts
*8 non-merges (from Census Tracts)
drop if _merge!=3
drop _merge

drop place_tractid
rename latitude X
rename longitude Y
save cdcTractMerge, replace
/* end of MERGE 1 */

/**** For the following datasets (#3, 4, 5) I am cleaning and appending to make one bigger dataset with the combined data involving the locations of health locations in Philadelphia ***** */

* bringing in dataset #3: List of Philly hospitals and locations by zip, address, and XY coordinates
insheet using "https://github.com/kekelly22/dmclass/raw/master/Hospitals%20(1).csv", clear
*zip_code (unique)
keep X y hospital_name street_address zip_code hospital_type
rename y Y
rename hospital_name ResourceName
rename street_address address
rename zip_code Zip
rename hospital_type Service /* renaming so that I can create a variable in future datasets to distinguish them as non-hospitals */
encode Service, g(service) /* ceeating value labels to avoid data relabeling its service type during future merges */
codebook service, ta(10) /* looking at value labels created */
save phlhospitals, replace

* bringing in dataset #4: List of Community Health Resource Centers in Philly and their locations by zip, address, and XY coordinates
insheet using "https://github.com/kekelly22/dmclass/raw/master/Healthy_Start_CRCs.csv", clear
*zip (4 unique)
keep X y facility_name address zip
rename facility_name ResourceName
rename zip Zip
rename y Y
gen Service = "Community Health Resource Center" /* created to distinguish these CRCs from hospitals and health centers in merge */
save phlCRC, replace

/* APPEND */
append using phlhospitals
* Brought in 2 new zips and 2 zips that were already in phlhospitals to add resource data. 
save phlHealthLocations, replace
replace service=5 if Service=="Community Health Resource Center"
label define ser 1 "Behavioral Health" 2 "General Medical" 3 "Long term care" 4 "Rehabilitation" 5 "Community Health Medical Center" 6 "Health Center"
label values service ser
save phlHealthLocations, replace

* bringing in dataset #5: List of Health Centers in Philly and their locations by zip, address, and XY coordinates
insheet using "https://github.com/kekelly22/dmclass/raw/master/Health_Centers.csv", clear
keep X y name zip full_address
rename name ResourceName
rename full_address address
rename zip Zip
rename y Y
gen Service = "Health Center" /* created to distinguish these CRCs from hospitals and health centers in merge */
save phlHC, replace

/* APPEND */
append using phlHealthLocations
* Brought in 2 zips that were already in phlhospitals and then added resource data in two new zips. Not dropping non-merges.
save phlHealthLocations, replace
replace service=6 if Service=="Health Center"
drop Service
rename service Service
save phlHealthLocations, replace
*******

* MERGE #2 */
merge 1:1 X using cdcTractMerge
//breaks here 
//. merge 1:1 X using cdcTractMerge
//variable X does not uniquely identify observations in the master data
//and it doesnt make sense anyway, if anything on both X and Y and m:1 because you have point here and polygon (tract) in using
//and should round up x and y to match better, we should talk and we should talk about macros and loops, say tues?


*8 non-merges (from Census Tracts)
drop if _merge!=3
drop _merge

drop place_tractid
rename latitude X
rename longitude Y
save cdcTractMerge, replace


/* Bringing in dataset #6: Healthy People 2020 (details above) 
commented out: github upload for Healthy people data "https://github.com/kekelly22/dmclass/blob/master/healthy-people-county%20(1).zip?raw=true" */
clear
unzipfile "https://www.health.pa.gov/topics/HealthStatistics/HealthyPeople/Documents/current/county/healthy-people-county.zip?", replace
insheet using healthy-people-county.csv, clear
drop if county_name!="Philadelphia"
drop data_type code goal goal_direction
drop if year!="2013-2017"
rename county_name County
replace topic = subinstr(topic, " ", "", .)
list
* creating a new variable to identify the different health statistics. this helps me drop rows I'm uninterested in before I reshape 
gen objectid= _n
drop if inlist(objectid, 2,3,4,5,6,7,13,14,15,17,18,20,21,23,24,25,26,27,28,29,30,31,32,33,34)
* dropping data related to specific types of cancer & keeping one general cancer prevalance rating. I tried different symbols (* or ~ or /) and didn't have much luck with make this code look simpler. What did I get wrong?
drop objectid

/* This is where I got stuck with this code. I want to reshape to be wide and not long so that each topic is it's own column. But I'm trying to rename the repeating topics to have a unique names for the reshape.
replace "FamilyPlanning"
save phlHP2020, replace

reshape wide topic rate, i(measure) j(topic 1/29) string
*/


/* Bringing in dataset #7: Custom report of Philly census data via Social Explorer */
***** This is my code for when I had to download the files and save them on my computer and then push to github in order to have an online import. Before uploading to github I dropped variables I didn't need for space/mem purposes. *****
/* infile using "R12396925.dct", using("R12396925_SL140.txt")
keep  FIPS NAME QName SUMLEV LOGRECNO STATE COUNTY TRACT GEOID A00001_001 A00002_002 A01001_002 A01001_003 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_009 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A14009_010 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005
save phlCensus_SE, replace
*/

clear
use "https://github.com/kekelly22/dmclass/blob/master/phlCensus_SE.dta?raw=true", clear
save phlCensus_SE, replace

drop A03001B_009 A01001_003 A14009_010

	/* I'm trying out better ways to do this code so that my variable labels aren't abbreviated and only the variable nane is. But I'm struggling to do that (below). In the meantime, here is the code that worked for me: */
foreach v of varlist FIPS NAME QName SUMLEV LOGRECNO STATE COUNTY TRACT GEOID A00001_001 A00002_002 A01001_002 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005 {
         local label : var label `v'
         local label1 = subinstr(`"`label'"', " ", "_", .)
		 local label2 = subinstr(`"`label1'"', "(", "", .)
		 local label3 = subinstr(`"`label2'"', ")", "", .)
		 local label4 = subinstr(`"`label3'"', ".", "", .)
		 local label5 = subinstr(`"`label4'"', "-", "", .)
		 local label6 = subinstr(`"`label5'"', ",", "", .)
		 local label7 = subinstr(`"`label6'"', "[", "", .)
		 local label8 = subinstr(`"`label7'"', "]", "", .)
		 local newlabel = subinstr(`"`label7'"', ":", "", .)
		 local newlabel1=substr(`"`newlabel'"',1,8)+substr(`"`newlabel'"',-28,20)
         label var `v' `"`newlabel1"'
}

foreach v of varlist A00001_001 A00002_002 A01001_002 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005 {
	local x : variable label `v'
	rename `v' `x'
}
* Above: I used loop code with local macros to remove invalid characters from the variable labels and I abbreviated the variable label names for ease 
*/

/* Here I'm trying toc reate loops to clean my labels of invalid characters so that I can rename my variables based off of their labels.  I was trying to create code to first clean the labels, then rename the variables for their names to match the labels, and THEN substring out the variable names to be abbreviated for ease of use. But I keep hitting road blocks... this was the closest I got code to success:

foreach v of varlist FIPS NAME QName SUMLEV LOGRECNO STATE COUNTY TRACT GEOID A00001_001 A00002_002 A01001_002 A01001_003 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A14009_010 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005 {
         local label : var label `v'
         local label1 = subinstr(`"`label'"', " ", "_", .)
		 local label2 = subinstr(`"`label1'"', "(", "", .)
		 local label3 = subinstr(`"`label2'"', ")", "", .)
		 local label4 = subinstr(`"`label3'"', ".", "", .)
		 local label5 = subinstr(`"`label4'"', "-", "", .)
		 local label6 = subinstr(`"`label5'"', ",", "", .)
		 local label7 = subinstr(`"`label6'"', "[", "", .)
		 local label8 = subinstr(`"`label7'"', "]", "", .)
		 local newlabel = subinstr(`"`label7'"', ":", "", .)
		 label var `v' `"`newlabel'"'
}

foreach v of varlist A00001_001 A00002_002 A01001_002 A01001_003 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A14009_010 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005 {
	local x : variable label `v'
	rename `v' `x'
}

foreach v of varlist A00001_001 A00002_002 A01001_002 A01001_003 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A14009_010 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005 {
	rename * substr(`"var"',1,10)+substr(`"var"',-26,22)
}	 
*/
	
save phlCensus_SE, replace


