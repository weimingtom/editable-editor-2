@echo off

set TEXTCMD=%CD%\
echo ��ǰĿ¼ %TEXTCMD%

pushd
::ִ��AIR���򣬲���InvokeEvent�¼�������
..\Tools\Air\bin\adl %~dp0\..\Tools\TextProcess\bin\application.xml -- %TEXTCMD%
popd

if exist ../NameString.xml (
	if exist NameString.xml del /s /q NameString.xml
)