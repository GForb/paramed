use "paramed_example.dta", clear

cap prog drop save_results
prog save_results
args scenario filename
    di `scenario'
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

    gen scenario = `scenario'
    if `scenario' ==  1 {
        save  `filename', replace
    }
    else {
        append using  `filename'
        save `filename', replace
    }
    restore
end

tempfile results
paramed y_cont, avar(treat) mvar(m_cont) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(linear) nointer 
save_results 1 filename(`results')


paramed y_cont, avar(treat) mvar(m_cont) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(linear)  
save_results 2 filename(`results')


use  `results', clear
rename A1 estimate
rename A2 standard_error
rename A3 p_value
rename A4 ll
rename A5 ul

