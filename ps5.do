* Data Management ps5
* Thursday, November 14th, 2019
* Kristin Kelly
* Stata version 16

/* I hope you may be sympathetic to me recreating my project and dataset ()during one of the busiest times in the semester). I'm using what I have so far of my new data set for ps5 and constantly adding more. I'm excited for how much cleaner my code and dataset are so far, but I realize I have a lot more work to do. I tried to incorporate ps5 into this small new dataset rather than continuing to sink work into my old dataset. I'm striving to be fully caught up by class next week. */

/************/
/*   DATA   */
/************/
/* 
Dataset #1: From the CDC, "500 Cities: Census Tract-level Data" (2018)
https://chronicdata.cdc.gov/500-Cities/500-Cities-Census-Tract-level-Data-GIS-Friendly-Fo/k86t-wghb
https://www.cdc.gov/500cities/
"The 500 Cities project is a collaboration between CDC, the Robert Wood Johnson Foundation, and the CDC Foundation. The purpose of the 500 Cities Project is to provide city- and census tract-level small area estimates for chronic disease risk factors, health outcomes, and clinical preventive service use for the largest 500 cities in the United States."

Dataset #2: From the U.S. Census & City of Philadelphia and imported from OpenDataPhilly): "Census Tracts (2010). 
This is a data set of census tracts with their name, ID, XY coord. I'm merging this into my master set in order to widen the geographic information I have for other health data sets with only one or two geo-identifiers.
https://www.opendataphilly.org/dataset/census-tracts
"For matching and analyzing demographic data collected and compiled by the U.S. Census Bureau & American Community Survey(ACS) to the geography of Census Block Group boundaries within the City of Philadelphia."

I have half a dozen other datasets to pick from to create my final master set. I'm working on data in every free minute I have, but this was as much data and code that I could get together in the last 2 days since our meeting. */


/******************/
/*     LOOKING    */
/******************/

* bringing in data set #1: CDC 500 cities data (details above)
insheet using "https://github.com/kekelly22/dmclass/blob/master/500cities.csv?raw=true", clear

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
insheet using "http://data-phl.opendata.arcgis.com/datasets/8bc0786524a4486bb3cf0f9862ad0fbf_0.csv"
rename geoid10 tractfips /* for merging purposes */
keep tractfips intptlat10 intptlon10 /*keeping geo ID for merging and XY coord to strengthen other geo data with merge */
rename intptlat10 latitude
rename intptlon10 longitude
save ODP_censustracts, replace

/* MERGE 1 */
use 500cities, clear
merge 1:1 tractfips using ODP_censustracts
*8 non-merges (from 4)
drop if _merge!=3
drop _merge

drop place_tractid

save cdcTractMerge, replace

* bringing in dataset #3
/* the following code is commented out as I still work on describing and planning out these following datasets
insheet using 3.csv, clear
*zip_code (unique)
save 3, replace

insheet using 5.csv, clear
*zip (4 unique)
save 5, replace

insheet using 6.csv, clear
*zip (mostly unique)
save 6, replace
*/
