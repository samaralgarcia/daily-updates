* This version: March 28, 2020
* First version: March 24, 2020
* Author: Glenn Magerman

/* latest updates
- auto call data from website (March 28, 2020)
- update code to reflect changed structure excel files (March 28, 2020)
*/

*-------------------------
* 1. Daily cases from ECDC
*-------------------------
// macro for today's datee
local today: display %td_CCYY-NN-DD date(c(current_date), "DMY")
local today = subinstr("`today'", " ", "", .)
di "`today'"

// download today's ECDC data
*https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-2020-03-28.xlsx
import excel "https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-`today'.xlsx", clear firstrow case(lower) 
	ren (daterep countriesandterritories geoid countryterritory) ///
	(date country iso2 iso3)
	drop day month year popdata2018
	
// format dates for graphs
	format date %td
	
// destring dates (not needed in latest version)
	cap {
		gen date2 = date(date, "DMY")
		format date2 %td
		drop date
		ren date2 date
	}
	
// harmonize country names	
	replace country = "UK" if country == "United_Kingdom"
	replace country = "USA" if country == "United_States_of_America"
	replace country = subinstr(country, "_", " ", .)
	replace country = "SouthKorea" if country == "South Korea"
	
// panel dimension
	encode country, gen(cty)
	xtset cty date

// calculate cumulative cases	
	bys country: gen cum_cases = sum(cases)
	bys country: gen cum_deaths = sum(deaths)
	
// gen logs	
	foreach x in cases deaths cum_cases cum_deaths {
		gen ln`x' = ln(`x')
	}		
	
// gen EU labels
	gen EU28 = 0
	replace EU28 = 1 if country == "Austria" | country == "Belgium" | ///
	country == "Bulgaria" | country == "Croatia" | country == "Cyprus" | ///
	country == "Czech Republic" | country == "Denmark" | country == "Estonia" | ///
	country == "Finland" | country == "France" | country == "Germany" | ///
	country == "Greece" | country == "Hungary" | country == "Ireland" | ///
	country == "Italy" | country == "Latvia" | country == "Lithuania" | ///
	country == "Luxembourg" | country == "Malta" | country == "Netherlands" | ///
	country == "Poland" | country == "Portugal" | country == "Romania" | ///
	country == "Slovakia" | country == "Slovenia" | country == "Spain" | ///
	country == "Sweden" | country == "UK"
	
// label vars for graphs	
	label var date Date
	label var cases Cases
	label var deaths Deaths
	label var country Country
	label var cty Country
	label var iso2 Country
	label var iso3 Country
	label var lncases "Cases"
	label var lndeaths "Deaths"
	label var cum_cases "Total cases"
	label var cum_deaths "Total deaths"
	label var lncum_cases "Total cases"
	label var lncum_deaths "Total deaths"
	label var EU28 "EU28 member"
save "./output/covid_cases_bycountry", replace	
