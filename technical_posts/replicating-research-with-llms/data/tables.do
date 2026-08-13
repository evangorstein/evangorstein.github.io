clear
set mem 200m

***************************
*** Table 1: Data Summary
***************************
clear
use mainsample

keep if educ==12 | educ==16

tab black
tab black if educ==12
tab black if educ==16

bysort black: summ afqt,
bysort educ: summ afqt if black==1,
bysort educ: summ afqt if black==0,

bysort black: tab urban
bysort black: tab urban if educ==12
bysort black: tab urban if educ==16

bysort black: tab region
bysort black: tab region if educ==12
bysort black: tab region if educ==16

bysort black: summ logwage

bysort black: summ logwage if age<25 
bysort black: summ logwage if age>=25 & age <30
bysort black: summ logwage if age>=30 & age <35
bysort black: summ logwage if age>=35 & age<40

bysort black: summ logwage if age<25 & educ==12
bysort black: summ logwage if age>=25 & age <30 & educ==12
bysort black: summ logwage if age>=30 & age <35 & educ==12
bysort black: summ logwage if age>=35 & age<40 & educ==12

bysort black: summ logwage if age<25 & educ==16
bysort black: summ logwage if age>=25 & age <30 & educ==16
bysort black: summ logwage if age>=30 & age <35 & educ==16
bysort black: summ logwage if age>=35 & age<40 & educ==16

bysort black: summ experience if age<25 & experience>0
bysort black: summ experience if age>=25 & age <30 & experience>0
bysort black: summ experience if age>=30 & age <35 & experience>0
bysort black: summ experience if age>=35 & age<40 & experience>0

bysort black: summ experience if age<25 & experience>0 & educ==12 
bysort black: summ experience if age>=25 & age <30 & experience>0 & educ==12
bysort black: summ experience if age>=30 & age <35 & experience>0 & educ==12
bysort black: summ experience if age>=35 & age<40 & experience>0 & educ==12

bysort black: summ experience if age<25 & experience>0 & educ==16 
bysort black: summ experience if age>=25 & age <30 & experience>0 & educ==16
bysort black: summ experience if age>=30 & age <35 & experience>0 & educ==16
bysort black: summ experience if age>=35 & age<40 & experience>0 & educ==16


bysort black: summ ptexp if age<25 & ptexp>0
bysort black: summ ptexp if age>=25 & age <30 & ptexp>0
bysort black: summ ptexp if age>=30 & age <35 & ptexp>0
bysort black: summ ptexp if age>=35 & age<40 & ptexp>0

bysort black: summ ptexp if age<25 & ptexp>0 & educ==12 
bysort black: summ ptexp if age>=25 & age <30 & ptexp>0 & educ==12
bysort black: summ ptexp if age>=30 & age <35 & ptexp>0 & educ==12
bysort black: summ ptexp if age>=35 & age<40 & ptexp>0 & educ==12

bysort black: summ ptexp if age<25 & ptexp>0 & educ==16 
bysort black: summ ptexp if age>=25 & age <30 & ptexp>0 & educ==16
bysort black: summ ptexp if age>=30 & age <35 & ptexp>0 & educ==16
bysort black: summ ptexp if age>=35 & age<40 & ptexp>0 & educ==16


************************************
*** Table 2: Main baseline results.
************************************
use mainsample,clear

    areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==12, cluster(id) absorb(year)
xi: areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub ptime i.region if ptexp<13 & educ==12, cluster(id) absorb(year)

    areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==16, cluster(id) absorb(year)
xi: areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub ptime i.region if ptexp<13 & educ==16, cluster(id) absorb(year)
 
*** Test of table 2
set matsize 800
keep if select==1 & female==0 & (educ==12 | educ==16)

xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year if ptexp<13, cluster(id) 
xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*ptime i.educ*i.region i.educ*i.year if ptexp<13, cluster(id) 


*****************************************
*** Table 3: Predicting AFQT
*****************************************
use mainsample,clear
duplicates drop id, force
replace satmath=. if satmath<0
replace psatmath=. if psatmath<0
replace actmath=. if actmath<0
replace satverb=. if satverb<0
replace psatverb=. if psatverb<0
replace actverb=. if actverb<0
g yrcol=educ-12
keep if yrcol>0 & yrcol<5 
g yrcolsq=yrcol^2

