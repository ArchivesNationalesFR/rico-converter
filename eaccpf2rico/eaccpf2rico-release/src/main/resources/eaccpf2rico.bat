@echo off
PATH %PATH%;%JAVA_HOME%\bin\

ECHO :: Welcome to EAC-CPF 2 Ric-O Converter ${project.version} ::
ECHO.

REM Test if java is installed
WHERE java >nul 2>nul
if %errorlevel%==1 (
    ECHO Java not found in path - Please install Java 1.8 or newer.
    exit
)

REM Fetch java version e.g. 180171
for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do set "jver=%%j%%k%%l%%m"
REM ECHO %jver%

if %jver% LSS 180000 (
	ECHO Java version not supported. Please install Java 1.8 or newer.
	exit
)

SET command=convert_arrange
set /p command=Enter command to execute (convert_arrange, convert, test, version) [press enter for "%command%"]:

SET parameterFile=parameters/%command%.properties
set /p parameterFile=Enter parameter file location [press enter for "%parameterFile%"]:

SET fullCommandLine=java -Xmx2048M -Xms1024M -jar eaccpf2rico-cli-${project.version}-onejar.jar %command% @%parameterFile%
ECHO %fullCommandLine%
%fullCommandLine%
pause