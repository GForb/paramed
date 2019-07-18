cd "N:\Paramed\Command\Paramed\Testing"

use "paramed_example.dta", clear

*Examples 

local eg = 2
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot seed(1234) reps(50)
mat b_eg`eg' = e(b)
mat v_eg`eg' = e(V)			

local eg = 3
paramed y_bin, avar(treat) mvar(m_bin) a0(0) a1(1) m(1) yreg(logistic) mreg(logistic) nointer boot reps(50) seed(1234)
mat b_eg`eg' = e(b)
mat v_eg`eg' = e(V)

local eg = 4
paramed y_poisson, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(poisson) mreg(logistic) nointer boot seed(1234) reps(50)
mat b_eg`eg' = e(b)
mat v_eg`eg' = e(V)


*Testing factorialy all options with bootstrap
set seed 1443536
rename y_cont y_linear
rename y_bin  y_logistic
gen y_loglinear = rbinomial(1, 0.5)


rename m_cont m_linear
gen m_logistic = rbinomial(1, 0.5)

timer clear 2
timer  on 2
*First set of tests
foreach y_type in linear logistic loglinear poisson negbin {
	foreach m_type in linear logistic {
			foreach full in nfl fl {
	
				local boot_code boot seed(1234) reps(10)
				

				local full_code ""
				if "`full'" == "fl" local full_code full
	
				*Test 1: No options
				local test = 1
				di _newline "Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') `boot_code' `full_code'
				mat b`test'_`y_type'_`m_type'_`full' = e(b)
				mat v`test'_`y_type'_`m_type'_`full' = e(V)
				
				if "`full'" == "fl" local full_code full c(10 5)
				
				*Test 2: 
				local test = 2
				
				if "`y_type'" == "loglinear" & "`m_type'" == "linear"  local boot_code boot seed(1234) reps(100) // increasing numbers of boot reps where issues calculating s.e.s encountered
				if  "`y_type'" == "logistic" & "`m_type'" == "linear"  local boot_code boot seed(1234) reps(100) // increasing numbers of boot reps where issues calculating s.e.s encountered
				
				
				di _newline "Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  `boot_code' `full_code'
				mat b`test'_`y_type'_`m_type'_`full' = e(b)
				mat v`test'_`y_type'_`m_type'_`full' = e(V)

				*Test 3: 
				local test = 3
				di _newline "Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  nointer `boot_code' `full_code'
				mat b`test'_`y_type'_`m_type'_`full' = e(b)
				mat v`test'_`y_type'_`m_type'_`full' = e(V)
			}
		}
	}

timer  off 2
timer  list 2

timer clear 3
timer on 3
*Case control
local y_type  logistic 
	foreach m_type in linear logistic {
			foreach full in nfl fl {
	

				local boot_code boot seed(1234) reps(10)
				if "`y_type'" == "logistic" & "`m_type'" == "linear"  local boot_code boot seed(1234) reps(100) // increasing numbers of boot reps where issues calculating s.e.s encountered

				local full_code ""
				if "`full'" == "fl" local full_code full
	
				*Test 1: No options
				local test = 1
				di _newline "CC Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') `boot_code' `full_code'
				mat c_b`test'_`y_type'_`m_type'_`full' = e(b)
				mat c_v`test'_`y_type'_`m_type'_`full' = e(V)
				
				if "`full'" == "fl" local full_code full c(10 5)
				
				*Test 2: 
				local test = 2
				di _newline "CC Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  `boot_code' `full_code'
				mat c_b`test'_`y_type'_`m_type'_`full' = e(b)
				mat c_v`test'_`y_type'_`m_type'_`full' = e(V)

				*Test 3: 
				local test = 3
				di _newline "CC Test: `test' `y_type' `m_type'" _newline
				paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  nointer `boot_code' `full_code'
				mat c_b`test'_`y_type'_`m_type'_`full' = e(b)
				mat c_v`test'_`y_type'_`m_type'_`full' = e(V)
			}
		}
	
timer off 3
timer list 3

timer off 1
timer list 1
	
*Saving matricies as datasets
clear
forvalues eg =  1 (1) 5 {
	svmat b_eg`eg'
	svmat v_eg`eg'
}

foreach y_type in linear logistic loglinear poisson negbin {
	foreach m_type in linear logistic {
			foreach full in nfl fl {
				forvalues test = 1 (1) 3 {
					svmat  b`test'_`y_type'_`m_type'_`full'
					svmat  v`test'_`y_type'_`m_type'_`full'
				}				
		}
	}
}


local y_type  logistic 
	foreach m_type in linear logistic {
			foreach full in nfl fl {
			forvalues test = 1 (1) 3 {
				svmat c_b`test'_`y_type'_`m_type'_`full'
				svmat c_v`test'_`y_type'_`m_type'_`full'
				}
			}
	}


cf _all using "test_answers_boot 16 Jul 2019.dta"	
