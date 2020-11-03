@echo off
rem versie 21-9-2020
rem parameters: {servername} {databasename} {schemaname} {tablename}
if "%4"=="" goto paramfout
if "%BCPTEMP%"=="" goto paramfout
if "%BCPLOG%"=="" goto paramfout
:
echo Export %1.%2.%3.%4 ...
echo %DATE% %TIME% Export %1.%2.%3.%4 >> %BCPLOG%\%0.log
%DEBUG% bcp "%3.%4" out %BCPTEMP%\%3_%4.bcp -S%1 -q -N -T -d%2 -o%BCPLOG%\%2_%3_%4.log
if errorlevel 1 goto :fout
echo %DATE% %TIME% OK >>%BCPLOG%\%0.log
echo OK
goto :EOF
:paramfout
echo onvoldoende parameters of variabelen BCPLOG of BCPTEMP niet gezet
goto einde
:fout
echo %DATE% %TIME% ERROR >>%BCPLOG%\%0.log
rem type %BCPLOG%\%2_%3_%4.log | more
