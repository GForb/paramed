*Demonstrating new features

use paramed_example.dta, clear

paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) // output
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic) nointer // full output
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic)  full c(5, 10) // output



paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic)  boot reps(10) level(90)


paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(regress) mreg(logistic) c(10 6) 



di as result "hello"
di "{result: hello}"



paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0) a1(1) m(1) yreg(linear) mreg(logistic)  
paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) m(1) yreg(linear) mreg(logistic) 
paramed2 y_cont, avar(treat) mvar(m_bin)  m(1) yreg(linear) mreg(logistic) 
paramed2 y_cont, avar(treat) mvar(m_bin)  m(1) yreg(linear) mreg(logistic) full

paramed2 y_cont, avar(treat) mvar(m_bin) cvars(var1 var2) a0(0)  m(1) yreg(linear) mreg(logistic) 