xi: areg afqt i.black*satmath i.black*satverb i.black*yrcol, cluster(id) absorb(major)
xi: areg afqt i.black*psatmath i.black*psatverb i.black*yrcol, cluster(id) absorb(major)
xi: areg afqt i.black*psatmath i.black*psatverb i.black*satmath i.black*satverb i.black*yrcol, cluster(id) absorb(major)
xi: areg afqt i.black*actmath i.black*actverb i.black*yrcol, cluster(id) absorb(major)
xi: areg afqt i.black*yrcol,cluster(id)  absorb(major)


*****************************************
*** Figure 1: AFQT distributions.
*****************************************
use mainsample,clear
g afqtwhite12=afqt if black==0 & educ==12
g afqtwhite16=afqt if black==0 & educ==16
g afqtblack12=afqt if black==1 & educ==12
g afqtblack16=afqt if black==1 & educ==16

twoway (hist afqtblack16, bcolor(black) bin(30))(hist afqtwhite16, bcolor(red) bin(30))
twoway (hist afqtblack12, bcolor(black) bin(30)) (hist afqtwhite12, bcolor(red) bin(30)) 
* The plots in the paper are done in matlab

*************************************
*** Figure 2: Nonparametric plots.
*************************************
use mainsample,clear
drop if educ<9
drop if educ>16
g geduc=educ
replace geduc=18 if educ>16
replace geduc=10 if educ<=11
replace geduc=14 if educ ==13 | educ==15 

statsby "areg logwage black afqt afqt_ptexp black_ptexp educ educ_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13, cluster(id) absorb(year)" _b, by(geduc) clear

graph twoway (bar b_afqt geduc) (scatter b_afqt geduc) 
graph twoway (bar b_afqt_ptexp geduc) (scatter b_afqt_ptexp geduc)
graph twoway (bar b_black geduc) (scatter b_black geduc) 

******************************************************
*** Table 4: Structural change at college graduation.
******************************************************

use mainsample,clear
gen dum=1 if educ>=16
replace dum=0 if dum==.
replace educ=educ-12
g black_educ=black*educ
g afqt_educ=afqt*educ
g black_ptexp_educ=black_ptexp*educ
g afqt_ptexp_educ=afqt_ptexp*educ
replace educ_ptexp=educ*ptexp
g educ_ptexpsq=educ_ptexp*ptexp
g educ_ptexpcub=educ_ptexpsq*ptexp
g educ_urban=educ*urban

xi: areg logwage i.dum*afqt i.dum*afqt_ptexp i.dum*black i.dum*black_ptexp  black_educ afqt_educ black_ptexp_educ afqt_ptexp_educ educ educ_ptexp educ_ptexpsq educ_ptexpcub urban ptexp ptexpsq ptexpcub if ptexp<13, cluster(id) absorb(year)

  

***********************************************
*** Figure 2: The structural parameters and CI.
***********************************************
use mainsample,clear
g black_ptexpsq=black_ptexp*ptexp
g black_ptexpcub=black_ptexpsq*ptexp
g afqt_ptexpsq=afqt_ptexp*ptexp
g afqt_ptexpcub=afqt_ptexpsq*ptexp

areg logwage afqt afqt_ptexp afqt_ptexpsq afqt_ptexpcub black black_ptexp black_ptexpsq black_ptexpcub urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==12, cluster(id) absorb(year)

* CI and parameters for AFQT
forvalues i=0(1)12 {
lincom afqt+afqt_ptexp*`i'+afqt_ptexpsq*`i'*`i'+afqt_ptexpcub*`i'*`i'*`i', level(90)
}

* CI and parameters for BLACK
forvalues i=0(1)12 {
lincom black+black_ptexp*`i'+black_ptexpsq*`i'*`i'+black_ptexpcub*`i'*`i'*`i', level(90)
}

* CI and parameters for LAMBDA
forvalues i=0(1)12 {
lincom afqt+afqt_ptexp*`i'+afqt_ptexpsq*`i'*`i'+afqt_ptexpcub*`i'*`i'*`i'-(black+black_ptexp*`i'+black_ptexpsq*`i'*`i'+black_ptexpcub*`i'*`i'*`i'), level(90)
}

