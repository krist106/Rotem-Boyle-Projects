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

tab2xl decoupling country [iweight=perweight] using testfile, col(1) row(1)
