@echo off
rem {server} {database} {schema} {table} (newschema)
rem set DEBUG=ECHO to show commands
rem set TRUNCATE_FIRST=Y to truncate table before import
rem set DELETE_FIRST=Y to delete table before import
rem
if "%4"=="" goto :EOF
if "%5"=="" (
	echo Import %1.%2.%3.%4 ...
	echo %DATE% %TIME% Import %1.%2.%3.%4 >>.\log\bcpimp.log
	if "%TRUNCATE_FIRST%"=="Y" (
		echo Truncating table first
		echo %DATE% %TIME% Truncate %1.%2.%3.%4 >>.\log\bcpimp.log
		%DEBUG% sqlcmd -S%1 -d%2 -E -Q"truncate table [%3].[%4]" -b 
		if errorlevel 1 goto :fout 
	)
	if "%DELETE_FIRST%"=="Y" (
		echo Delete table first
		echo %DATE% %TIME% Delete %1.%2.%3.%4 >>.\log\bcpimp.log
		%DEBUG% sqlcmd -S%1 -d%2 -E -Q"delete from [%3].[%4]" -b >>.\log\bcpimp.log
		if errorlevel 1 goto :fout 
	)
	%DEBUG% bcp "%3.%4" in ".\Temp\%3_%4.bcp" -S%1 -n -T -d%2 -b100000 -o".\log\bcpimp_%2_%3_%4.log" -E -m0 -q
	if errorlevel 1 goto :fout 
)
if not "%5"=="" (
	echo Import %1.%2.%5.%4 ...
	echo %DATE% %TIME% Import %1.%2.%5.%4 >>.\log\bcpimp.log
	if "%TRUNCATE_FIRST%"=="Y" (
		echo Truncate table first
		echo %DATE% %TIME% Truncate %1.%2.%5.%4>>.\log\bcpimp.log
		%DEBUG% sqlcmd -S%1 -d%2 -E -Q"truncate table [%5].[%4]" -b>>.\log\bcpimp.log
		if errorlevel 1 goto :fout 
	)
	if "%DELETE_FIRST%"=="Y" (
		echo Delete table first
		echo %DATE% %TIME% Delete %1.%2.%5.%4 >>.\log\bcpimp.log
		echo sqlcmd -S%1 -d%2 -E -Q"delete from [%5].[%4]" -b >>.\log\bcpimp.log
		%DEBUG% sqlcmd -S%1 -d%2 -E -Q"delete from [%5].[%4]" -b >>.\log\bcpimp.log
		if errorlevel 1 goto :fout 
	)
	%DEBUG% bcp "%5.%4" in ".\Temp\%3_%4.bcp" -S%1 -n -T -d%2 -b100000 -o".\log\bcpimp_%2_%5_%4.log" -E -m0 -q
	if errorlevel 1 goto :fout 
)
echo %DATE% %TIME% OK >>.\log\bcpimp.log
goto :einde
:fout
echo ERROR
echo %DATE% %TIME% ERROR >>.\log\bcpimp.log
echo %DATE% %TIME% %0 %3_%4.bcp >>.\log\bcp.err
:einde
rem %DEBUG% del .\Temp\%3_%4.bcp
