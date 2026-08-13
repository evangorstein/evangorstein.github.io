#delimit;
clear;
set mem 300m;
set matsize 800;
set more off;
pause on;


****************************************************************************
***** This File Reads the Raw NLSY79 and Create Final Cleaned Samples. *****
****************************************************************************;

* We thank Fabian Lange for providing us with his code. His program for extracting data from the 
  NLSY79 has been modified here to fulfill our specific needs;

use maindata.dta,clear;
	***** Basic Demographics *****;

rename R0000100  id;	rename R0000149  hid;	rename R0000300  MONTH79;	rename R0000500  YR79;
rename R0173600  sample;rename R0214700  RACE79;rename R0214800  SEX79;		rename R0410100  MONTH81;
rename R0410300  YR81;	rename R0810200  SEX82;

	*GENERATE YEAR OF BIRTH USING DATA FROM TWO YEARS - STEVE McCLASKEY OF CHRR SUGGESTED THIS RULE
	The nlsy asked for the date of birth in 2 years, 1979 and 1981. This information is used to 
	create a cleaner age measure;

gen year=0;
replace year=YR81 if YR81 > 0;	replace year=YR79 if YR81 <=0;
gen month=0;				replace month=MONTH81 if MONTH81 > 0;	replace month=MONTH79 if MONTH81 <=0;

	*Generate sets of demographic dummies;
gen hisp=0;		replace hisp=1 if RACE79==1;	gen black=0;	replace black=1 if RACE79==2;
gen female=0;	replace female=1 if SEX82==2;	replace female=1 if SEX82 < 0 & SEX79==2;

	*Classify the samples;
replace sample=1 if sample>=1&sample<=8;
replace sample=2 if sample>=9&sample<=14;
replace sample=3 if sample>=15&sample<=20;
label var sample "1=cross-sec, 2=supplemental, 3=military";

drop R*;sort id;
save temp.dta,replace;
	
	***** Highest Grade completed *****;

use maindata, clear;	
rename R0000100 id;
rename R0216701 hgc79;rename R0406401 hgc80;rename R0618901 hgc81;rename R0898201 hgc82;
rename R1145001 hgc83;rename R1520201 hgc84;rename R1890901 hgc85;rename R2258001 hgc86;
rename R2445401 hgc87;rename R2871101 hgc88;rename R3074801 hgc89;rename R3401501 hgc90;
rename R3656901 hgc91;rename R4007401 hgc92;rename R4418501 hgc93;rename R5103900 hgc94;
rename R5166901 hgc96;rename R6479600 hgc98;rename R7007300 hgc100;rename R7704400 hgc102;
rename R8496800 hgc104; 
keep hgc* id;

reshape long hgc, i(id) j(year);

*bottom code at 6 years of education;
gen below6=0;
replace below6=1 if hgc<6 & hgc>=0;	replace hgc=6 if hgc<6 & hgc>=0;	replace hgc=6 if hgc>90;

reshape wide hgc below6, i(id) j(year);
*extra cleaning
for X in num 79/94 96 98 100 102 104: replace hgcX=. if hgcX<0;

sort id;merge id using temp;drop _merge;sort id;
save temp, replace;


	***** Employment Status, Class of Workers, Hours worked *****;


use maindata, clear;

