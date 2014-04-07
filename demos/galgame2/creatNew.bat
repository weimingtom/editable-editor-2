@echo off
echo  ‰»Î»˝Œª±‡∫≈
set/p ID_FOLDER=

if not exist %ID_FOLDER% (
	md %ID_FOLDER%
	copy 000\exportScript.bat %ID_FOLDER%\exportScript.bat
	copy 000\makeText.bat %ID_FOLDER%\makeText.bat
	copy 000\text.csv %ID_FOLDER%\text.csv
)