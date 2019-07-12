*!TITLE: PARAMED - causal mediation analysis using parametric regression models	
*!AUTHORS: Hanhua Liu and Richard Emsley, Centre for Biostatistics, The University of Manchester
*!
*!	verson 1.6 GF/RAE 13 June 2019
*!	Updated output text with more details given on causal effects reported
*!
*!	verson 1.5 HL/RAE 24 April 2013
*!		bug fix - stata's standard calculation of p and confidence interval based on e(b) and e(V)
*!				  (e.g. at 95%, [b-1.96*se, b+1.96*se]) does not work for non-linear cases
*!				  (e.g. loglinear at 95%, [exp(log(b)-1.96*se), exp(log(b)+1.96*se)]), so revert
*!				  back to manual calculation as already done in paramed.mata
*!		affected files - paramed.ado, paramedbs.ado; other files only updated with new version info
*!
*!	version 1.4 HL/RAE 14 March 2013
*!		replay feature - after running paramed, issuing just paramed to reprint/replay the results;
*!		affected files - paramed.ado, paramed.sthlp; other files only updated with new version info
*!
*!	version 1.3 HL/RAE 17 February 2013
*!		return values - instead of returning e(effects), now returns standard e(b) and e(V),
*!						and display the results in standard Stata format;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!
*!	version 1.2 HL/RAE 11 February 2013
*!		syntax change - interaction is now default behaviour, 'nointer' is required syntax for no interaction;
*!		results - now use indicative name for the interaction variable rather than _000001;
*!		bootstrap - changed default number of repetitions from 200 to 1000;
*!		affected files - paramed.ado, paramedbs.ado, paramed.sthlp
*!	
*!	version 1.1 HL/RAE  15 January 2013
*!		updated to save and install files to Stata's PLUS folder
*!
*!	version 1.0 HL/RAE  1 October 2012
*!		final version for submitting to SSC
*!	
*!	version 0.3d HL/RAE 25 October 2011
*!		syntax change - removed nc, introduced minimal abbreviation, 
*!						simplified input for interaction/casecontrol (no need ture/false), output
*!		return values - returns individual effects to allow bootstrap
*!		bootstrap - changed original program to paramedbs, this program is a wrapper which can handle bootstrap option
*!		
*!	version 0.3c HL/RAE 22 October 2011
*!		changed program name - Stata Journal recently published a command mediation, program name changes to paramed
*!		include s_e (standard error) in all outputs
*!	
*!	version 0.3b HL/RAE 24 September 2011
*!	
*!	version 0.3a HL/RAE 17 September 2011 - mediation.ado