rename R0000100  id;
rename R0046800 cls79;		rename R0214900 esr79;
rename R0094700 curr1job79;	rename R0094800 curr2job79;	rename R0094900 curr3job79;
rename R0095000 curr4job79;	rename R0095100 curr5job79;	      
rename R0263500 cls80;		rename R0406300 esr80;
rename R0337700 curr1job80;	rename R0349200 curr2job80;	rename R0360700 curr3job80;
rename R0372200 curr4job80;	rename R0383700 curr5job80;	      
rename R0446600 cls81;		rename R0618800 esr81;      
rename R0545500 curr1job81;	rename R0558600 curr2job81;	rename R0571700 curr3job81;
rename R0584800 curr4job81;	rename R0597900 curr5job81;
rename R0702300 cls82;		rename R0898500 esr82;
rename R0840100 curr1job82;	rename R0853200 curr2job82;	rename R0866300 curr3job82;
rename R0879400 curr4job82;	rename R0892500 curr5job82;
rename R0945400 cls83;		rename R1144700 esr83;
rename R1087200 curr1job83;	rename R1100400 curr2job83;	rename R1113600 curr3job83;
rename R1126800 curr4job83;	rename R1140000 curr5job83;
rename R1255800 cls84;		rename R1519900 esr84;
rename R1462900 curr1job84;	rename R1476000 curr2job84;	rename R1489100 curr3job84;
rename R1502200 curr4job84;	rename R1515300 curr5job84;      
rename R1650600 cls85;		rename R1890600 esr85;
rename R1809700 curr1job85;	rename R1822400 curr2job85;	rename R1835100 curr3job85;
rename R1847800 curr4job85;	rename R1860500 curr5job85;       
rename R1923200 cls86;		rename R2257700 esr86;
rename R2171400 curr1job86;	rename R2185000 curr2job86;	rename R2198600 curr3job86;
rename R2212200 curr4job86;	rename R2225800 curr5job86;      
rename R2318000 cls87;		rename R2445100 esr87;
rename R2376200 curr1job87;	rename R2387500 curr2job87;	rename R2398800 curr3job87;
rename R2410100 curr4job87;	rename R2421400 curr5job87;
rename R2525800 cls88;		rename R2870600 esr88;
rename R2770800 curr1job88;	rename R2783700 curr2job88;	rename R2796600 curr3job88;
rename R2809500 curr4job88;	rename R2822400 curr5job88;      
rename R2924800 cls89;		rename R3074300 esr89;
rename R3012600 curr1job89;	rename R3025700 curr2job89;	rename R3038800 curr3job89;
rename R3051900 curr4job89;	rename R3065000 curr5job89;      
rename R3127500 cls90;		rename R3401000 esr90;
rename R3340000 curr1job90;	rename R3354000 curr2job90;	rename R3368000 curr3job90;
rename R3382000 curr4job90;	rename R3396000 curr5job90;     
rename R3523200 cls91;		rename R3656400 esr91;
rename R3604300 curr1job91;	rename R3616400 curr2job91;	rename R3628500 curr3job91;
rename R3640600 curr4job91;	rename R3652700 curr5job91;           
rename R3728200 cls92;		rename R4006900 esr92;
rename R3954500 curr1job92;	rename R3966700 curr2job92;	rename R3978900 curr3job92;
rename R3991100 curr4job92;	rename R4003300 curr5job92;
rename R4182300 cls93;		rename R4418000 esr93;
rename R4586700 clsa94;		rename R4586800 clsb94;	rename R4587900 clsc94;	rename R5081000 esr94;
rename R5268800 clsa96;		rename R5268900 clsb96;	rename R5270400 clsc96;	rename R5166300 esr96;
rename R5925000 clsa98;		rename R5925800 clsb98;	rename R5936600 clsc98;	rename R6478900 esr98;

rename R6592300 cls100;		rename R6555000 esr100;
rename R7210100 cls102;		rename R7181300 esr102;
rename R7898500 cls104;		rename R7866700 esr104;


*** Bring in how many hours per week the worker worked at job;

rename R0070500 hrsweekj179; rename R0070600 hrsweekj279; rename R0070700 hrsweekj379; rename R0070800 hrsweekj479; rename R0070900 hrsweekj579;
rename R0264300 hrsweek80; rename R0446900 hrsweek81; rename R0702600 hrsweek82; rename R0945700 hrsweek83; rename R1256100 hrsweek84;
rename R1650900 hrsweek85; rename R1923500 hrsweek86; rename R2318300 hrsweek87; rename R2526100 hrsweek88; rename R2925100 hrsweek89;
rename R3127900 hrsweek90; rename R3523600 hrsweek91; rename R3728600 hrsweek92; rename R4182600 hrsweek93; rename R4540300 hrsweek94; 
rename R5236400 hrsweek96; rename R5838200 hrsweek98; rename R6578200 hrsweek100;rename R7192900 hrsweek102;rename R7879600 hrsweek104;
                                           

