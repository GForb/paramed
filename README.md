# Paramed

### Installation
To install the latest version of `paramed` from github enter the below command. This version is currently not available on SSC:

`net install paramed, from("https://raw.githubusercontent.com/GForb/paramed/master")`

### `paramed` performs causal mediation analysis using parametric regression models.  



Two models are estimated: a model for the mediator conditional on treatment (exposure) and covariates (if specified), and a model for the outcome conditional on treatment (exposure), the mediator and covariates (if specified).  It extends statistical mediation analysis (widely known as Baron and Kenny procedure) to allow for the presence of treatment (exposure)-mediator interactions in the outcome regression model using counterfactual definitions of direct and indirect effects. 

`paramed` allows continuous, binary or count outcomes, and continuous or binary mediators, and requires the user to specify an appropriate form for the regression models. `paramed` provides estimates of the controlled direct effect, the natural direct effect, the natural indirect effect and the total effect with standard errors and confidence intervals derived using the delta method by default, with a bootstrap option also available.
