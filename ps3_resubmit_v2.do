//good! there's progress! BUT:
//datasets to be merged should be 2 different not just collapsing and merging with the same
//should have emailed me earlier about reshape
//we should meet outside of the class to go over this

* Data Management ps3
* Thursday, October 17th, 2019
* Resubmission: Friday, October 25th, 2019
* Second Resubmission: Thursday, October 31st, 2019
* Kristin Kelly
* Stata version 16

/********/
/* DATA */
/********/

/* Different data sets sourced from ICSPR & The Arda:

* First data set - Study of Women's Health Across the Nation (SWAN), 2001-2003: Visit 05
Dataset. 
"The Study of Women's Health Across the Nation (SWAN), is a multisite longitudinal, epidemiologic 
study designed to examine the health of women during their middle years. The study examines the physical, 
biological, psychological, and social changes during this transitional period."
https://www.icpsr.umich.edu/icpsrweb/NACDA/series/253

* Second data set - Midlife in the United States (MIDUS) Series, 2013-2014.
"In 1995-1996, the MacArthur Midlife Research Network carried out a national survey of over 7,000 Americans 
aged 25 to 74 [ICPSR 2760]. The purpose of the study was to investigate the role of behavioral, psychological, and social 
factors in understanding age-related differences in physical and mental health."
https://www.icpsr.umich.edu/icpsrweb/NACDA/studies/36346

* Third data set - Behavioral Risk Factor Surveillance System (BRFSS), 2003. 
"The Behavioral Risk Factor Surveillance System (BRFSS) is a state-based system of health surveys that collects 
information on health risk behaviors, preventive health practices, and health care access primarily related to 
chronic disease and injury. For many states, the BRFSS is the only available source of timely, accurate data on health-related behaviors.
https://www.icpsr.umich.edu/icpsrweb/RCMD/studies/34085

* Fourth data set - Voice of the People, 2003. 
"This annual survey, fielded November 2003 to January 2004, was conducted in over 50 countries to 
solicit public opinion on social and political issues."
https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/24482

* Fifth data set - General Social Survey, 2016.
"the General Social Survey (GSS) has been monitoring societal change and studying the growing complexity of American society."
http://www.thearda.com/Archive/Files/Descriptions/GSS2016.asp
*/ 
//good

/**************/
/* HYPOTHESES */
/**************/
/* I started with the SWAN dataset on middle-age American women because I was interested in looking into health relations that may 
occur uniquely among that demographic. I decided to merge in more health data points, such as obesity markers, overall physical/mental health
ratings, health comparison reports, fitness levels, and average education levels, from the four additional datasets. 
My general hypotheses include:
* Women of color will be less likely to have general and women's-health healthcare providers.
* Women with higher reports of health comparison will engage in more physical activity compared to women who report lower health comparisons.
* Physical activity will correlate with less consumption of sweets on a daily basis.
* Physical health will correlate with higher reports of mental health.
* BMI will reflect a positive correlation with age, until women surpass the age of ~60 years and then BMI will begin to negatively correleate.
A lot of health correlations could be drawn from these datasets, but these hypotheseses reflect my first questions for the data.
* Higher caloric intake will not be significantly related to BMI.
* Women who report higher QOL will correlate with higher reports of Avg Physical and Mental health.
*/
//good
mkdir ~\kristinkellyPS3
cd ~\kristinkellyPS3

use "https://github.com/kekelly22/dmclass/blob/master/SWAN.dta?raw=true", clear

/***********/
/* looking */
/***********/

edit 

describe

/* editing */

keep AGE5 RACE ALCHL245 QLTYLIF5 PHYSACT5 WALKBIK5 WEIGHT5 BMI5 DTTKCAL5 PRVIDER5 /* this is where I finally realized what I wanted to keep*/