*** esr for years after 98 is just whether the worker is currently holding job 1 or not (not created by NLSY for these years)
replace esr100=3 if esr100==0;
replace esr102=3 if esr102==0;
replace esr104=3 if esr104==0;

drop R*;
reshape long esr cls clsa clsb clsc hrsweekj1 hrsweekj2 hrsweekj3 hrsweekj4 hrsweekj5 hrsweek curr1job curr2job curr3job curr4job curr5job, i(id) j(year);
replace cls=clsa if (year>93&clsa>-3) & year<100;
replace cls=clsb if (year>93&clsb>-3) & year<100;
replace cls=clsc if (year>93&clsc>-3) & year<100;

*coding changed in 1994;
generate temp1=.;
replace temp1=1 if (year>93&(cls==2|cls==3))& year<100;
replace temp1=2 if (year>93&cls==1)& year<100;
replace temp1=3 if (year>93&cls==4)& year<100;
replace temp1=4 if (year>93&cls==5)& year<100;

replace cls=temp1 if temp1~=.;
***;

*"code" will tell us a person's employment status -  -9 = coding error but working 
0 = interviewed, non-milt, not working, 1 = working for pay, 2 = non-interview,
3 = military & no civilian job, 4= self-employed, 5 - working w/o pay 			*****;

gen code=-99;
replace code=-9 if (cls>-4 & cls<0) & (esr==1 | esr==2);
replace code=0 if cls==-4 | ((cls>-4 & cls<0) & (esr>2 & esr~=8));
replace code=2 if esr==-5;
replace code=3 if esr==8;
replace code=1 if cls==1 | cls==2;
replace code=4 if cls==3;
replace code=5 if cls==4;

lab def xx -9 "coding error";
lab def xx 0  "interviewed and not working",add;
lab def xx 2 "non-interview",add;
lab def xx 3 "military w/ no civilian job",add;
lab def xx 1 "working for pay ",add;
lab def xx 4 "self-employed  ",add;
lab def xx 5 "working w/o pay",add;
label values code xx;


*Determine CPSJOB;
generate CPSJOB=0;
for Y in num 5(1)1: replace CPSJOB=Y if currYjob==1;
drop curr*;

replace CPSJOB=1 if year>92;

* Determine how many hours per week are worked;
for Y in num 1(1)5: replace hrsweek=hrsweekjY if CPSJOB==Y & year==79;


keep id code cls esr year hrsweek;
reshape wide code cls esr hrsweek, i(id) j(year);


sort id;merge id using temp;drop _merge;sort id;
save temp,replace;


	**** Average Hourly Rate of Pay *****;

use maindata.dta, clear;

rename R0000100  id;
rename R0047010  HRP79;rename R0263710  HRP80;rename R0446810  HRP81;rename R0702510  HRP82;rename R0945610  HRP83;
rename R1256010  HRP84;rename R1650810  HRP85;rename R1923410  HRP86;rename R2318210  HRP87;rename R2526010  HRP88;
rename R2925010  HRP89;rename R3127800  HRP90;rename R3523500  HRP91;rename R3728500  HRP92;rename R4416800  HRP93;
rename R5079800  HRP94;rename R5165200  HRP96;rename R6478000  HRP98;rename R7005700  HRP100;rename R7702900 HRP102; rename R8495200 HRP104;


	**** Is Residence Urban or Not ****;

