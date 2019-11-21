*Bug 01 test cases
*Relates to issue 01 on paramed github.


use "Testing/test_answers 16 Jul 2019", clear

append using "Testing/test_answers_boot 16 Jul 2019", gen(source)

label define source 0 "boot" 1 "no_boot"
label values source source

drop b* c_b*