cap prog drop paramed2
program define paramed2, eclass
	version 10.0	

	//implementing stata replay feature, i.e. after running paramed, issuing just paramed should reprint the results
	if replay() {
		if ("`e(cmd)'" != "paramed") error 301
		
	//	syntax [, Level(cilevel) ]
	//	ereturn display, level(`level')
	
		//fake stata replay feature by simply display the resulting effects matrix again
	//	matrix list e(effects), noheader
		matlist e(effects), noheader underscore
		exit 0
	}

	syntax varname(numeric), avar(varname numeric) mvar(varname numeric)	///
			[cvars(varlist numeric)] a0(real) a1(real) m(real) ///
			yreg(string) mreg(string) [NOINTERaction	///
			CASEcontrol FULLoutput c(numlist)] ///
			[BOOTstrap reps(integer 1000) level(cilevel) seed(passthru) note(integer 1)] 
	

	capture confirm file "`c(sysdir_plus)'paramed.mo"
	if _rc!=0 {
		display as error "Compiling paramed.mata into paramed.mo ..."
		display as error "This only happens the first time you run paramed, which may take a while."
		quietly do "`c(sysdir_plus)'p/paramed.mata"
	}
	
	
	paramedbs `varlist', avar(`avar') mvar(`mvar') cvars(`cvars')	///
				a0(`a0') a1(`a1') m(`m') yreg(`yreg') mreg(`mreg')	///
				`nointeraction' `casecontrol' `fulloutput' c(`c')

	matrix effects = e(effects)
	local nrow = rowsof(effects)
	
	

	

	//fully expanded names to show as keys to the abbreviations
	local longnames `""controlled direct effect" "controlled direct effect" "natural direct effect" "natural indirect effect" "pure natural direct effect" "pure natural indirect effect" "total natural direct effect" "total natural indirect effect" "conditional controlled direct effect" "conditional pure natural direct effect" "conditional pure natural indirect effect" "conditional total natural direct effect" "conditional total natural indirect effect" "marginal conditional direct effect" "marginal pure natural direct effect" "marginal pure natural indirect effect" "marginal total natural direct effect" "marginal total natural indirect effect" "marginal total effect" "conditional total effect" "total effect" "proportion mediated""'
	//all names used in meta code
	local allnames `""cde=nde" "cde" "nde" "nie" "pnde" "pnie" "tnde" "tnie" "conditional cde" "conditional pnde" "conditional pnie" "conditional tnde" "conditional tnie" "marginal cde" "marginal pnde" "marginal pnie" "marginal tnde" "marginal tnie" "marginal total effect" "conditional total effect" "total effect" "proportion mediated""'
//	local shortnames `"cde cde nde nie pnde pnie tnde tnie c_cde c_pnde c_pnie c_tnde c_tnie m_cde m_pnde m_pnie m_tnde m_tnie mte cte te pm"'
	local shortnames `"cde cde nde nie pnde pnie tnde tnie ccde cpnde cpnie ctnde ctnie mcde mpnde mpnie mtnde mtnie mte cte te pm"'
	local form_1  "E{Y(A=a*, M=m)}- E{Y(A=a, M=m)}" 
	local form_2 "E{Y(A=a*, M=m)}- E{Y(A=a, M=m)}" // nde = cde and cde
	local form_3 "E{Y(A=a*, M(A=a))}- E{Y(A=a, M(A=a))}" // nde
	local form_4 "E{Y(A=a, M(A=a*))}- E{Y(A=a, M(A=a))}" // nie
	local form_5 "E{Y(A=a*, M(A=a))}- E{Y(A=a, M(A=a))}"  // pnde (to be updated)
	local form_6 "E{Y(A=a, M(A=a*))}- E{Y(A=a, M(A=a))}"  // pnie (to be updated)
	local form_7 "E{Y(A=a*, M(A=a*)}- E{Y(A=a, M(A=a*))}" // tnde (to be updated)
	local form_8 "E{Y(A=a*, M(A=a*)}- E{Y(A=a*, M(A=a))}" // tnie
	local form_9 "E{conditional cde}" // conditional cde
	local form_10 "E{conditional pde}" // conditional pnde
	local form_11 "E{conditional pnie}" // 
	local form_12 "E{conditional tnde}" // 
	local form_13 "E{conditional tnie}" // conditional tnie
	local form_14  "E{to be updated}" // marginal cde
	local form_15  "E{to be updated}" // marginal pnde
	local form_16  "E{to be updated}" // marginal pnie
	local form_17 "E{to be updated}" // marginal tnde
	local form_18  "E{to be updated}" // marginal tnie
	local form_19  "E{to be updated}" // marginal te
	local form_20  "E{to be updated}" // conditional total effect
	local form_21  "E{Y(A=a*)}- E{Y(A=a)}" // total effect
	local form_22 "Eto be updated" // proportion mediated
					
					
					
					
					
					
					
					
					
					
	tempname tempmat
	forvalues i=1(1)`nrow' {
		matrix define `tempmat' = effects[`i',1..1]
		local rown_`i' : rownames `tempmat'
		//to find out the position of the full name in `allnames' 
		//and give it a short name in the corresponding position of `shortnames'
	//	local index : list posof "`rown_`i''" in allnames
		local index : list posof "`rown_`i''" in shortnames
		local bs_`i' : word `index' of `shortnames'
		local keys_`i' : word `index' of `longnames'
		if (`i'>1) {
			local keys  `keys'  as result `"    `bs_`i'': "' as text `"`keys_`i''"' _newline 
		}
		else {
			local keys as text `"Note:"' _newline as result `"    `bs_`i'': "' as text `"`keys_`i''"' _newline		
		}
		
		*Keys 2
		local keys2  `keys2'  %45s as text `"`keys_`i'' ({result:`bs_`i''})"'  %-30s `" = `form_`i''"'  _newline 

		*Keys 3
		local keys3  `keys3' as text  %45s `"{result:`bs_`i''}: `keys_`i''"' %-30s `" = `form_`i''"' _newline 	
		
		*Keys 4
		local keys4  `keys4'  as text %20s `"{result:`bs_`i''} "' `"{it:`keys_`i''}"' _newline %15s "= " %-30s `"`form_`i''"' _newline 
		local keys5  `keys5'  as text %5s "" `"{it:`keys_`i''}"' _newline %25s `"{result:`bs_`i''} = "' %-30s `"`form_`i''"' _newline 

	}

	local note_text "Note for outcome Y, treatment (exposure) A, and mediator M:"

	
	
	
	*Running bootstrap
	if "`bootstrap'" != "" {
		local bs ""
		forvalues i=1(1)`nrow' {
			local bs `"`bs' `bs_`i''=e(`bs_`i'')"'
		}
		quietly bootstrap `bs', reps(`reps') level(`level') `seed':	///
				paramedbs `varlist', avar(`avar') mvar(`mvar') cvars(`cvars')	///
					a0(`a0') a1(`a1') m(`m') yreg(`yreg') mreg(`mreg') ///
					`nointeraction' `casecontrol' `fulloutput' c(`c')
		
		display		

		estat bootstrap, noheader	//only report bias-corrected confidence interval
	}
	
	
	display 
	*display "{p 5}"
	if `note' ==1 di `keys'
	if `note' > 1 {
		di   `"`note_text'"'
		di `keys`note''
	}
	*display "{p_end}"

	


	tempname b V
	matrix `b' = e(b)
	matrix `V' = e(V)
	ereturn post `b' `V', esample()	//clear any previous ereturn list, returns e(b) and e(V)

	ereturn matrix effects = effects	
	
	ereturn local cmd `"paramed"'
	ereturn local cmdline `"paramed `0'"'
end paramed
