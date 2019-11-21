cd "N:\Paramed\Command\Paramed\Testing"

cap prog drop save_results
prog save_results
args scenario filename cmd
    local cmdline = e(cmdline)
    if _rc == 0 {
        mat define A = e(effects)
        preserve    
        clear
        svmat A
        local names : rownames A
        local n_words = rowsof(A)
        gen estimand = ""
        forvalues i = 1 (1) `n_words' {
            replace estimand = word("`names'", `i') if _n == `i'
        }
    }
    else {
        preserve    
        clear
        set obs 1
        gen A1 = .
        gen A2 = .
        gen A3 = .
        gen A4 = .
        gen A5 = .
        gen estimand = "error"
        
    
    }
    gen scenario = `scenario'
    gen command = "`cmdline'"

    if `scenario' ==  1 {
        save  `filename', replace
    }
    else {
        append using  `filename'
        save `filename', replace
    }
    restore
end

foreach b in no_boot  { // boot
    use "paramed_example.dta", clear

    tempfile test_results_`b'

    timer clear 1
    timer on 1

    local test_no = 1
    local eg = 1
    capture noisily paramed y_cont, avar(treat) mvar(m_cont) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(linear) nointer  `boot'
    save_results `test_no++' `test_results_`b''

    local eg = 5 
    capture noisily paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) c(10 6) full `boot'
    save_results `test_no++' `test_results_`b''



    *Testing factorialy all options
    set seed 31321
    rename y_cont y_linear
    rename y_bin  y_logistic
    gen y_loglinear = rbinomial(1, 0.5)


    rename m_cont m_linear
    gen m_logistic = rbinomial(1, 0.5)

    timer clear 2
    timer  on 2

    *First set of tests

        if "`b'" == "no_boot" local boot 
        if  "`b'" == "boot" local boot "boot reps(50)"

        foreach y_type in linear logistic loglinear poisson negbin {
            foreach m_type in linear logistic {
                    foreach full in nfl fl {
            


                        local full_code ""
                        if "`full'" == "fl" local full_code full
            
                        *Test 1: No options
                        di _newline "Test `test_no': No options, `y_type' `m_type'" _newline
                        capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type')  `full_code' `boot'
                        save_results `test_no++' `test_results_`b''

                        
                        if "`full'" == "fl" local full_code full c(10 5)
                        
                        *Test 2:				
                        di _newline "Test `test_no': cvars,  `y_type' `m_type'" _newline
                        capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)   `full_code' `boot'
                        save_results `test_no++' `test_results_`b''


                        *Test 3: 
                        di _newline "Test `test_no': cvars, no interaction  `test' `y_type' `m_type'" _newline
                        capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  nointer  `full_code' `boot'
                        save_results `test_no++' `test_results_`b''

                    
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

                    local full_code ""
                    if "`full'" == "fl" local full_code full

                    *Test 1: No options
                    local test = 1
                    di _newline "CC Test: `test' `y_type' `m_type'" _newline
                    capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type')  `full_code' `boot'
                    save_results `test_no++' `test_results_`b''

                    
                    *Test 2: 
                    local test = 2
                    if "`full'" == "fl" local full_code full c(10 5)

                    di _newline "CC Test: `test' `y_type' `m_type'" _newline
                    capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)   `full_code' `boot'
                    save_results `test_no++' `test_results_`b''


                    *Test 3: 
                    local test = 3
                    di _newline "CC Test: `test' `y_type' `m_type'" _newline
                    capture noisily paramed y_`y_type', avar(treat) mvar(m_`m_type') a0(0) a1(1) m(1) yreg(`y_type') mreg(`m_type') cvars(var1 var2)  nointer  `full_code' `boot'
                    save_results `test_no++' `test_results_`b''

                }
        }



    timer off 3
    timer list 3

    timer off 1
    timer list 1
    if "`b'" == "no_boot" {
        use `test_results_`b'', clear
        rename A1 estimate
        rename A2 standard_error
        rename A3 p_value
        rename A4 ll
        rename A5 ul

        save "test_answers `c(current_date)'", replace
   }
   else {
        use `test_results_`b'', clear
        rename A1 boot_estimate
        rename A2 boot_bias
        rename A3 boot_se
        rename A4 boot_ll
        rename A5 boot_ul
        
        save "test_answers_boot `c(current_date)'", replace
   }

}