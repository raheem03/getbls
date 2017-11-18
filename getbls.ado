*! v.1.0.2 18nov2017, Raheem Chaudhry

cap program drop getbls
program define getbls
version 14.0 

    syntax anything(id="Series ID(s)" name=serieslist)[, key(string) years(string) STates(string) SAVEas(string) clear]

    * Check for dependencies
    foreach program in libjson.mlib insheetjson.ado {
        capture which `program'
        if _rc    {
            display _newline(1)
            display as result "You don't have `program' installed. Enter -yes- to install or any other key to abort." _request(_y)
            local program = substr("`program'", 1, strpos("`program'", ".")-1)
            if "`y'"=="yes" ssc install "`program'"
            else {
                display as error "`program' not installed. To use getbls, first install `program' by typing -ssc install `program'-."
                qui exit 601
            }
        }
    }

    * Defaults
    local states1 "01 02 04 05 06 08 09 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29"
    local states2 "30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56"
    local stateslist "`states1' `states2'"
    if "`states'" == "*" local states "`stateslist'"
    
    local curryear = year(td(`c(current_date)'))
    if "`years'" == "" local years `curryear'

    * Parse years
    local switch 0
    
    foreach split in "-" "/" " - " " / " {
        local years = subinstr("`years'", "`split'", " - ", .)
    }
    
    foreach i in `years' {
        if `switch' == 1 {
            local start = `beforesplit' + 1
            local stop = `i' - 1
            if `stop' < `start' & `stop' - `start' != -1 {
                dis as error "Make sure to pass larger years first if separating with delimiter (/ or -)"
                exit
            }
            
            forvalues j = `start'/`stop' {
                local allyears = "`allyears' `j'"
            }
            
            local switch 0
        }

        if "`i'" == "-" {
            local switch = 1
        }
        else {
            local allyears = "`allyears' `i'"
            local beforesplit "`i'"
        }
    }
    
    local allyears = strtrim("`allyears'")
    local yearcount: word count `allyears'
    local allyears = subinstr("`allyears'", " ", ", ", .)
    
    if `yearcount' > 1 {
        local firstyr = min(`allyears')
        local secondyr = max(`allyears')
    }
    else {
        local firstyr = `allyears'
        local secondyr = `allyears'
    }
        
    * Handle key
    if "`key'" != "" dis "You can avoid passing a key each time by creating a global (preferably in your profile.do) called blskey that contains your key."
    if "`key'" == "" local key "$blskey"
    if "`key'" == "" {
        dis as err "Must pass BLS key. To acquire, register here: https://data.bls.gov/registrationEngine/. To avoid passing each time, set global blskey to your key in your profile.do. Type -help getBLS- for details."
    }

    * Error handling
    if (`c(changed)' | `c(N)' | `c(k)') & "`clear'" == "" {
        dis as err "no; data in memory would be lost"
        exit 4
    }
    
    preserve
    if "`clear'" != "" {
        clear
    }
    
    foreach year in `firstyr' `secondyr' {
        if `year' < `curryear' - 10 {
            dis as err "BLS API only provides data for last 10 years."
            exit
        }
    }
    
    foreach year in `firstyr' `secondyr' {
        if `year' > `curryear' {
            dis as err "Data for `year' have not been released yet."
            exit
        }
    }

    * API Call
    local i = 0
    tempfile temp
    foreach series in `serieslist' {
        local table "`series'"
        if strpos("`series'", "%") {
            local geos "`states'"
        }
        else {
            local geos "us"
        }
        
        foreach geo in `geos' {
            local series = subinstr("`series'", "%", "`geo'", .)
            local ++i
            qui clear
            local APICall "https://api.bls.gov/publicAPI/v2/timeseries/data/`series'?registrationkey=`key'&catalog=true&startyear=`firstyr'&endyear=`secondyr'"
            tempfile jsontree
            qui copy "`APICall'" "`jsontree'"
            qui import delimited "`jsontree'", delimiter("\n", asstring) varnames(nonames) clear 

            qui local find1 `""Results""'
            qui local find2 `"series""'
            
            qui replace v1 = subinstr(v1, "[{}]", "[[]]", .)
            qui replace v1 = subinstr(v1, `"`find2':"', "", .)
            qui replace v1 = subinstr(v1, `"`find1':{"', `"`find1':{"`find2':"', .)
            qui drop if v1 == ""
            qui outfile using "`jsontree'", noquote replace wide
            
            qui clear
            foreach var in year monthID month value {
                qui gen str60 `var' = ""
            }

            qui insheetjson year monthID month value using "`jsontree'", table("Results" "series" "1" "data") columns("year" "period" "periodName" "value")
            qui gen table = "`table'"
            qui destring *, replace
            qui gen geography = "`geo'"
            qui compress
            cap append using `temp'
            qui save `temp', replace
            
        }
    }

if "`saveas'" != "" saveold `saveas', replace

restore, not
end
