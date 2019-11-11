* Data Management ps4
* OG Deadline: Thursday, November 7th, 2019
* Extended Deadline: Monday, November 11th, 2019
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

/**************/
/* HYPOTHESES */
/**************/
/* I started with the SWAN dataset on middle-age American women because I was interested in looking into health relations that may 
occur uniquely among that demographic. I decided to merge in more health data points, such as obesity markers, overall physical/mental health
ratings, health comparison reports, fitness levels, and average education levels, from the four additional datasets. 
My general hypotheses include:
* Women of color will be less likely to have general and women's-health healthcare providers.
* Women with higher reports of health comparison will engage in more physical activity compared to women who report lower health comparisons.
* Physical activity will correlate with lower daily calorie intake.
* Physical health will correlate with higher reports of mental health.
* BMI will reflect a positive correlation with age, until women surpass the age of ~60 years and then BMI will begin to negatively correleate.
A lot of health correlations could be drawn from these datasets, but these hypotheseses reflect my first questions for the data.
* Higher caloric intake will not be significantly related to BMI.
* Women who report higher QOL will correlate with higher reports of Avg Physical and Mental health.
*/

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
/* END OF PS3 */




/* START OF PS4 */

/* commenting out until submission 
mkdir ~\kristinkellyPS4
cd ~\kristinkellyPS4 */

save ps4.dta, replace

graph bar Avg_MentH, over(Age)
graph save AvgMentHxAge, replace

graph bar Avg_PhysH, over(Age)
graph save AvgPhysHxAge, replace

/* Interpretation of graph: With these bar graphs, I intended to uncover if there were any significant appearing patterns for average mental and physical health across ages. There weren't any detectable patterns in the bar graphs- presumably because the ages are all responses from middle-aged/similar adults. I'd expect a more distinct pattern from a more age-diverse group. */

graph bar Weight, over(Age)
graph save WeightxAge, replace

/* Interpretation of graph: This visual reflects results that are supported by general health research for middle-age adults. Typically, adults will gain about 10 pounds every new decade of life after we turn 20 years old. Then the weight tends to plateau and hold steady from mid-40s to mid-60s. After entering our 60s, people tend to lose weight as they enter a geriatric life stage (Hutfless et al., 2013).  So while this bar graph isn't very exciting, it replicates known results for middle-age adults' weight scores. */

graph bar QoL, over(WomHC) /* I created this chart and realized that I had a significant # of missing values, so I went and removed the observations that didn't report if they did or did not have women's health healthcare providers. */
drop if WomHC==-1 /* removing missing ^^ */
graph bar QoL, over(WomHC) /*regraphed*/
graph save QoLxWomHC, replace
graph export QolxWomHC.pdf, as(pdf) name("Graph") 
/* I edited the Y axis to include markers in .25 intervals, so that the difference between groups was more distinguishable. 
I also changed the X axis label to show a general title about if women had a specific women's health care provider and then bars with "yes" and "no". 
Then I saved as a PDF so that I could upload the revised graph to Git. Is that the only way I can show you the slightly prettier version of my graph? */

/* Interpretation of graph: This graph shows that, on average, women without a women's health healthcare provider report an overall lower quality of life. This supports the idea that increased healthcare access and health resources will have an overall impact beyond typical health outcomes for women. 
However, this graph doesn't display if the difference between women with or without a women's health healthcare provider is statistically significant. To determine this, I'd need to run a one sample t-test. */

graph bar TimeWaBi, over(RACE)
graph save TimeWaBixRace, replace
/* Interpretation of graph: There is a small difference between racial groups' number of times they reported 30 minutes of walking or bike per week. The graph displays that Black middle-aged women report the least times and Chinese middle-aged women reported the most times. */


graph bar TimeWaBi, over(Age)
graph save TimeWaBixAge, replace
/* Interpretation of graph: There is a small increase in self-reports of time spent walking or bike each week as middle-aged women enter their 60s. I'm curious if this could be related to retirement and women having more free time to spend on exercise. */


/* this graph didn't work out for me. I was hoping to chart the different levels of daily caloric intake with lines for each race. It comes out looking really crazy...
graph twoway ///
line CalIn Age if RACE == 1 || ///
line CalIn Age if RACE == 2 || ///
line CalIn Age if RACE == 3 || ///
line CalIn Age if RACE == 4 || ///
line CalIn Age if RACE == 5 
*/


tabstat CalIn BMI, by(RACE)
/* This table shows the averages for both daily caloric intake and exact BMI for each racial group surveyed across my dataset.
Interpretation of table: Middle-aged women of Black and Hispanic racial backgrounds report the highest daily caloric intake, as well as the highest BMIs. In general, all racial backgrounds show higher daily intake associated with higher BMI. According to this table, middle-aged Chinese/Chinese-American women consume the least daily calories and have lower BMIs.  */

tabstat Avg_PhysH CalIn, by(Age)
/* This table shows average self-reports of physical health in realtion to daily caloric intake as separated by age. This reflects results for one of my hypotheses predicting higher reports of physical health to be associated with lower caloric intake. 
Interpretation of table: This table does not support my hypothesis, which may have a lot to do with the sample population of this data set. This table does correlate with known literature suggesting that daily intake does decrease as we get older. */

tabstat Avg_PhysH CalIn BMI, by(Age)
/* After running the previous table, I was interested to see how BMI may fit into the trends of caloric intake decreasing with age. 
Interpretation of table: In this table, we can see that the addition of BMI shows that, despite decreasing caloric intake and increased self-reports of physical health, middle-aged American women continue to have increasing BMIs as they reach their 60s. */

tabstat Avg_PhysH CalIn BMI TimeWaBi, by(Age)
/* After running the previous two tables, I added average time spent walking/biking per week to see how it may fit into the trends of caloric intake decreasing but BMI increasing with age. 
Interpretation of table: In this table, you can see that the probably insignificant levels of weekly physical exercise don't appear to have a relation to daily caloric intake or self-reports of physical health. This may suggest that middle-aged women experience changes in BMI regardless of physical activity levels. */

save ps4, replace



/*** Citations:
Gallup International, Inc. Voice of the People, 2003. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2009-04-28. 
 https://doi.org/10.3886/ICPSR24482.v1
 Ryff, Carol, Almeida, David, Ayanian, John, Binkley, Neil, Carr, Deborah S., Coe, Christopher, … Williams, David. Midlife in the United States (MIDUS 3), 
 2013-2014 . Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2019-04-30. https://doi.org/10.3886/ICPSR36346.v7
Hutfless, S., Maruthur, N. M., Wilson, R. F., Gudzune, K. A., Brown, R., Lau, B., ... 
	& Segal, J. B. (2013). Strategies to prevent weight gain among adults.
 Smith, T. (2019, February 9). General Social Survey, 2016.
Sutton-Tyrell, Kim, Selzer, Faith, R. (Mary Francis Roy) Sowers, MaryFran, Neer, Robert, Powell, Lynda, Gold, Ellen B., … McKinlay, Sonja. Study of Women’s 
 Health Across the Nation (SWAN), 2001-2003: Visit 05 Dataset. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2018-10-18. 
 https://doi.org/10.3886/ICPSR30501.v2
United States Department of Health and Human Services. Centers for Disease Control and Prevention. Behavioral Risk Factor Surveillance System (BRFSS), 2003. 
 Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2013-08-05. https://doi.org/10.3886/ICPSR34085.v1
***/
