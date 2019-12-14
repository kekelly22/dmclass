* Data Management Final Project
* Due: Saturday, November 30th, 2019
* Kristin Kelly
* Stata version 16

* Just a reminder to viewers that this is a new dataset created after ps4. Previous problem sets used different data and hypotheses that weren't conducive to the future data processes of this course.
* I've been working on my code in and out of family occasions this past few days since class. I think my code has improved a lot in my eyes, but I'd still like to meet on Tuesday.

/******************/
/*   HYPOTHESES   */
/******************/
* 1) Rates of obesity, asthma and smoking will be higher in poorer areas.
* 2) Rates of access to healthcare and annual check-ups will be unrelated to health services available in that area.
* 3) Obesity rates will be different by races.

/************/
/*   DATA   */
/************/
/* 
Dataset #1: CDC 500 CITIES
From the CDC, "500 Cities: Census Tract-level Data" (2018)
https://chronicdata.cdc.gov/500-Cities/500-Cities-Census-Tract-level-Data-GIS-Friendly-Fo/k86t-wghb
https://www.cdc.gov/500cities/
"The 500 Cities project is a collaboration between CDC, the Robert Wood Johnson Foundation, and the CDC Foundation. The purpose of the 500 Cities Project is to provide city- and census tract-level small area estimates for chronic disease risk factors, health outcomes, and clinical preventive service use for the largest 500 cities in the United States."

Dataset #2: U.S. CENSUS
From the U.S. Census & City of Philadelphia and imported from OpenDataPhilly: "Census Tracts (2010)". 
This is a data set of census tracts with their name, ID, XY coord. I'm merging this into my master set in order to widen the geographic information I have for other health data sets with only one or two geo-identifiers.
https://www.opendataphilly.org/dataset/census-tracts
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
"For matching and analyzing demographic data collected and compiled by the U.S. Census Bureau & American Community Survey(ACS) to the geography of Census Block Group boundaries within the City of Philadelphia."

Dataset #3: PHILADELPHIA DEPARTMENT OF PUBLIC HEALTH
From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Philadelphia Hospitals", last updated in 2019. 
https://www.opendataphilly.org/dataset/philadelphia-hospitals
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This is a list of Philly hospitals and locations by zip, address, and XY coordinates. I'm utilizing this dataset to create a count of how many hospitals are provided in different neighborhoods of Philly.

Dataset #4: PHILADELPHIA DEPARTMENT OF PUBLIC HEALTH
From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Healthy Start Community Resource Centers", last updated in 2017.
https://www.opendataphilly.org/dataset/healthystart-crcs
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This data originally contains information on street location, hours and contact information of 4 PDPH-affiliated HealthyStart Community Resource Centers. I'm utilizing this dataset to create a count of how many health resources are provided in different neighborhoods of Philly.

Dataset #5: PHILADELPHIA DEPARTMENT OF PUBLIC HEALTH
From the City of Philadelphia's Department of Public Health and imported from OpenDataPhilly: "Health Centers", last updated in 2017.
https://www.opendataphilly.org/dataset/health-centers
I had to upload the dataset to GitHub for an online data source because the link address on OpenDataPhilly was not responding.
This data originally contains information on street location, hours and contact information of 55 Health Centers in Philly. I'm utilizing this dataset to create a count of how many health resources are provided in different neighborhoods of Philly.

Dataset #6: HEALTHY PEOPLE 2020
From the state of Pennsylvania's Healthy People 2020 census data.
https://www.health.pa.gov/topics/HealthStatistics/HealthyPeople/Documents/current/county/index.aspx
https://www.healthypeople.gov/2020/data-search/Search-the-Data#topic-area=3495;topic-area=3505;topic-area=3498;topic-area=3502
This dataset includes prevalence statistics for a variety of major health concerns in the U.S. I'm cleaning it to include data for the city of Philadelphia.

Dataset #7: SOCIAL EXPLORER 
I created a report of ACS 5-year census data from Social Explorer. This data set is geoidentified by census tract. 
It includes data reports of poverty, income, housing, race, age, sex, and health insurance coverage by census tract in the city of Philadelphia. 

Dataset #8: U.S. CENSUS
I have a US census data set with organized census tracts with zip codes. I plan to use this to help clean and merge my different prevalence datasets with census tracts or zips if they're missing one or the other. This is my next dataset plan, but I'm still trying to work through my challenges outlined below first.
https://www.census.gov/geographies/reference-files/2010/geo/relationship-files.html#par_textimage_674173622
https://www.census.gov/programs-surveys/geography/technical-documentation/records-layout/2010-zcta-record-layout.html

Dataset #9: CITY OF PHILADELPHIA
Neighborhood Food Retail Report collected by Philadelphia Department of Public Health
"This dataset is derived from the Neighborhood Food Retail in Philadelphia report. The report, and accompanying online resource gallery, looks at neighborhood availability of "high-produce supply stores” (e.g., supermarkets, produce stores, farmers’ markets) in relation to “low-produce supply stores” (like dollar stores, pharmacies, and convenience stores)."
https://www.opendataphilly.org/dataset/neighborhood-food-retail
Last Updated: 2019 */

