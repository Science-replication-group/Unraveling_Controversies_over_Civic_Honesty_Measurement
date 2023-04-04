********************************************************************************
********************************************************************************
*****Unraveling Controversies over Civic Honesty Measurement*****
********************************************************************************
********************************************************************************

sysuse auto, clear
cd "C:\" 

//field experiment data set
use "Replication experiment and others_data.dta", clear 
snapshot save

//survey data set
use "Online national representative survey_data.dta", clear
snapshot save


********************************************************************************
*****Manuscript*****
********************************************************************************

*********************Figure 1*******************
***** =====================================*****
//fig.1(a)
snapshot restore 1
tab r_hnsty_nocontact 
recode r_hnsty_nocontact (0 1 2 3 = 0 ) (4 5 6 = 100), gen(noemail_e)
tab noemail_e  //Failing to contact the owner of the lost wallet was relevant to civic honesty

tab r_hnsty_takeaway					   
recode r_hnsty_takeaway (0 1 2 3 = 0 ) (4 5 6 = 100), gen(takeaway_e)
tab takeaway_e	//Retaining one or all items of the lost wallet was relevant to civic honesty			   

graph bar noemail_e takeaway_e,  ///                              
      ylabel(0(20)100, tposition(inside) labsize(*0.8) angle(0) nogrid) ///
      ytitle("Reporting rate (%)", tstyle(smbody) justification(left)) ///
      blabel(bar, size(small) format(%9.2f)) ///
      bar(1, color(gs3) lwidth(thin))  ///
      bar(2, color(gs12) lwidth(thin)) ///
	  bargap(60) ///
      legend(row(1) ring(1) position(6) region(lcolor(white)) ///
	  label(1 "Failing to contact") ///
	  label(2 "Retaining the wallet") ///
	  order(1 2)  ///
	  size(small)) ///
	  title("(a) Behavior is relevant to personal integrity", tstyle(smbody)) ///
	  subtitle("in the field experiment", tstyle(smbody)) ///
	  graphregion(fcolor(white) lcolor(white)) ysize(10) xsize(6) name(fig_1_left, replace)

//fig.1(b)
snapshot restore 2
tab1 takeaway noemail
replace noemail=100 if noemail==1
replace takeaway=100 if takeaway==1

graph bar noemail takeaway,  ///                              
      ylabel(0(20)100, tposition(inside) labsize(*0.8) angle(0) nogrid) ///
      ytitle("Reporting rate (%)", tstyle(smbody)) ///
      blabel(bar, size(small) format(%9.2f)) ///
      bar(1, color(gs3) lwidth(thin))  ///
      bar(2, color(gs12) lwidth(thin)) ///
	  bargap(60) ///
      legend(row(1) ring(1) position(6) region(lcolor(white)) ///
	  label(1 "Failing to contact") ///
	  label(2 "Retaining the wallet") ///
	  order(1 2)  ///
	  size(small)) ///
	  title("(b) Behavior can be considered as a dishonest behavior", tstyle(smbody)) ///
	  subtitle("in the nationally representative survey", tstyle(smbody)) ///
	  graphregion(fcolor(white) lcolor(white)) ysize(10) xsize(6) name(fig_2_right, replace)

//combine figures
graph combine fig_1_left fig_2_right, rows(1) ycommon graphregion(fcolor(white) lcolor(white)) ysize(10) xsize(14)



*********************Table 1********************
***** =====================================*****
snapshot restore 1
keep money email wallet_recovery wallet_totalrecovery 
replace email=1 if email==100
replace wallet_recovery=1 if wallet_recovery==100
replace wallet_totalrecovery=1 if wallet_totalrecovery==100
tabstat email wallet_recovery wallet_totalrecovery, by(money) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist email wallet_recovery wallet_totalrecovery {
  tabulate `var' money, chi
}

*********************Table 2********************
***** =====================================*****
snapshot restore 1

//demean covariates
sum male age40 computer coworkers other_bystanders
egen mmale = mean(male)
gen dm_male = male - mmale

egen mage40 = mean(age40)
gen dm_age40 = age40 - mage40

egen mcomputer = mean(computer)
gen dm_computer = computer - mcomputer

egen mcoworkers = mean(coworkers)
gen dm_coworkers = coworkers - mcoworkers

egen mother_bystanders = mean(other_bystanders)
gen dm_other_bystanders = other_bystanders - mother_bystanders
tab1 dm_male dm_age40 dm_computer dm_coworkers dm_other_bystanders

//interaction between the treatment and demeaned covariates
gen dm_mm = money*dm_male
gen dm_ma = money*dm_age40
gen dm_mcp = money*dm_computer
gen dm_mck = money*dm_coworkers
gen dm_mob = money*dm_other_bystanders
tab1 dm_mm dm_ma dm_mcp dm_mck dm_mob
drop mmale mage40 mcomputer mcoworkers mother_bystanders ///
     dm_male dm_age40 dm_computer dm_coworkers dm_other_bystanders

//regression
global xlist1 male age40 computer coworkers other_bystanders 
global xlist2 rice male age40 computer coworkers other_bystanders ///
              dm_mm dm_ma dm_mcp dm_mck dm_mob      
regress email money i.city i.institution, robust // column 1
regress email money $xlist1 i.city i.institution, robust // column 2
regress email money $xlist2 i.city i.institution, robust // column 3
regress wallet_recovery money i.city i.institution, robust // column 4 
regress wallet_recovery money $xlist1 i.city i.institution, robust // column 5
regress wallet_recovery money $xlist2 i.city i.institution, robust // column 6
regress wallet_totalrecovery money i.city i.institution, robust // column 7
regress wallet_totalrecovery money $xlist1 i.city i.institution, robust // column 8
regress wallet_totalrecovery money $xlist2 i.city i.institution, robust // column 9


********************************************************************************
*****Appendix*****
********************************************************************************		

********************Table S1********************
***** =====================================*****
snapshot restore 1
keep money male age40 computer coworkers other_bystanders hotel bank cultural ///
     public postal security_cam security_guard english understood_situation busy
order money male age40 computer coworkers other_bystanders hotel bank cultural ///
      public postal security_cam security_guard english understood_situation busy
tabstat male-busy, by(money) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist male-busy {
  tabulate `var' money, chi
}