rename R0215100 urban79;	rename R0393510 urban80;	rename R0646900 urban81;	rename R0897800 urban82;
rename R1146500 urban83;	rename R1521600 urban84;	rename R1892300 urban85;	rename R2259400 urban86;
rename R2446900 urban87;	rename R2872700 urban88;	rename R3076400 urban89;	rename R3403100 urban90;
rename R3658500 urban91;	rename R4009000 urban92;	rename R4420100 urban93;	rename R5083100 urban94;
rename R5168400 urban96;	rename R6481200 urban98;	rename R7008900 urban100;	rename R7706200 urban102;
rename R8498600 urban104;

	*** What Region Did the Respondent Live In ***;

rename R0216400 region79 ;rename R0405700 region80 ;rename R0602810 region81 ;
rename R0897910 region82 ;rename R1144800 region83 ;rename R1520000 region84 ;
rename R1890700 region85 ;rename R2257800 region86 ;rename R2445200 region87 ;
rename R2870800 region88 ;rename R3074500 region89 ;rename R3401200 region90 ;
rename R3656600 region91 ;rename R4007100 region92 ;rename R4418200 region93 ;
rename R5081200 region94 ;rename R5166500 region96 ;rename R6479100 region98 ;
rename R7006800 region100;rename R7704100 region102;rename R8496500 region104;

	*** What Major Did They Have in College? ***;

rename R0021600 major79 ;rename R0230900 major80 ;rename R0419100 major81 ;
rename R0666200 major82 ;rename R0907500 major83 ;rename R1207800 major84 ;
rename R1607000 major85 ;rename R1907400 major86 ;rename R2511300 major88 ;
rename R2910200 major89 ;rename R3112200 major90 ;rename R3712700 major92 ;
rename R4140300 major93 ;rename R4528700 major94 ;rename R5224000 major96 ;
rename R6467800 major98 ;rename R6543300 major100;rename R7106500 major102;

*Major is missing for these years;
g major87=.;
g major91=.;

g majorfield=.;
for num 79/93 94 96 98 100 102: replace majorfield=majorX if majorX>0 & majorX~=.;

	**** How Many jobs Were Ever Reported ***;

rename R0216020 jobsever79;	rename R0407510 jobsever80;	rename R0646610 jobsever81;	rename R0897720 jobsever82;
rename R1146320 jobsever83;	rename R1521520 jobsever84;	rename R1892220 jobsever85;	rename R2259320 jobsever86;
rename R2446810 jobsever87;	rename R2872610 jobsever88;	rename R3076800 jobsever89;	rename R3403500 jobsever90;
rename R3658900 jobsever91;	rename R4009400 jobsever92;	rename R4420500 jobsever93;	rename R5083500 jobsever94;	
rename R5168800 jobsever96;	rename R6481600 jobsever98;	rename R7009300 jobsever100;	rename R7706600 jobsever102;	
rename R8499000 jobsever104;

	***CPI-U Numbers from ERP 2001  
1979 - 72.6		1980 - 82.4		1981 - 90.9		1982 - 96.5		1983 - 99.6		1984 - 103.9	1985 - 107.6
1986 - 109.6	1987 - 113.6	1988 - 118.3	1989 - 124.0	1990 - 130.7	1991 - 136.2	1992 - 140.3
1993 - 144.5	1994 - 148.2	1996 - 156.9	1998 - 163.0	2000 - 172.4	2002 - 179.9	2004 - 184.3;