* CI and parameters for Theta
forvalues i=0(1)12 {
nlcom (_b[afqt]+_b[afqt_ptexp]*`i'+_b[afqt_ptexpsq]*`i'*`i'+_b[afqt_ptexpcub]*`i'*`i'*`i')/(_b[afqt]+_b[afqt_ptexp]*`i'+_b[afqt_ptexpsq]*`i'*`i'+_b[afqt_ptexpcub]*`i'*`i'*`i'-(_b[black]+_b[black_ptexp]*`i'+_b[black_ptexpsq]*`i'*`i'+_b[black_ptexpcub]*`i'*`i'*`i')), level(90)
}


**********************************************
*** Table 5: The selection median regressions.
**********************************************
clear
use fullsample
keep if female==0 & (educ==12 |educ==16) & ptexp>0

bootstrap "xi: qreg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub i.year if ptexp<13 & educ==12 & female==0,nolog" _b, cluster(id) reps(1000)
bootstrap "xi: qreg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub i.region ptime i.year if ptexp<13 & educ==12 & female==0,nolog" _b, cluster(id) reps(1000)

bootstrap "xi: qreg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub i.year if ptexp<13 & educ==16 & female==0,nolog" _b, cluster(id) reps(1000)
bootstrap "xi: qreg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub i.year i.region ptime if ptexp<13 & educ==16 & female==0,nolog" _b, cluster(id) reps(1000)

bootstrap "xi: qreg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year if ptexp<13 & female==0,nolog" _b, cluster(id) reps(100)
bootstrap "xi: qreg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.educ*i.region i.educ*ptime if ptexp<13 & female==0,nolog" _b, cluster(id) reps(100)

****************************************************
*** Table 6: College vs first 4 years of experience.
****************************************************
use mainsample,clear
keep if(educ==12 | educ==16) & ptexp<13
drop if ptexp<4
areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==12, cluster(id) absorb(year)
xi: areg logwage afqt afqt_ptexp black black_ptexp urban ptexp ptexpsq ptexpcub ptime i.region if ptexp<13 & educ==12, cluster(id) absorb(year)

* Test that (high scool at ptexp=4)==(College at ptexp=0)
use mainsample,clear
keep if(educ==12 | educ==16) & ptexp<13
replace ptexp=ptexp-4 if educ==12
drop if ptexp<0
replace afqt_ptexp=afqt*ptexp if educ==12
replace black_ptexp=black*ptexp if educ==12
replace ptexpsq=ptexp*ptexp if educ==12
replace ptexpcub=ptexpsq*ptexp if educ==12

xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year if ptexp<13, cluster(id) 
xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.educ*i.region i.educ*ptime if ptexp<13, cluster(id) 


********************************
*** Table 7: Father's education.
********************************
use mainsample,clear

replace feduc=. if feduc<4
g feduc_ptexp=feduc*ptexp
g black_feduc=black*feduc
g black_feduc_ptexp=black*feduc*ptexp


areg logwage black black_ptexp feduc feduc_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==12, cluster(id) absorb(year)
areg logwage black black_ptexp feduc feduc_ptexp afqt afqt_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==12, cluster(id) absorb(year)

areg logwage black black_ptexp feduc feduc_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==16, cluster(id) absorb(year)
areg logwage black black_ptexp feduc feduc_ptexp afqt afqt_ptexp urban ptexp ptexpsq ptexpcub if ptexp<13 & educ==16, cluster(id) absorb(year)


**********************************
*** Table 8: Time varying effects.
**********************************
use mainsample, clear
set matsize 800
keep if educ==12 | educ==16

g afqtcol=afqt if educ==16
replace afqtcol=0 if educ==12
g afqths=afqt if educ==12
replace afqths=0 if educ==16

g blackcol=black if educ==16
replace blackcol=0 if educ==12
g blackhs=black if educ==12
replace blackhs=0 if educ==16

g afqt_ptexpcol=afqt_ptexp if educ==16
replace afqt_ptexpcol=0 if educ==12
g afqt_ptexphs=afqt_ptexp if educ==12
replace afqt_ptexphs=0 if educ==16

