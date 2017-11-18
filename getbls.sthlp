{smcl}
{* *! version 1.0.2  18nov2017}{...}
{viewerjumpto "Syntax" "test##syntax"}{...}
{viewerjumpto "Menu" "test##menu"}{...}
{viewerjumpto "Description" "test##description"}{...}
{viewerjumpto "Options" "test##options"}{...}
{viewerjumpto "Examples" "test##examples"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{bf: getbls} {hline 2}}Imports Bureau of Labor Statistics tables to memory.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:getbls}
{series_list}
[{cmd:,} {it:options}]


{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth key(string)}}BLS key. Required to access API.{p_end}
{synopt:{opth years(#)}}Year or range of years for which to return data. Default is current year.{p_end}

{syntab:Options}
{synopt:{opt states(string)}}State FIPS or list of state FIPS. Pass asterisk (*) for all states.{p_end}
{synopt:{opt saveas(string)}}Filename to save imported data.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt getbls} accesses Bureau of Labor Statistics tables and import them into memory. The API can return up to 10 years of data.

{pstd}
You can pass as many table IDs as necessary. Though, keep in mind that if you'd like state tables,
you should use the % symbol where the state FIPS would go within the ID. E.g., SMU01000000500000011
has weekly hours worked in Alabama while SMU02000000500000011 has weekly hours worked in Alaska.
To get these data,simply pass SMU%000000500000011 and pass their FIPS codes (01 and 02, respectively)
to the {bf: states} option.

Below are some common national and state tables.

{marker nattab}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:National Table ID}}Concept{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt CES0000000001}} Total employees, thousands {p_end}
{synopt:{space 4}{opt LNS14000000}} Unemployment rate {p_end}
{synopt:{space 4}{opt CEU0500000002}} Average weekly hours, all {p_end}
{synopt:{space 4}{opt CEU0500000003}} Average hourly earnings, all {p_end}
{synopt:{space 4}{opt CEU0500000011}} Average weekly wages, all {p_end}
{synopt:{space 4}{opt CUSR0000SA0}} CPI, all urban customers {p_end}

{marker stattab}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:State Table ID}}Concept{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt SMS%000000000000001}} Total non-farm employment, thousands {p_end}
{synopt:{space 4}{opt LASST%0000000000003}} Unemployment rate  {p_end}
{synopt:{space 4}{opt SMU%000000500000002}} Average weekly hours, all {p_end}
{synopt:{space 4}{opt SMU%000000500000003}} Average hourly earnings, all {p_end}
{synopt:{space 4}{opt SMU%000000500000011}} Average weekly earnings, all {p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth key(string)}  To access BLS' API, BLS requires that you download a key. You can download the key {browse "here":https://data.bls.gov/registrationEngine/}. 
You can avoid passing this every time if you add {bf: global blskey YOURKEY} to your profile.do.


{phang}
{opth years(year_list)} You can pass a year or list of years, separated by a "-" or "/". Default is current year. BLS' API only allows you to select a range, 
so {cmd: getbls} will take the maximum and minimum from this range and pass those to BLS.

{dlgtab:Options}

{phang}
{opt states} You can pass a state FIPS code or series of state FIPS codes. You can get all states by passing an asterisk (*). 
Remember: when passing series IDs for state tables, pass a "%" where the state FIPS would go (e.g., SMU%000000500000011)

{phang}
{opt saveas(string)} Saves imported dataset to memory with filename passed to this option.


{marker examples}{...}
{title:Examples}

    {pmore}. {bf:getbls} LNS14000000{p_end}
    {pmore}. {bf:getbls} LNS14000000, years(2015 - 2017){p_end}
    {pmore}. {bf:getbls} SMU%000000500000011, states(01 02) years(2014/2017){p_end}
    {pmore}. {bf:getbls} LNS14000000 SMU%000000500000011, years(2010 2017) states(01 02 56) clear {p_end}

{marker authors}{...}
{title:Authors}

{pstd} Raheem Chaudhry, {browse "mailto:rchaudhry@cbpp.org":rchaudhry@cbpp.org}{p_end}
{pstd} Center on Budget and Policy Priorities {p_end}