gen AHRP79=HRP79/(72.6/130.7);	gen AHRP80=HRP80/(82.4/130.7);	gen AHRP81=HRP81/(90.9/130.7);	gen AHRP82=HRP82/(96.5/130.7);
gen AHRP83=HRP83/(99.6/130.7);	gen AHRP84=HRP84/(103.9/130.7);	gen AHRP85=HRP85/(107.6/130.7);	gen AHRP86=HRP86/(109.6/130.7);
gen AHRP87=HRP87/(113.6/130.7);	gen AHRP88=HRP88/(118.3/130.7);	gen AHRP89=HRP89/(124/130.7);		gen AHRP90=HRP90;
gen AHRP91=HRP91/(136.2/130.7);	gen AHRP92=HRP92/(140.3/130.7);	gen AHRP93=HRP93/(144.5/130.7);	gen AHRP94=HRP94/(148.2/130.7);
gen AHRP96=HRP96/(156.9/130.7);	gen AHRP98=HRP98/(163.0/130.7);	gen AHRP100=HRP100/(172.4/130.7);	gen AHRP102=HRP102/(179.9/130.7); 
gen AHRP104=HRP104/(184.3/130.7);

for num 79/93 94 96 98 100 102 104: replace AHRPX=. if AHRPX<0;

keep id AHRP79 AHRP80 AHRP81 AHRP82 AHRP83 AHRP84 AHRP85 AHRP86 AHRP87 AHRP88 AHRP89 AHRP90 AHRP91 AHRP92 AHRP93 AHRP94 AHRP96 AHRP98 AHRP100 AHRP102 AHRP104 urban* jobsever* major* region*;
sort id;merge id using temp;drop _merge;sort id;
save temp, replace;
*/;




	**** Test Data ****;

use maindata, clear;
rename R0000100 id;		rename R0000149 hid;		rename R0000300 birthmt79;
rename R0000500 birthyr79;	rename R0000600 age79;		rename R0410100 birthmt81;
rename R0410300 birthyr81;	rename R0410500 age81;		rename R0410600 agecor81;
rename R0615100 AFQTsect2;	rename R0615200 AFQTsect3;	rename R0615300 AFQTsect4;
rename R0615400 AFQTsect5;	rename R0618200 AFQTperc;	rename R0615000 AFQTsect1;
rename R0615500 AFQTsect6;	rename R0615600 AFQTsect7;	rename R0615700 AFQTsect8;
rename R0615800 AFQTsect9;	rename R0615900 AFQTsect10;

rename R0619700 psatmath;	rename R0619800 psatverb;
rename R0619900 satmath;	rename R0620000 satverb;
rename R0620100 actmath;	rename R0620200 actverb;
rename R0618300 afqt89;
drop R*;

***clean age81***;;
replace age79=. if age79<0;
replace age81=. if age81<0;
replace agecor=. if agecor<0;
replace age81=age79+2 if agecor==0;
replace age81=age79+2 if age81==.;
drop birthmt* age79 agecor;

***calculate afqt standardized scores***;
for num 1/10: replace AFQTsectX=. if AFQTsectX<0;
replace AFQTperc=. if AFQTperc<0;
replace afqt89=. if afqt89<0;
generate AFQTscore=AFQTsect2+AFQTsect3+AFQTsect4+0.5*AFQTsect5;
*drop AFQTsect*;

sort age81;
by age81: egen AFQTsd=sd(AFQTscore);
by age81: egen AFQTmn=mean(AFQTscore);

replace AFQTscore=(AFQTscore-AFQTmn)/AFQTsd;

sort age81;
by age81: egen afqt89sd=sd(afqt89);
by age81: egen afqt89mn=mean(afqt89);

replace afqt89=(afqt89-afqt89mn)/afqt89sd;


label var AFQTscore "age standardized AFQT score";
keep id AFQTscore AFQTsect* psat* sat* act* afqt89 age81;
sort id;merge id using temp;drop _merge;sort id;
save temp, replace;


		***** First Graduation Date *****;

use maindata, clear;
generate gy=.;generate gm=.;

