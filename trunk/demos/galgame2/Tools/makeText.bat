@echo off
ECHO ...dealing String...


if exist *.txt del /s *.txt>NUL

..\Tools\ExportCsv\ExportCsv.exe text.csv

if exist STR_*_LIB.txt del /s STR_*_LIB.txt >NUL

rem ##############

for %%i in (STR_???.txt) do (
	..\Tools\StringToBin\StringToBin.exe %%i %%~ni.bin
)

if exist STR.h del /s STR.h >NUL
if exist STR_CHS.bin move /y STR_CHS.bin data.bin
