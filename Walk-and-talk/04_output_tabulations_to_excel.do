*******************************************************************************
***                                                                         ***
***                         Women’s Rights –                                ***
***        Not Only a Policy Instrument but a Lived Reality?				***
***																			***
***																			***
*******************************************************************************
* 		Liz Boyle and Nir Rotem
* 04.13.21

* to create excel spreadsheet from tabulation with weights. Can't do percentages AND weights. Have to calculate those yourself once the numbers are in the spreadsheet. After the comma, the options are telling Stata where to start writing in the Excel file. 

cd "C:\Users\Nir\Documents\Projects\2020\Grounded decoupling\IPUMS DHS data"

clear
use 02_women.dta if ever_married==1

tab2xl decoupling country [iweight=perweight] using testfile, col(1) row(1)

xtable decoupling waves2 [iweight=perweight], column row file(percent.xlsx) sheet(2waves)
xtable decoupling waves3 [iweight=perweight], column row file(percent.xlsx) sheet(3waves)