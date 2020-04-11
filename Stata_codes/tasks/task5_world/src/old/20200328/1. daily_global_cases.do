* First Version: March 24, 2020
* This Version: March 28, 2020
* Author: Glenn Magerman

/* Latest updates: 
- automate choice of top_world (March 28, 2020)
- update color pallette (March 27, 2020)
- automate legend for auto-selected countries (March 27, 2020)
- try svg and html interactive output (March 27, 2020)
*/

*-----------------------------------
* 0. Total number of cases worldwide
*-----------------------------------
use "$task1/output/covid_cases_bycountry", clear
qui su date
	local last_date = r(max)
	keep if date == `last_date'
	distinct country
	global ncountries = r(ndistinct)
	egen grand_total_cases = total(cum_cases)
	global ncases = grand_total_cases
	egen grand_total_deaths = total(cum_deaths)
	global ndeaths = grand_total_deaths
	
*----------------------------------
* 1. Total cases by country, top 10
*----------------------------------
// select countries
use "$task1/output/covid_cases_bycountry", clear
	qui su date
	local last_date = r(max)
	keep if date == `last_date'
	gsort -cum_cases
	gen rank = _n	

// local with names of analyzed countries for graphs
	keep if rank <= $top_world
	sort country
	levelsof country, local(countrylist)
	local nvar = r(N)
	forvalues i = 1/`nvar' {
		local l`i' = "lab(`i' `=country[`i']')"
	}
	forvalues i = 1/`nvar' {
		local legend `legend' `l`i''
	}
	di "`legend'"

// globals for top 3 countries: country name and #cum_cases
	sort rank
	forvalues i = 1/3 {
		global n`i'_cumcases_country = "country[`i']"
		global n`i'_cumcases = cum_cases[`i']
	}
	
*-----------------------------
* 2. Cumulative cases, by date
*-----------------------------
use "$task1/output/covid_cases_bycountry", clear
	foreach country in `countrylist' {
		local line `line' (tsline cum_cases ///
		if country == "`country'", recast(connected) lwidth(medthick))  ||
	}
	twoway `line', ///
	legend(on size(small) `legend') xoverhangs ///
	tlabel(, format(%tdmd)) ysize(7) xsize(7) note("$ref_source" "$ref_data") ///
	title("Cumulative cases", size(medium)) ytitle("Number of cases") 
	macro drop _line
	graph export "./output/cumcases_byday_global_top${top_world}.svg", replace 
	
*---------------------------------	
* 3. Cumul cases, since 100th case	
*---------------------------------
use "$task1/output/covid_cases_bycountry", clear
//sync events
	drop if cum_cases < 100
	bys country: gen event_time = _n
	xtset cty event_time

// graph
	foreach country in `countrylist' {
		local line `line' (tsline cum_cases ///
		if country == "`country'", recast(connected) lwidth(medthick))  ||
	}
	twoway `line', ///
	legend(on size(small) `legend') xoverhangs ///
	ysize(7) xsize(7) note("$ref_source" "$ref_data") ///
	title("Cumulative cases", size(medium)) ytitle("Number of cases") ///
	xtitle("Days since 100th case") 
	macro drop _line
	graph export "./output/cumcases_post100_global_top${top_world}.svg", replace 

*----------------------------------------------	
* 4. Cumul cases, since 100th case, per million	
*----------------------------------------------
// load data
use "$task1/output/covid_cases_bycountry", clear
	merge m:1 country using "$task1/output/world_population_2020", ///
	nogen keep(match) keepusing(population)

// variables per million inhabitants	
	gen pop_perMln = population/1000000
	gen double cases_perMln = cases/pop_perMln
	
// cumulative cases	
	bys country: gen double cum_cases_perMln = sum(cases_perMln)
	
//sync events
	drop if cum_cases_perMln < 100
	bys country: gen event_time = _n
	xtset cty event_time

// graph
	foreach country in `countrylist' {
		local line `line' (tsline cum_cases_perMln ///
		if country == "`country'", recast(connected) lwidth(medthick))  ||
	}
	twoway `line', ///
	legend(on size(small) `legend') xoverhangs ///
	ysize(7) xsize(7) note("$ref_source" "$ref_data") ///
	title("Cumulative cases, per million inhabitants", size(medium)) ///
	ytitle("Number of cases, per million inhabitants") ///
	xtitle("Days since 100th case per million") 
	macro drop _line
	graph export "./output/cumcases_perMln_post100_global_top${top_world}.svg", replace 
	
	