rename R0000100 id;
replace gy=R5821501 if R5821300==0;	replace gm=R5821500 if R5821300==0; replace gy=R5221501 if R5221300==0;	replace gm=R5221500 if R5221300==0;
replace gy=R4526201 if R4526000==0;	replace gm=R4526200 if R4526000==0; replace gy=R4137601 if R4137400==0;	replace gm=R4137600 if R4137400==0;
replace gy=R3709900 if R3709600==0;	replace gm=R3709800 if R3709600==0; replace gy=R3509900 if R3509600==0;	replace gm=R3509800 if R3509600==0;
replace gy=R3109900 if R3109600==0;	replace gm=R3109800 if R3109600==0; replace gy=R2907800 if R2907500==0;	replace gm=R2907700 if R2907500==0;
replace gy=R2508700 if R2508400==0;	replace gm=R2508600 if R2508400==0; replace gy=R2306200 if R2305900==0;	replace gm=R2306100 if R2305900==0;
replace gy=R1905300 if R1905000==0;	replace gm=R1905200 if R1905000==0; replace gy=R1604800 if R1604500==0;	replace gm=R1604700 if R1604500==0;
replace gy=R1205500 if R1205200==0;	replace gm=R1205400 if R1205200==0; replace gy=R0905600 if R0905300==0;	replace gm=R0905500 if R0905300==0;
replace gy=R0664200 if R0663900==0;	replace gm=R0664100 if R0663900==0; replace gy=R0417100 if R0416800==0;	replace gm=R0417000 if R0416800==0;
replace gy=R0228800 if R0228500==0;	replace gm=R0228700 if R0228500==0; replace gy=R0017000 if R0015600==0;	replace gm=R0016900 if R0015600==0;

label var gy "year of first graduation";
label var gm "month of first graduation";

replace gy=. if gy<=0;
replace gm=. if gm<=0;

for X in num 63/98: replace gy=X if gy==19X;

*** Need to know at what interview the person reported that s/he was not in school so that would be the first job;
g firstjob=.;

replace firstjob=98 if R5821300==0;	 replace firstjob=96 if R5221300==0;	
replace firstjob=94 if R4526000==0;	 replace firstjob=93 if R4137400==0;	
replace firstjob=92 if R3709600==0;	 replace firstjob=91 if R3509600==0;	
replace firstjob=90 if R3109600==0;	 replace firstjob=89 if R2907500==0;	
replace firstjob=88 if R2508400==0;	 replace firstjob=87 if R2305900==0;	
replace firstjob=86 if R1905000==0;	 replace firstjob=85 if R1604500==0;	
replace firstjob=84 if R1205200==0;	 replace firstjob=83 if R0905300==0;	
replace firstjob=82 if R0663900==0;	 replace firstjob=81 if R0416800==0;	
replace firstjob=80 if R0228500==0;	 replace firstjob=79 if R0015600==0;	





rename R0215300 wkswork79; rename R0406700 wkswork80; rename R0645800 wkswork81;
rename R0897300 wkswork82; rename R1145800 wkswork83; rename R1521000 wkswork84;
rename R1891700 wkswork85; rename R2258800 wkswork86; rename R2446200 wkswork87;
rename R2872000 wkswork88; rename R3075700 wkswork89; rename R3402400 wkswork90;
rename R3657800 wkswork91; rename R4008300 wkswork92; rename R4419400 wkswork93;
rename R5082400 wkswork94; rename R5167700 wkswork96; rename R6480500 wkswork98;
rename R7008200 wkswork100;rename R7705500 wkswork102;rename R8497900 wkswork104;

rename R0215310 hrswork79 ;rename R0406800 hrswork80 ;rename R0646200 hrswork81 ;
rename R0897200 hrswork82 ;rename R1145700 hrswork83 ;rename R1520900 hrswork84 ;
rename R1891600 hrswork85 ;rename R2258700 hrswork86 ;rename R2446100 hrswork87 ;
rename R2871900 hrswork88 ;rename R3075600 hrswork89 ;rename R3402300 hrswork90 ;
rename R3657700 hrswork91 ;rename R4008200 hrswork92 ;rename R4419300 hrswork93 ;
rename R5082300 hrswork94 ;rename R5167600 hrswork96 ;rename R6480400 hrswork98 ;
rename R7008100 hrswork100;rename R7705400 hrswork102;rename R8497800 hrswork104;