/******************/
/*     LOOKING    */
/******************/
/* sub
mkdir ~\kristinkellyPS5
cd ~\kristinkellyPS5 */

* bringing in dataset #1: CDC 500 cities data (details above)
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

keep State placename tractfips population2010 access2hc highbp asthma ancheckup smoking dentalvis obesity pap mammo
* I kept the relevant variables for my final data set exploring healthcare access and visits

rename tractfips geoid /* this will be useful in future merges */

save 500cities, replace
* NOTE: after cleaning, this dataset has:
*** Geo-identifiers: State, City, Tract, geoID
*** Health factors: % rates for access to healthcare, high blood pressure, asthma, people with regular annual check-ups, smoking, people with dental healthcare, people getting regular mammogram screenings, obesity, and people getting regular PAP tests
*** Other: Population in 2010

*bringing in dataset #2: Census Tracts (2010) - details above
insheet using "https://github.com/kekelly22/dmclass/raw/master/Census_Tracts_2010.csv", clear
edit
rename geoid10 geoid /* for merging purposes */
keep geoid intptlat10 intptlon10 
*keeping geo ID for merging and XY coord to strengthen other geo data with merge
rename intptlat10 latitude
rename intptlon10 longitude
save ODP_censustracts, replace
* NOTE: after cleaning, this dataset has:
*** Geo-identifiers: Tract, X coord, Y coord

/* MERGE 1 */
use 500cities, clear
merge 1:1 geoid using ODP_censustracts
*8 non-merges (from Census Tracts)
drop if _merge!=3
drop _merge

rename latitude X
rename longitude Y
/* end of MERGE 1 */
* The purpose of this merge was to take the prevalence rates of major health factors (from my data set of 500 cities) and add in geographic identifiers with tract id and coordinates. This is intended to make my data more geographically rich for future merges with other geoID data files.
save cdcTractMerge, replace

* NOTE: this merged dataset has:
*** Geo-identifiers: State, City, Tract, geoid, X coord, Y coord
*** Health factors: % rates for access to healthcare, high blood pressure, asthma, people with regular annual check-ups, smoking, people with dental healthcare, people getting regular mammogram screenings, obesity, and people getting regular PAP tests
*** Other: Population in 2010

** Bringing in Data set #8 with census tract, zip, and housing data
insheet using "https://github.com/kekelly22/dmclass/blob/master/censustract_zip.csv?raw=true", clear
drop if county!=101 /* dropping data from outside of Philadelphia county */
keep zhu zcta5 tract geoid
rename zcta5 Zip
rename tract Tract
rename zhu HousUnitCount
sort Zip
drop if Zip < 19000
drop if Zip > 19155 /* dropping zip codes from outside of the city of Philadelphia */
sort Tract
tab geoid 
collapse (first) geoid HousUnitCount, by (Zip) 
* creating a list of unique geoID (including tract id) and an average of the # of housing units in each one by Zip
save tract_to_zip, replace

/* MERGE 2 */
merge m:1 geoid using cdcTractMerge
*333 non-merges - This is most likely explained by the data set of with census tracts and zips containing geoids that went beyond the city limits of Philadelphia. Since my health statistics are for the primary 47 zip codes of the city of Philadelphia, those are the ones that matched and kept. 
drop if _merge!=3
drop _merge
rename placename City
save master, replace

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
* NOTE: after cleaning, this dataset has:
*** Geo-identifiers: X coord, Y coord, Zip, Address
*** Health data: names of 36 hospitals, type of hospital