rename BMI5 BMI
rename WEIGHT5 Weight
rename QLTYLIF5 QoL
rename ALCHL245 Alc
rename AGE5 Age
rename DTTKCAL5 CalIn
rename PHYSACT5 PhysHComp
rename WALKBIK5 TimeWaBi

recode PRVIDER5 (1 =1 "Do not have Wom Healthcare") (2 =2 "Have Wom Healthcare"), gen(WomHC) //* recoding to create a new variable specifically for all participants with or without women's healthcare.*//

drop PRVIDER5

ta Alc, mi 
replace Alc=-9 if Alc==. //* Here I'm replacing any missing values for alchohol use. Blank or missing answers are replaced with the appropriate value label*/

ta RACE //* checking to make sure all participants have a response for race*//
recode RACE (1/3 5 =1 "POC")(4 =0 "Non-POC"), gen(POC) //* recoding to create a new variable specifically for all people of color (POC) and then white/caucasian people *//

ta Age 
recode Age (0/49 =1 "Under 50yo") (50/100 =2 "Over 50yo"), gen(AgeGroup) //* recoding to create a new variable specifically for women over or under 50 years old *//

save ps3, replace

/******************/
/* merge: MIDUS */
/******************/

use "https://github.com/kekelly22/dmclass/blob/master/MIDUS3.dta?raw=true", clear

keep M2ID M2FAMNUM SAMPLMAJ C1PRAGE C1PRSEX C1PA1 C1PA2 C1PA3 /*keeping the variables that I want to compare*/

drop if C1PRSEX == 1 /* dropping male observations*/

rename C1PA1 Avg_PhysH
rename C1PA2 Avg_MentH
rename C1PA3 Avg_HeaComp
rename C1PRAGE Age /*making sure age var have the same name*/

collapse Avg_PhysH Avg_MentH Avg_HeaComp, by(Age) /* creating unique variables for average reports of physical, mental, and comparison health for women by age*/



save MIDUS_ps3, replace

clear
use ps3

merge m:1 Age using MIDUS_ps3

ta _merge
ta Age
ta Age if _merge==2
drop if _merge!=3
drop _merge

/* My master data set had a limited age range, so some observations beyond my master age range were dropped with the merge. */

save ps3, replace


/***********/
/*   PS3   */
/***********/

/****************/
/* merge: BRFSS */
/****************/
/* MERGE #3: merging in data from Behavioral Risk Factor Surveillance System (BRFSS), 2003 -- merging in the average BMI-overweight and obese groups and health risk factors by age -- from ICPSR */

clear
unzipfile "https://github.com/kekelly22/dmclass/blob/master/BRFSS.dta.zip?raw=true"
use BRFSS

/* It took me forever to figure out- but I figured out how to clone my repository and have a local 
version on my laptop. Then I figured out how upload a zip file from my computer to github when it's more than 25mb. I know
you probably already know this, but you can upload data files over 25mb (but not larger than 100mb) to GitHub if you upload them
through the command in your computer's command prompt (for my Mac it's called terminal). It took a million articles and tutorials
but I finally got my biggest data set to upload this way! If it would be helpful, I could take the time to type up how I did 
this for my classmates/future students to use to upload bigger data sets to GitHub. One of the key articles I used is here:
https://help.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line */

drop if NUMWOMEN < 1 /* dropping observations from male-only households or male participants*/
drop if SEX==1
drop if IMPAGE==99 /* dropping if age is unknown or missing */

keep IYEAR NUMMEN NUMWOMEN GENHLTH MARITAL EDUCA EMPLOY INCOME2 WEIGHT SEX RFHLTH BMI3CAT IMPAGE

rename IMPAGE Age /* renaming age var to match between data sets */
rename BMI3CAT Avg_BMIgroup
rename RFHLTH Avg_HealthRiskFac

drop if Age<46|Age>58 /* dropping the obs from women younger or older than the age range of my current data set... in future management/merging would I be better off starting with one of these higher range data sets first?? */