drop R*;

sort id;merge using temp;drop _merge;sort id;


		***** Actual Experience *****
*** Now I want to create a cummulative measure of actual experience:
	-	replace negative responses with 0, since these are either skips or non-
		interviews
	- 	requires me to only consider individuals who graduate
		in 1979 or later.
	-	only allow for post-school experience. Thus if an individual
		has more weeks worked than possible based on the graduation year
		response, then replace with the max possible.
***;
*Do the wkswork;

for X in num 79/94 96 98 100 102 104: replace wksworkX=0 if wksworkX<0 \ replace wksworkX=. if gy<78;
generate cumwks79=0;
for X in num 79/94 96 98 100 102 104:replace wksworkX=(X-gy)*52 if ((X-gy)*52<wksworkX)&(X>gy)&wksworkX~=.;
replace cumwks79=cumwks79+wkswork79 if gy<=79&gy>=78;
for X in num 79/94 96 98 100 102 \ Y in num 80/94 96 98 100 102 104: generate cumwksY=0 \ replace cumwksY=cumwksX+wksworkY if gy<=Y&gy>=78;
drop wkswork*;

*Do the hrswork;

for X in num 79/94 96 98 100 102 104: replace hrsworkX=0 if hrsworkX<0 \ replace hrsworkX=. if gy<78;
generate cumhrs79=0;
for X in num 79/94 96 98 100 102 104:replace hrsworkX=(X-gy)*52*40 if ((X-gy)*52*40<hrsworkX)&(X>gy)&hrsworkX~=.;
replace cumhrs79=cumhrs79+hrswork79 if gy<=79&gy>=78;
for X in num 79/94 96 98 100 102 \ Y in num 80/94 96 98 100 102 104: generate cumhrsY=0 \ replace cumhrsY=cumhrsX+hrsworkY if gy<=Y&gy>=78;
drop hrswork*;


label data "data from maindata.do before selecting sample";
save clndata, replace;


	*****Including Sample Weights *****;
use maindata, clear;
rename R0000100 id;
rename R0216100 weight79; rename R0405200 weight80; 
rename R0614600 weight81; rename R0896700 weight82;
rename R1144400 weight83; rename R1519600 weight84;
rename R1890200 weight85; rename R2257300 weight86;
rename R2444500 weight87; rename R2870000 weight88;
rename R3073800 weight89; rename R3400200 weight90;
rename R3655800 weight91; rename R4006300 weight92;
rename R4417400 weight93; rename R5080400 weight94;
rename R5165700 weight96; rename R6466300 weight98;
rename R7006200 weight100; rename R7703400 weight102;
rename R8495700 weight104;	

drop R*;
sort id;
merge using clndata;drop _merge; sort id;
label data "data from maindata.do before selecting sample";
save clndata, replace;


	***** Experience Before 1978*****;

use maindata,clear;
rename R0015600 enroll;   rename R0017000 lastenroll; rename R0016900 lastenrollmo ; 
rename R0113700 mil;      rename R0030000 milmo;      rename R0030100 mily ;
rename R0115000 wks77;    rename R0115100 wks76 ;     rename R0115200 wks75 ;
rename R0115300 hrs77;    rename R0115400 hrs76 ;     rename R0115500 hrs75 ;
rename R0116100 fstjobyr; rename R0116000 fstjobmo;   rename R0116600 firstoccup;
rename R0000100 id;

replace wks75=. if wks75<0;            replace wks76=. if wks76<0;            replace wks77=. if wks77<0;
replace wks75=0 if mily<=75 & mily>0;  replace wks76=0 if mily<=75 & mily>0;  replace wks77=0 if mily<=75 & mily>0;
replace wks76=0 if mily==76;           replace wks77=0 if mily==76;           replace wks77=0 if mily==77;