* bringing in dataset #4: List of Community Health Resource Centers in Philly and their locations by zip, address, and XY coordinates
insheet using "https://github.com/kekelly22/dmclass/raw/master/Healthy_Start_CRCs.csv", clear
*zip (4 unique)
keep X y facility_name address zip
rename facility_name ResourceName
rename zip Zip
rename y Y
gen Service = "Community Health Resource Center" /* created to distinguish these CRCs from hospitals and health centers in merge */
save phlCRC, replace
* NOTE: after cleaning, this dataset has:
*** Geo-identifiers: X coord, Y coord, Zip, Address
*** Health data: name of 4 Community Health Resource Center, type of CHRC

/* APPEND */
append using phlhospitals
* Brought in 2 new zips and 2 zips that were already in phlhospitals to add resource data. 
save phlHealthLocations, replace
replace service=5 if Service=="Community Health Resource Center"
label define ser 1 "Behavioral Health" 2 "General Medical" 3 "Long term care" 4 "Rehabilitation" 5 "Community Health Medical Center" 6 "Health Center"
label values service ser
save phlHealthLocations, replace
* NOTE: after appending this dataset has:
*** Geo-identifiers: X coord, Y coord, Zip, Address
*** Health data: name of 4 Community Health Resource Center, names of 26 hospital, type of service

* bringing in dataset #5: List of Health Centers in Philly and their locations by zip, address, and XY coordinates
insheet using "https://github.com/kekelly22/dmclass/raw/master/Health_Centers.csv", clear
keep X y name zip full_address
rename name ResourceName
rename full_address address
rename zip Zip
rename y Y
gen Service = "Health Center" /* created to distinguish these CRCs from hospitals and health centers in merge */
save phlHC, replace
* NOTE: after cleaning this dataset has:
*** Geo-identifiers: X coord, Y coord, Zip, Address
*** Health data: name of 55 Health Centers, type of Health center

/* APPEND */
append using phlHealthLocations
* Brought in 2 zips that were already in phlhospitals and then added resource data in two new zips. Not dropping non-merges.
save phlHealthLocations, replace
replace service=6 if Service=="Health Center"
drop Service
rename service Service
save phlHealthLocations, replace /* I'm saving this data set individually before continuing with more collapsing/pre-merge cleaning. I can use this more comprehensive set of information on health services later if my initial statistical tests or visuals indicate an interesting use for it. */
*******
* NOTE: after cleaning and appending, this finished dataset has:
*** Geo-identifiers: X coord, Y coord, Zip, Address
*** Health data: name of 4 Community Health Resource Center, name of 36 hospitals, name of 55 health centers, type of service

sort Zip
order Zip
save phl_HCmerge, replace
collapse (count) Service, by(Zip)
rename Service Num_HealthServiceProv

* NOTE: after cleaning and collapsing, this dataset has:
*** Geo-identifiers: Zip
*** Health data: # of health service providers in 32 Zip codes
save phl_HCmerge, replace

* MERGE 3 *
use master
merge 1:m Zip using phl_HCmerge
*15 non-merges - 15 of the total 47 Zip codes in the master set didn't have different types of healthcare providers in them.
drop _merge

* Not dropping the non-merges because it's still important to know which zip codes do not have healthcare providers in them
replace Num_HealthServiceProv=0 if Num_HealthServiceProv==.
rename geoid GeoID
save master, replace
* end of MERGE 3 *
* NOTE: after this merge, this finished dataset has:
*** Geo-identifiers: geoid, X coord, Y coord, Zip, Address, City, State
*** Health data: # of health service providers in 32 (of 47) Zip codes, % rates (for: access to healthcare, high blood pressure, asthma, people with regular annual check-ups, smoking, people with dental healthcare, people getting regular mammogram screenings, obesity, and people getting regular PAP tests)
*** Other: Population in 2010, Housing unit count

/* Bringing in dataset #7: Custom report of Philly census data via Social Explorer */
*** This is my code for when I had to download the data and dictionary files. I saved them on my computer and then pushed to github in order to have an online import. Before uploading to github I dropped variables I didn't need for space/mem purposes.
/* infile using "R12396925.dct", using("R12396925_SL140.txt")
keep  FIPS NAME QName SUMLEV LOGRECNO STATE COUNTY TRACT GEOID A00001_001 A00002_002 A01001_002 A01001_003 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A10025_001 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_009 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A14009_010 A13003B_001 A13003B_002 A13003B_003 B13004_001 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A20001_002 A20001_003 A20001_004 A20001_005
save phlCensus_SE, replace */

