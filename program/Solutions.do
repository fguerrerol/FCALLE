 ********************************************************************************
*																			   *
*				Solución problem set			       *
*																			   *
********************************************************************************

*** Created: 			29/01/22
*** Last edited: 		29/01/22
*** Authors: 			Francisco Guerrero
*** Stata 16.1

********************************************************************************

* Configuración básica, configuración del directorio de trabajo 

clear all
set more off
global main    "/home/jesus/Documentos/Test/RA-FrancoCalle"
global output "$main/output"
global input "$main/input"



*Creación del dataset, esto se hace mediante la toma de un módulo y sucesivos merges con los distintos módulos de la encuesta, esto


use $input/enaho01-2017-200 ,clear
count 



recode p208a (0/14 = 1 "Menor de 14") (15/99 = 0 "Mayor de 14"), gen(menores)

egen menores_t = total(menores), by (conglome vivienda hogar)



egen miembros  = count(codperso != ""), by(conglome vivienda hogar)

recode p208a (0/17 = 0 "Menores")(18/99 =1 "Adultos"), gen(adultos)

keep if adultos ==1


recode p208a (0/19 31/99 =0 "No jovenes")(20/30 = 1 "Jovenes"), gen(jovenes)



merge 1:1 conglome vivienda hogar codperso using "$input/enaho01a-2017-300.dta", keep(match) nogen



merge 1:1 conglome vivienda hogar codperso using"$input/enaho01a-2017-400.dta", keep(match) nogen




merge 1:1 conglome vivienda hogar codperso using "$input/enaho01a-2017-500.dta" , keep(match) nogen


merge m:1 conglome vivienda hogar using "$input/enaho01-2017-100", keep(match) nogen



* En este punto se guarda la data de manera precautoria, y para utilizarla se vuelve a cargar

save "$output/Enaho-full-2017.dta", replace 


* Se vuelve a cargar

use $output/Enaho-full-2017, clear

recode estrato (1/5=0 "urbano") (6/8 = 1  "rural") , gen (rural) 



recode p509 (2=0) ,gen(empresario) 

gen desempleado = 1 if ((p501 == 2) & (p503 == 2))

recode desempleado .=0 

egen ingreso_total = sum(p524a1), by(conglome vivienda hogar)

gen l_i_total = log(ingreso_total)

gen ingreso = log(p524a1)

sum desempleado adultos rural miembros l_i_total

gen departamento = substr(ubigeo,1,2)


egen num_jovenes = sum(jovenes), by(departamento)

egen den_jovenes = count(jovenes), by(departamento)

gen prop_jovenes = num_jovenes/den_jovenes



collapse (mean) ingreso desempleado rural  miembros l_i_total jovenes  menores_t ,by(departamento)

destring departamento, replace


save "$output/Reduced-Enaho-2017", replace


import excel "$input/ERM2018_Resultados_Regional",  firstrow  clear

sort Region

encode Region, gen(departamento)


save "$output/elecciones", replace


merge m:1 departamento using "$output/Reduced-Enaho-2017"

rename OrganizaciónPolítica orgpol
encode orgpol, gen(orgpolnum) 
encode TipoOrganizaciónPolítica, gen(tipo_org) 


preserve


collapse (sum) Votos ,by(orgpolnum)
br


*** Mayores partidos políticos *****

* APP 		4	*
* Accion Popular 1	*
* Podemos Peru 	 93	*
* Somos Peru		84*
* Fuerza Popular 	27* 
restore





save "$output/merged", replace

use $output/merged, clear

reg Partipación Electores if orgpolnum ==114, robust

twoway (scatter Participación Electores) (lfit Participación Electores) if orgpolnum==114

outreg2 using $output/reg1.tex, tex



reg Partipación Electores if orgpolnum ==114, robust

twoway (scatter Participación Electores) (lfit Participación Electores) if orgpolnum==114

outreg2 using $output/reg1.tex, tex




reg Partipación Electores if orgpolnum ==114, robust

twoway (scatter Participación Electores) (lfit Participación Electores) if orgpolnum==114

outreg2 using $output/reg1.tex, tex




reg Partipación Electores if orgpolnum ==114, robust

twoway (scatter Participación Electores) (lfit Participación Electores) if orgpolnum==114

outreg2 using $output/reg1.tex, tex




twoway bar I Electores if (orgpolnum == 4 | orgpolnum==1 | orgpolnum ==93 | orgpolnum ==84 | orgpolnum ==27)


egen minshare = min(I) ,by (orgpolnum)


egen maxshare = max(I) ,by (orgpolnum)




graph bar minshare maxshare  if (orgpolnum == 4  | orgpolnum == 1 | orgpolnum== 93 | orgpolnum == 84 | orgpolnum ==27  ), over(orgpolnum)


twoway (scatter Participación Electores ) (lfit Participación Electores) if orgpolnum==93 , title("Evolución del voto de Podemos Peru") 


