@echo off

set TEXTCMD=%CD%\
echo 当前目录 %TEXTCMD%

pushd
::执行AIR程序，并向InvokeEvent事件传参数
..\Tools\Air\bin\adl %~dp0\..\Tools\TextProcess\bin\application.xml -- %TEXTCMD%
popd

if exist ../NameString.xml (
	if exist NameString.xml del /s /q NameString.xml
)