use "https://github.com/kekelly22/dmclass/blob/master/phlCensus_SE.dta?raw=true", clear
drop GEOID A03001B_009 A01001_003 A14009_010 QName SUMLEV LOGRECNO STATE COUNTY A01001_002 A01001_004 A01001_005 A01001_006 A01001_007 A01001_008 A01001_009 A10010_001 A10010_002 A10010_003 A10010_004 A10010_005 A10010_006 A10010_007 A10010_008 A10010_009 A10010_010 A03001B_001 A03001B_002 A03001B_003 A03001B_004 A03001B_005 A03001B_006 A03001B_007 A03001B_008 A03001B_010 A01003B_002 A01003B_003 A01003B_004 A01003B_005 A01003B_006 A01003B_007 A01003B_008 A01003B_009 A01003B_010 B13004_002 B13004_003 B13004_004 B13004_005 A20001_001 A10025_001 A00001_001 A00002_002
save phlCensus_SE, replace

	/* I'm trying out better ways to do this code so that my variable labels aren't abbreviated and only the variable nane is. But I'm struggling to do that (below). In the meantime, here is the code that worked for me: */
foreach v of varlist _all {
         local label : var label `v'
		 local label1 = subinstr(`"`label'"', "Average", "Avg", .)
		 local label2 = subinstr(`"`label1'"', "In 2017 Inflation Adjusted Dollars", "", .)
		 local label3 = subinstr(`"`label2'"', "Population", "Pop", .)
		 local label4 = subinstr(`"`label3'"', "Dollars Adjusted", "", .)
		 local label5 = subinstr(`"`label4'"', "Hous*", "Hous", .)
         local label6 = subinstr(`"`label5'"', " ", "_", .)
		 local label7 = subinstr(`"`label6'"', "(", "", .)
		 local label8 = subinstr(`"`label7'"', ")", "", .)
		 local label9 = subinstr(`"`label8'"', ".", "", .)
		 local label10 = subinstr(`"`label9'"', "-", "", .)
		 local label11 = subinstr(`"`label10'"', ",", "", .)
		 local label12 = subinstr(`"`label11'"', "[", "", .)
		 local label13 = subinstr(`"`label12'"', "]", "", .)
		 local newlabel = subinstr(`"`label13'"', ":", "", .)
		 local newlabel1=substr(`"`newlabel'"',1,8)+substr(`"`newlabel'"',-16,16)
         label var `v' `"`newlabel1"'
}

rename NAME TractName
rename TRACT TractNum
rename FIPS geoid

foreach v of varlist A01001_010 A01001_011 A01001_012 A01001_013 A03001_002 A03001_003 A03001_004 A03001_005 A03001_006 A03001_007 A03001_008 A14008_001 A14009_001 A14009_002 A14009_003 A14009_004 A14009_005 A14009_006 A14009_007 A14009_008 A14009_009 A13003B_001 A13003B_002 A13003B_003 B13004_001 A20001_002 A20001_003 A20001_004 A20001_005 {
	local x : variable label `v'
	rename `v' `x'
}
* Above: I used a loop with local macros to remove invalid characters from the variable labels and I abbreviated the variable label names for simplicity */

/* Here I'm trying to create loops to clean my labels of invalid characters so that I can rename my variables based off of their labels.  I was trying to create code to first clean the labels, then rename the variables for their names to match the labels, and THEN substring out the variable names to be abbreviated for ease of use. But I keep hitting road blocks... this was the closest I got code to success:

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
}	  */
	
destring geoid, generate(GeoID) /* had to do this to be able to merge. my master data set bas geoid as a numeric */
gen Pop55over = Total_Pop_55_to_64_Years+Total_Pop_65_to_74_Years+Total_Pop_75_to_84_Years+Total_Po5_Years_and_Over
* Generating a new variable for ages 55 and up for possible visuals or tests of older populations.
drop Total_Pop_55_to_64_Years Total_Pop_65_to_74_Years Total_Pop_75_to_84_Years Total_Po5_Years_and_Over

