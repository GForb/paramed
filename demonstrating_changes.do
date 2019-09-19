*Demonstrating new features
cap log close	
log using paramed_changes, smcl replace
use paramed_example.dta, clear // this is the example data that is downloaded when the paramed package is installed.

*1. Reduced output
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) // 

*2. Full output if no covariates specified
***Note I have ommited a0 a1 options and command still runs***
paramed2 y_cont, avar(treat) mvar(m_bin)  m(1) yreg(linear) mreg(logistic)  full // full output

*3. Full output when covariates specified
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2)  m(1) yreg(linear) mreg(logistic)  full c(5, 10) // output

*4. Bootstrap output
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) // 

mat list e(effects) // note the effects matrix stores the non bootsrapped results

log close 

view paramed_changes.smcl