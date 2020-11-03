	@echo off
	rem version 2020-11-03
	rem {server} {database} {schema} {table} (newschema)
	rem set DEBUG=ECHO to show commands
	rem set TRUNCATE_FIRST=Y to truncate table before import
	rem set DELETE_FIRST=Y to delete table before import
	rem set BCPTEMP to specify location of BCP files
	rem set BCPlog to specify location of logfiles
	rem set DELETE_BCPFILE to specify if .bcp file should be deleted after SUCCESSFUL import
	rem
	if "%4"=="" goto paramfout
	if "%BCPTEMP%"=="" goto paramfout
	if "%BCPLOG%"=="" goto paramfout
:
	if not exist %BCPTEMP%\%3_%4.bcp goto notfound
:
	if "%5"=="" (
		if "%TRUNCATE_FIRST%"=="Y" (
			echo Truncating table %3.%4 ...
			echo %DATE% %TIME% Truncate %1.%2.%3.%4 >> %BCPLOG%\bcpimp.log
			%DEBUG% sqlcmd -S%1 -d%2 -E -Q"truncate table [%3].[%4]" -b >>%BCPLOG%\bcpimp.log
			if errorlevel 1 goto fout 
		)
		if "%DELETE_FIRST%"=="Y" (
			echo Delete table %3.%4 ...
			echo %DATE% %TIME% Delete %1.%2.%3.%4 >>%BCPLOG%\bcpimp.log
			%DEBUG% sqlcmd -S%1 -d%2 -E -Q"delete from [%3].[%4]" -b >>%BCPLOG%\bcpimp.log
			if errorlevel 1 goto fout 
		)
		echo import %1.%2.%3.%4 ...
		echo %DATE% %TIME% Import %1.%2.%3.%4 >>%BCPLOG%\bcpimp.log
		%DEBUG% bcp "%3.%4" in %BCPTEMP%\%3_%4.bcp -S%1 -N -T -q -d%2 -b100000 -o%BCPLOG%\%2_%3_%4.log -E -m0 -h"TABLOCK"
		if errorlevel 1 goto fout 
	)
	if not "%5"=="" (
		if "%TRUNCATE_FIRST%"=="Y" (
			echo Truncate table %5.%4 ...
			echo %DATE% %TIME% Truncate %1.%2.%5.%4 >>%BCPLOG%\bcpimp.log
			%DEBUG% sqlcmd -S%1 -d%2 -E -Q"truncate table [%5].[%4]" -b >>%BCPLOG%\bcpimp.log
			if errorlevel 1 goto fout 
		)
		if "%DELETE_FIRST%"=="Y" (
			echo Delete table %5.%4 ...
			echo %DATE% %TIME% Delete %1.%2.%5.%4 >>%BCPLOG%\bcpimp.log
			%DEBUG% sqlcmd -S%1 -d%2 -E -Q"delete from [%5].[%4]" -b >>%BCPLOG%\bcpimp.log
			if errorlevel 1 goto fout 
		)
		echo import %1.%2.%5.%4 ...
		echo %DATE% %TIME% Import %1.%2.%5.%4 >>%BCPLOG%\bcpimp.log
		%DEBUG% bcp [%5].[%4] in %BCPTEMP%\%3_%4.bcp -S%1 -N -T -q -d%2 -b100000 -o%BCPLOG%\%2_%5_%4.log -E -m0 -h"TABLOCK"
		if errorlevel 1 goto :fout 
	)
	echo %DATE% %TIME% OK >>%BCPLOG%\bcpimp.log
:
	%DEBUG% if "%DELETE_BCPFILE%"=="Y" (
			echo Deleting del %BCPTEMP%\%3_%4.bcp
			del %BCPTEMP%\%3_%4.bcp
	)
	echo OK
	goto :einde
:paramfout
	echo onvoldoende parameters of variabelen BCPLOG of BCPTEMP niet gezet
	goto einde
:notfound
	echo Bestand "%BCPTEMP%\%3_%4.bcp" niet gevonden
	goto einde
:fout
	echo ERROR
	echo %DATE% %TIME% ERROR >>%BCPLOG%\bcpimp.log
	echo %DATE% %TIME% %3_%4.bcp >>%BCPLOG%\bcpimp.err
:einde