save phlCensus_SE, replace

* MERGE 4 *
use master, clear
merge m:1 GeoID using phlCensus_SE
* 340 non-merges - most likely for the same reasons listed above with the 
rename geoid GeoID_String
drop _merge
* end of MERGE 4 
save master, replace

* Bringing in dateset #9: City of Philadelphia's Neighborhood Food Retail (details above)
insheet using "http://data-phl.opendata.arcgis.com/datasets/53b8a1c653a74c92b2de23a5d7bf04a0_0.csv"
drop shape__area shape__length OBJECTID pct_hpss

la var high_poverty "High poverty is defined as 20% or more of the block group being below the federal poverty level"
la var hpss_access "Access to high-produce supply stores as either No Access, Low Access, or Moderate or High Access"
la var hpss_per1000 "Number of high-produce supply stores per 1,000 people"
la var lpss_per1000 "Number of low-produce supply stores per 1,000 people"
la var pct_poverty "Percentage of people living below the federal poverty level"
la var pct_vehicle_availability "Percentage of occupied housing units with at least 1 vehicle"
rename pct_vehicle_availability Pct_VehiAccess
la var total_hpss "Total number of high-produce supply stores within a half mile walking distance of the block group."
la var total_restaurants "Number of restaurants, bars, and food trucks located within a block group	"
la var total_lpss "Total number of low-produce supply stores within a half mile walking distance of the block group."
la var supermarket_access "Binary indicator for whether or not the block group has a supermarket within a half mile walking distance."


/**************************/
/*     TESTS & VISUALS    */
/**************************/
* Graphing a scatter plot of obesity rates by racial populations
twoway (scatter obesity Total_Po_Pop_White_Alone Total_Pon_American_Alone Total_Poska_Native_Alone Total_Po_Pop_Asian_Alone Total_Poc_Islander_Alone Total_PoOther_Race_Alone Total_Powo_or_More_Races), ytitle(Obesity) ylabel(0(1000)7000, labsize(small) angle(vertical) valuelabel alternate) xtitle(Race) title(Obesity by Race)
* INTERPRETATION: You can tell there are some patterns in differences of obesity rates by racial backgrounds.

* Producing a correlation of access to healthcare and the nymber of healthcare providers by zip code. The idea of this test is 
correlate access2hc Num_HealthServiceProv
* This correlation indicates a mild, positive correlation (r = 0.2067). 
twoway(scatter access2hc Num_HealthServiceProv) (lfit access2hc Num_HealthServiceProv)
* Need to come back to this and include code for the visual effects I made ^^
graph save "Graph" "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/New/Ac2HCxNumHCP.gph", replace

graph hbar (mean) access2hc, over(Zip, label(labsize(tiny))) ytitle(Access to Healthcare) title(Access to Healthcare by Zip) name(Ac2HCxZip, replace)
graph save "Ac2HCxZip" "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/New/Ac2HCxZip.gph", replace

graph hbar (mean) Num_HealthServiceProv, over(Zip, label(labsize(tiny))) ytitle(Number of Health Service Providers) title(Number of Health Service Provider by Zip) name(Ac2HCxZip, replace)
graph save "Ac2HCxZip" "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/New/NumHCPxZip.gph", replace

graph hbar (mean) HousUnitCount, over(Zip, label(labsize(tiny))) ytitle(Housing Unit (count)) title(Housing Unit Count by Zip) name(HousCountxZip, replace)
graph save "HousCountxZip" "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/NewHousCountxZip.gph", replace

graph hbar (mean) Avg_Housollars_adjusted_, over(Zip, label(labsize(tiny))) ytitle(Average Household Income) title(Household Income by Zip) name(HousIncxZip, replace)
graph save "HousIncxZip" "/Users/kristinkelly/Documents/Academic/Rutgers/Classes/Fall19/DataManagement/HouseIncxZip.gph", replace


/* come back to this tabstat Avg_Housollars_adjusted_ Total_Nosurance_Coverage by(Zip) */