g black_ptexpcol=black_ptexp if educ==16
replace black_ptexpcol=0 if educ==12
g black_ptexphs=black_ptexp if educ==12
replace black_ptexphs=0 if educ==16


xi: reg logwage afqths afqtcol afqt_ptexphs afqt_ptexpcol blackhs blackcol black_ptexphs black_ptexpcol i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.year*afqt if ptexp<13, cluster(id)
xi: reg logwage afqths afqtcol afqt_ptexphs afqt_ptexpcol blackhs blackcol black_ptexphs black_ptexpcol i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.year*afqt i.year*black if ptexp<13, cluster(id)

*Test differences                
xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.year*afqt  if ptexp<13, cluster(id)
xi: reg logwage i.educ*afqt i.educ*afqt_ptexp i.educ*black i.educ*black_ptexp i.educ*urban i.educ*ptexp i.educ*ptexpsq i.educ*ptexpcub i.educ*i.year i.year*afqt i.year*black  if ptexp<13, cluster(id)



*******************************************
*** Figure 4: The residual Autocorrelation.
*******************************************

quietly forvalues v=12(4)16{
 quietly forvalues i=1(1)11 {
  clear
  use mainsample
  keep if educ==`v'
  local j=`i'+1
  xi: areg logwage  afqt black urban if ptexp==`i', cluster(id) absorb(year)
  predict resid`i',residuals
  xi: areg logwage  afqt black urban if ptexp==`j', cluster(id) absorb(year)
  predict resid`j',residuals
  sort id ptexp
  bysort id: g sel=1 if ptexp[1]==1 
  drop if sel~=1
  drop sel
  drop if resid`i'==. & resid`j'==.
  bysort id: g sel=1 if ptexp[2]==`j'
  drop if sel~=1
  bysort id: replace resid`j'=resid`j'[2]
  corr resid`i' resid`j'
  g rho`v'=r(rho)
  keep if _n==1
  keep rho`v'
  save rho`v'`i',replace
 }
 use rho`v'1,clear
 forvalues i=2(1)11{
  append using rho`v'`i'
 }
 g ptexp=_n
 save rho`v',replace
}

merge using rho12
drop _merge
rename rho12 rhohs
rename rho16 rhocol
save rho,replace

*Calculate the regression
use rho, clear
replace ptexp=ptexp-1
g ptexpsq=ptexp^2
g ptexpcub=ptexp^3

g auto12=rhohs/rhohs[1]-1
g auto16=rhocol/rhocol[1]-1

reg auto12 ptexp ptexpsq ptexpcub, noconst 
predict auto12hat
reg auto16 ptexp ptexpsq ptexpcub,noconst 
predict auto16hat

twoway (scatter auto12 ptexp) (line auto12hat ptexp) (scatter auto16 ptexp) (line auto16hat ptexp)


******************************************
*** Figure 5: The residual Std. Deviation.
******************************************
set more off
use mainsample,clear

quietly forvalues i=1(1)12 {

quietly xi: areg logwage  afqt black urban if ptexp==`i' & educ==12, absorb(year)
quietly predict residhs`i',residuals
summ residhs`i'
g stdhs`i'=r(sd)
quietly xi: areg logwage  afqt black urban if ptexp==`i' & educ==16, absorb(year)
quietly predict residcol`i',residuals
summ residcol`i'
g stdcol`i'=r(sd)
}
keep if _n==1
keep std*
g n=_n
reshape long stdhs stdcol,i(n) j(ptexp)
replace ptexp=ptexp-1
g ptexpsq=ptexp^2
g ptexpcub=ptexp^3

g SD12=stdhs/stdhs[1]-1
g SD16=stdcol/stdcol[1]-1

reg SD12 ptexp ptexpsq ptexpcub, noconst 
predict SD12_hat,xb

reg SD16 ptexp ptexpsq ptexpcub,noconst 
predict SD16_hat,xb
keep ptexp SD*

graph twoway (line SD12_hat ptexp) (line SD16_hat ptexp) (scatter SD12 ptexp) (scatter SD16 ptexp) 


