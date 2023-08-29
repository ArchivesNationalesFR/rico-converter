@echo off
PATH %PATH%;%JAVA_HOME%\bin\

ECHO :: Welcome to Ric-O Converter 2.0.0-beta ::
ECHO.

REM Test if java is installed
WHERE java >nul 2>nul
if %errorlevel%==1 (
    ECHO Java not found in path - Please install Java 1.8 or newer.
    exit
)

REM Fetch java version e.g. 180171
for /f tokens^=2-5^ delims^=++.-_^" %%j in ('java -fullversion 2^>^&1') do set "jver=%%j%%k"
REM ECHO %jver%

if %jver% LSS 18 (
	ECHO Java version not supported. Please install Java 1.8 or newer.
	exit
)

SET command=convert_eac
set /p command=Enter command to execute (convert_eac, convert_eac_raw, convert_ead, test_eac, test_ead, version, help) [press Enter for "%command%"]:

SET parameterFile_default=parameters/%command%.properties
SET parameterFile=
if NOT %command% == help (
	set /p parameterFile=Enter parameter file location [press Enter for "%parameterFile_default%"]:
)

if NOT !%parameterFile% == ! (
	set parameterFileOption=@%parameterFile%
)

SET fullCommandLine=java -Xmx1200M -Xms1200M -jar ricoconverter-cli-2.0.0-beta-onejar.jar %command% %parameterFileOption%
ECHO %fullCommandLine%
%fullCommandLine%
pause