recode Age (0/49 =1 "Under 50yo") (50/100 =2 "Over 50yo"), gen(AgeGroup) //* recoding to create a new variable specifically for women over or under 50 years old *//

collapse Avg_BMIgroup Avg_HealthRiskFac, by(AgeGroup) /* creating unique variables for average reports of physical, mental, and comparison health for women by age*/

save BRFSS_ps3, replace

clear
use ps3

merge m:1 AgeGroup using BRFSS_ps3

drop _merge

save ps3, replace

/* END MERGE #3 */


/**************/
/* merge: VOP */
/**************/


/* MERGE #4: merging in data from "Voice of the People" international data collection, 2003 -- found on ICSPR */

use "https://github.com/kekelly22/dmclass/blob/master/VoiceOfThePeople.dta?raw=true", clear

keep COUNTRY Q5 D1 D2 D3 D4 D5 D6

rename D1 Gender
rename D2 Age
rename D3 Education
rename Q5 Avg_ProspNextGen

drop if COUNTRY!=80 /* dropping observations from outside of the US because my master file is just for American women */
drop if Age==4 /* dropping missing values for age */

recode Age (1/2 =1 "Under 50yo") (3 =2 "Over 50yo"), gen(AgeGroup) //* recoding to create a new variable specifically for women over or under 50 years old *//

collapse Avg_ProspNextGen, by(AgeGroup)

save VOP_ps3, replace

use ps3
merge m:1 AgeGroup using VOP_ps3

drop _merge

save ps3, replace

/* END MERGE #4 */

/**************/
/* merge: GSS */
/**************/
/* MERGE #5: merging in data from the General Social Survey, 2016 -- found on The Arda */

use "https://github.com/kekelly22/dmclass/blob/master/General%20Social%20Survey,%202016.DTA?raw=true", clear

keep age agekdbrn sex parborn granborn pillok premarsx

rename age Age
rename premarsx Avg_MoralPrMaSex

drop if sex==1 /* only keeping women's data */
drop if Avg_MoralPrMaSex==0
drop sex /* dropping sex as a column now that I've already kept all of the women's data and I don't have a sex variable across my master */
 
recode Age (0/49 =1 "Under 50yo") (50/100 =2 "Over 50yo"), gen(AgeGroup) //* recoding to create a new variable specifically for women over or under 50 years old *//

collapse Avg_MoralPrMaSex, by(AgeGroup) /* creating unique variables for average reports of physical, mental, and comparison health for women by age*/

save GSS16_ps3, replace

use ps3

merge m:1 AgeGroup using GSS16_ps3

drop _merge

save ps3, replace

/* END MERGE #5 */

/* RESHAPE */

/* I'm so confused as to why I would/should reshape and how to do that with this dataset... I'm not sure what sort of variables in my set that would be usefully reshaped */


/*** Citations:
Gallup International, Inc. Voice of the People, 2003. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2009-04-28. 
 https://doi.org/10.3886/ICPSR24482.v1
 Ryff, Carol, Almeida, David, Ayanian, John, Binkley, Neil, Carr, Deborah S., Coe, Christopher, … Williams, David. Midlife in the United States (MIDUS 3), 
 2013-2014 . Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2019-04-30. https://doi.org/10.3886/ICPSR36346.v7
Smith, T. (2019, February 9). General Social Survey, 2016.
Sutton-Tyrell, Kim, Selzer, Faith, R. (Mary Francis Roy) Sowers, MaryFran, Neer, Robert, Powell, Lynda, Gold, Ellen B., … McKinlay, Sonja. Study of Women’s 
 Health Across the Nation (SWAN), 2001-2003: Visit 05 Dataset. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2018-10-18. 
 https://doi.org/10.3886/ICPSR30501.v2
United States Department of Health and Human Services. Centers for Disease Control and Prevention. Behavioral Risk Factor Surveillance System (BRFSS), 2003. 
 Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2013-08-05. https://doi.org/10.3886/ICPSR34085.v1
***/