kwallis understood_situation, by(money)
kwallis busy, by(money)

********************Table S2********************
***** =====================================*****
snapshot restore 1
keep record male age40 computer coworkers other_bystanders hotel bank cultural ///
     public postal security_cam security_guard english understood_situation busy
order record male age40 computer coworkers other_bystanders hotel bank cultural ///
      public postal security_cam security_guard english understood_situation busy
tabstat male-busy, by(record) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist male-busy {
  tabulate `var' record, chi
}

kwallis understood_situation, by(record)
kwallis busy, by(record)

********************Table S3********************
***** =====================================*****
//250 sites data of foreign research assistants
snapshot restore 1
keep if record==1 
keep money male age40 computer coworkers other_bystanders security_cam ///
     security_guard english understood_situation busy
order money male age40 computer coworkers other_bystanders security_cam ///
      security_guard english understood_situation busy
tabstat male-busy, by(money) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist male-busy {
  tabulate `var' money, chi
}
kwallis understood_situation, by(money)
kwallis busy, by(money)

//250 sites data of undercover observers 
snapshot restore 1
keep if record==1 
keep money o_male o_age40 o_computer o_coworkers o_other_bystanders ///
     o_security_cam o_security_guard o_english o_understood_situation o_busy 
order money o_male o_age40 o_computer o_coworkers o_other_bystanders ///
      o_security_cam o_security_guard o_english o_understood_situation o_busy
tabstat o_male-o_busy, by(money) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist o_male-o_busy {
  tabulate `var' money, chi
}
kwallis o_understood_situation, by(money)
kwallis o_busy, by(money)

//difference between foreign research assistants and undercover observers
snapshot restore 1
keep if record==1 
keep male age40 computer coworkers other_bystanders security_cam ///
     security_guard english understood_situation busy
gen observer=0  // foreign research assistants
order observer male age40 computer coworkers other_bystanders security_cam ///
      security_guard english understood_situation busy
save "experimenter.dta",replace 

snapshot restore 1
keep if record==1
keep o_male o_age40 o_computer o_coworkers o_other_bystanders o_security_cam ///
     o_security_guard o_english o_understood_situation o_busy
rename o_male male
rename o_age40 age40
rename o_computer computer
rename o_coworkers coworkers
rename o_other_bystanders other_bystanders
rename o_security_cam security_cam
rename o_security_guard security_guard
rename o_english english
rename o_understood_situation understood_situation
rename o_busy busy
gen observer=1  //undercover observer

order observer male age40 computer coworkers other_bystanders security_cam ///
      security_guard english understood_situation busy
append using "experimenter.dta"

foreach var of varlist male-busy {
  tabulate `var' observer, chi
}
kwallis understood_situation, by(observer)
kwallis busy, by(observer)


********************Table S4********************
***** =====================================*****
snapshot restore 1
keep money keymissing cardmissing notemissing wcovermissing moneymissing wavialabel
order money keymissing cardmissing notemissing wcovermissing moneymissing wavialabel
tabstat keymissing-wavialabel, by(money) stat(mean sd) col(stat) format(%9.3f)
foreach var of varlist keymissing-wavialabel {
  tabulate `var' money, col chi2
}

********************Table S5********************
***** =====================================*****
snapshot restore 1

//demean covariates
sum male age40 computer coworkers other_bystanders
egen mmale = mean(male)
gen dm_male = male - mmale

egen mage40 = mean(age40)
gen dm_age40 = age40 - mage40

egen mcomputer = mean(computer)
gen dm_computer = computer - mcomputer

egen mcoworkers = mean(coworkers)
gen dm_coworkers = coworkers - mcoworkers

egen mother_bystanders = mean(other_bystanders)
gen dm_other_bystanders = other_bystanders - mother_bystanders
tab1 dm_male dm_age40 dm_computer dm_coworkers dm_other_bystanders

//interaction between the treatment and demeaned covariates
gen dm_mm = money*dm_male
gen dm_ma = money*dm_age40
gen dm_mcp = money*dm_computer
gen dm_mck = money*dm_coworkers
gen dm_mob = money*dm_other_bystanders
tab1 dm_mm dm_ma dm_mcp dm_mck dm_mob
drop mmale mage40 mcomputer mcoworkers mother_bystanders ///
     dm_male dm_age40 dm_computer dm_coworkers dm_other_bystanders

//regression
global xlist male age40 computer coworkers other_bystanders cis ///
              dm_mm dm_ma dm_mcp dm_mck dm_mob      

regress email money $xlist i.city i.institution, robust // column 1
regress wallet_recovery money $xlist i.city i.institution, robust // column 2
regress wallet_totalrecovery money $xlist i.city i.institution, robust // column 3

	 