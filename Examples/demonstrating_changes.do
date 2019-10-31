*Demonstrating new features
cd "N:\Paramed\Command\Paramed" 

cap log close	
log using "Examples/paramed_changes", smcl replace
use Testing/paramed_example.dta, clear // this is the example data that is downloaded when the paramed package is installed.

*1. Reduced output
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) // 

*2. Full output if no covariates specified
***Note I have ommited a0 a1 options and command still runs***
paramed y_cont, avar(treat) mvar(m_bin)  m(1) yreg(linear) mreg(logistic)  full // full output

*3. Full output when covariates specified
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2)  m(1) yreg(linear) mreg(logistic)  full c(5, 10) // output

*4. Bootstrap output
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) seed(1234) // 
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) seed(1234) interval(percentile) // 
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) seed(1234) interval(normal) // 
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) seed(1234) interval(bc) // 
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) boot reps(10) seed(1234) interval(sdfsdf) // 


mat list e(effects) // note the effects matrix stores the non bootsrapped results


*5 Ommiting m when nointer is specified
paramed y_cont, avar(treat) mvar(m_bin) nointeraction yreg(linear) mreg(logistic)  full // full output
paramed y_cont, avar(treat) mvar(m_bin) m(1) nointeraction yreg(linear) mreg(logistic)  full // full output

*6 Surpressing output
paramed y_cont, avar(treat) mvar(m_bin) cvars(var1 var2)  m(1) yreg(linear) mreg(logistic)  full c(5, 10) nodef // output


log close 

view Examples/paramed_changes.smcl

