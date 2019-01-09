@echo off
PATH %PATH%;%JAVA_HOME%\bin\

REM test if java is installed
WHERE java >nul 2>nul
if %errorlevel%==1 (
    ECHO Java not found in path - Please install Java 1.8 or newer.
    exit
)

REM fetch java version e.g. 180171
for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do set "jver=%%j%%k%%l%%m"
REM ECHO %jver%

if %jver% LSS 180000 (
	ECHO Java version not supported. Please install Java 1.8 or newer.
	exit
)