g fjob=fstjoby if fstjoby>0;
replace fjob=lastenroll+1 if lastenroll>0 & fjob==.;

gen cumwks78=.  ;
replace cumwks78=(wks75+wks76+wks77) if (fjob==75 );
replace cumwks78=(wks76+wks77) if (fjob == 76);
replace cumwks78=(wks77) if (fjob == 77);
rename cumwks78 cumexp;
keep cumexp fjob id;
sort id;
merge using clndata;drop _merge; sort id;
label data "data from maindata.do before selecting sample";
save clndata, replace;


	***** Father's Education ******;

use maindata,clear;
rename R0000100 id;
rename R0007900 feduc;
drop R*; sort id;
merge using clndata;drop _merge; sort id;
label data "data from maindata.do before selecting sample";
save clndata, replace;


***************************************************************************;

        ******************************************
		***** Sample Selection, Data Cleaning*****
		******************************************;
clear;
set mem 800m;
use clndata, clear;

*reshape long;
rename year brtyear;
reshape long AHRP urban jobsever region major esr cls code hgc below6 cumwks cumhrs hrsweek weight, i(id) j(year);

* Generate age, potential experience; 
generate age=year-brtyear;
generate exper=year-gy;

* Creat logwage variable;
generate logwage=.;replace logwage=log(AHRP) if AHRP>0&AHRP~=.;

* Keep only blacks and whites;
drop if hisp==1;

* First interview starts at 1979;
drop if year<79;

*Keep only individuals that have left school already;
drop if gy>year;

*Keep only individuals working for pay;
generate select=1;
replace select=0 if code~=1;

*Keep only individuals with wages between $1 and $100 following Altonji and Pierret (2001);
replace select=0 if AHRP<100|AHRP>10000;

*Keep people that were interviewed but were unemployed to use for robustness check;
replace select=2 if code==0;

* Drop if the experience before 78 cannot be constructed;
drop if cumexp==. & gy<78;
replace cumwks=cumwks+cumexp if gy<78;
drop if cumwks==.;

* Drop if education is less then 8;
drop if hgc<8 | hgc==.;

* Clean up the experience variables;
g experience=cumwks/52;
drop if exper==.;
drop if hgc==.;
bysort id: egen minhgc=min(hgc) if hgc<17;
replace exper=exper-(hgc-minhgc);
drop if exper<0;
drop minhgc;

* Drop if logwage is missing or not valid job. Replace logwage with 0 for people not working at the time of interview
  in order to use it for robustness checks;
replace logwage=0 if select==2;
drop if logwage==.;

*Clean up AFQT, urban, region;
drop if AFQTscore==.;
drop if urban<0; replace urban=. if urban==2;
replace region=. if region<0;

* Select the sample to keep people with valid jobs;
keep if select==1 | select==2;
drop if esr<1 & select==1;
drop if esr>2 & select==1;
replace firstjob=fjob if gy<78;
drop if firstjob>year;

* Create part time status;
replace hrsweek=. if hrsweek<0;
g ptime=1 if hrsweek<30;
replace ptime=0 if ptime==.;

* Recode college major so it collects subfields under one field;
replace major=majorfield;
for X in num 0/23: replace major=X if majorfield>=X*100 & majorfield<(X+1)*100;
replace major=24 if majorfield>=4900 & majorfield~=.;

* Create interaction variables;
g afqt=AFQTscore; g educ=hgc; g ptexp=year-gy;
g afqt_ptexp=AFQTscore*ptexp; g educ_ptexp=hgc*ptexp;
g black_ptexp=black*ptexp; g ptexpsq=ptexp^2; g ptexpcub=ptexp^3;


label data "Final full data from maindata.do";
save fullsample.dta, replace;

keep if female==0 & select==1 & ptexp>0;
label data "Main specifications data from maindata.do";
save mainsample,replace;

erase temp.dta;
