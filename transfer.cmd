	@echo off
	rem versie 12/10/2020
	rem parameters: {source} {dest} {dbname} {schema} {table} (newschema)
	if "%5"=="" goto paramfout
	if "%BCPTEMP%"=="" goto paramfout
	if "%BCPLOG%"=="" goto paramfout
:
	echo %DATE% %TIME% Transfer from %1.%3.%4.%5 >> %BCPLOG%\%0.log
	if "%6"=="" echo %DATE% %TIME% Transfer to %2.%3.%4.%5 >> %BCPLOG%\%0.log
	if not "%6"=="" echo %DATE% %TIME% Transfer to %2.%3.%6.%5 >> %BCPLOG%\%0.log
	if exist %BCPTEMP%\%4_%5.bcp del %BCPTEMP%\%4_%5.bcp
	call bcpexp %1 %3 %4 %5
	if errorlevel 1 goto fout
	call bcpimp %2 %3 %4 %5 %6
	echo %DATE% %TIME% OK >> %BCPLOG%\%0.log
	goto einde
:paramfout
	echo onvoldoende parameters of variabelen BCPLOG of BCPTEMP niet gezet
	echo parameters: (sourceserver) (destserver) (dbname) (schema) (tablename) {newschema}
	goto einde
:fout
	echo %DATE% %TIME% ERROR >> .log\%0.log
	pause
:einde
