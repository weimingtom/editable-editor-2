ECHO ...dealing String...
@echo off

if exist *.txt del /s *.txt>NUL

ExportCsv\ExportCsv.exe text.csv

if exist STR_*_LIB.txt del /s STR_*_LIB.txt >NUL

rem ##############

for %%i in (STR_???.txt) do (
	StringToBin\StringToBin.exe %%i %%~ni.bin
)

if exist STR.h del /s STR.h >NUL