/************************/
/*     SIDE ANALYSIS    */
/************************/
* Originally planned to break this data down by census tract, but it doesn't have comprehensive geoidentifiers to do that. The prevalance rates are only provided on a county-level. So instead I've cleaned down the dataset of all counties in the State of Pennsylvania to include Philadelphia County and all of the surrounding PA counties (Bucks, Chester, Delaware, and Montgomery). Unfortunately, the state of New Jersey does not have the same data publicly available for their counties bordering Philadelphia, so for now this is where the analyses stop.

* Bringing in dataset #6: PA Healthy People 2020 (details above) 
/* commented out: github upload for Healthy people data "https://github.com/kekelly22/dmclass/blob/master/healthy-people-county%20(1).zip?raw=true" */
clear
unzipfile "https://www.health.pa.gov/topics/HealthStatistics/HealthyPeople/Documents/current/county/healthy-people-county.zip?", replace
insheet using healthy-people-county.csv, clear
keep if county_name=="Philadelphia"|county_name=="Bucks"|county_name=="Delaware"|county_name=="Montgomery"|county_name=="Chester"
drop data_type code goal goal_direction
drop if year!="2013-2017"
rename county_name County
list
* creating a new variable to identify the different health statistics. this helps me drop rows I'm uninterested in before I reshape 

replace topic="Cancer_DeathRate" if measure=="Cancer age-adjusted death rate per 100,000"
replace topic="PregnancyRate_age15to17" if measure=="Reported pregnancy rate per 1,000 females age 15 to 17"
replace topic="PregnancyRate_age18to19" if measure=="Reported pregnancy rate per 1,000 females age 18 to 19"
replace topic="CoronaryHD_DeathRate" if measure=="Coronary heart disease age-adjusted death rate per 100,000"
replace topic="Stroke_DeathRate" if measure=="Stroke age-adjusted death rate per 100,000"
replace topic="HIV_DeathRate" if measure=="HIV disease age-adjusted death rate per 100,000"
replace topic="Homicide_DeathRate" if measure=="Homicide age-adjusted rate per 100,000"
replace topic="Suicide_DeathRate" if measure=="Suicide age-adjusted rate per 100,000"
replace topic="InfantMortality_DeathRate" if measure=="Infant mortality rate per 1,000 live births"
replace topic="DrugInduced_DeathRate" if measure=="Drug-induced age-adjusted death rate per 100,000"

drop measure year
keep if topic=="Cancer_DeathRate"|topic=="PregnancyRate_age15to17"|topic=="PregnancyRate_age18to19"|topic=="CoronaryHD_DeathRate"|topic=="Stroke_DeathRate"|topic=="HIV_DeathRate"|topic=="Homicide_DeathRate"|topic=="Suicide_DeathRate"|topic=="InfantMortality_DeathRate"|topic=="DrugInduced_DeathRate"

reshape wide rate, i(county_fips) j(topic) string 
order County 
foreach var in rateCancer_DeathRate rateCoronaryHD_DeathRate rateDrugInduced_DeathRate rateHIV_DeathRate rateHomicide_DeathRate rateInfantMortality_DeathRate ratePregnancyRate_age15to17 ratePregnancyRate_age18to19 rateStroke_DeathRate rateSuicide_DeathRate {
	rename `var' `var'17  
	destring, replace
}
save phlHP2020, replace

/******************/
/*     VISUALS    */
/******************/
* Creating pie charts of the distribution of homicides or suicides across this cluster of counties in Southeastern PA.
graph pie rateHomicide_DeathRate17, over(County) plabel(_all percent, color(dknavy%80) size(vsmall)) intensity(inten90) title(Homicide Rates by County) legend(on) name(HomicidexCounty, replace)
graph save "HomicidexCounty", replace
graph pie rateSuicide_DeathRate, over(County) plabel(_all percent, color(dknavy%80) size(vsmall)) intensity(inten90) title(Suicide Rates by County) legend(on) name(SuicidexCounty, replace)
* Interpretation: You can see that Philadelphia County has significantly more deaths due to homicide than any of the surrounding counties. You can also tell that suicide is reported almost equally across counties, which indicates that suicide rates transcend other health systems or social systems of an area.

* Add in: more lines of code (twice as much), more visuals, t-tests/ANOVAS, give stronger interpretations related back to hypotheses/research questions, add in more data {not necessarily in merged set, but a side study}, add in tests/visuals of side demographics (elderly, etc) for more code, add in counties surrounding philadelphia county and do comparison of health rates (in dataset #6)
