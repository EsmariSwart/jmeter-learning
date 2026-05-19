@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Run from repo root (where this file lives)
cd /d "%~dp0"

call :resolve_jmeter
if errorlevel 1 exit /b 1

call :verify_jmeter
if errorlevel 1 (
  echo.
  pause
  exit /b 1
)

echo   JMeter ready.
echo   Launcher: !JMETER_CMD!
echo   JAR:      !RUN_JM_JAR!
echo.

if not exist "results" mkdir "results"
if not exist "reports" mkdir "reports"

set "LIST_FILE=%TEMP%\jmeter_run_%RANDOM%.lst"
if exist "%LIST_FILE%" del "%LIST_FILE%"

goto :menu

REM ---------------------------------------------------------------------------
REM Subroutines (main flow must not fall through into these)
REM ---------------------------------------------------------------------------

:run_test
set "JMX=%~f1"
set "BASE=%~2"
set "JTL=%~dp0results\%BASE%.jtl"
set "REPORT=%~dp0reports\%BASE%"

echo ------------------------------------------------------------
echo Test: %JMX%
echo JTL:  %JTL%
echo HTML: %REPORT%\index.html
echo ------------------------------------------------------------

if exist "%REPORT%" rmdir /s /q "%REPORT%"

REM Do not set JMETER_BIN here - jmeter.bat uses it for the jar path
set "JMETER_BIN="
pushd "!RUN_JM_DIR!"
call "!JMETER_CMD!" -n -t "!JMX!" -l "!JTL!" -e -o "!REPORT!"
set "RUN_RC=!ERRORLEVEL!"
popd
exit /b !RUN_RC!

:run_selected
set "IDX=%~1"
set "JMX="
set "BASE="
for %%i in (%IDX%) do (
  set "JMX=!TEST_%%i!"
  set "BASE=!NAME_%%i!"
)
if not defined JMX exit /b 1
call :run_test "!JMX!" "!BASE!"
exit /b %ERRORLEVEL%

:build_catalog
set "COUNT=0"
if exist "%LIST_FILE%" del "%LIST_FILE%"

for /f "delims=" %%D in ('dir /b /ad /o:n "scripts" 2^>nul') do (
  call :catalog_phase_folder "scripts\%%D" "%%D"
)

if exist "scripts\*.jmx" (
  call :phase_has_runnable_root
  if not errorlevel 1 (
    echo.
    echo   General:
    echo.
    for %%F in ("scripts\*.jmx") do call :register_test "%%F"
  )
)
exit /b 0

:catalog_phase_folder
set "PHASE_DIR=%~1"
set "PHASE_NAME=%~2"
call :phase_has_runnable_dir "%PHASE_DIR%"
if errorlevel 1 exit /b 0

call :print_phase_header "%PHASE_NAME%"
for /f "delims=" %%F in ('dir /s /b /o:n "%PHASE_DIR%\*.jmx" 2^>nul') do (
  call :register_test "%%F"
)
exit /b 0

:phase_has_runnable_dir
set "FOUND=1"
for /f "delims=" %%F in ('dir /s /b /o:n "%~1\*.jmx" 2^>nul') do (
  findstr /m /c:"<ThreadGroup" "%%F" >nul 2>&1
  if not errorlevel 1 set "FOUND=0"
)
exit /b !FOUND!

:phase_has_runnable_root
set "FOUND=1"
for %%F in ("scripts\*.jmx") do (
  findstr /m /c:"<ThreadGroup" "%%F" >nul 2>&1
  if not errorlevel 1 set "FOUND=0"
)
exit /b !FOUND!

:print_phase_header
set "FOLDER=%~1"
echo %FOLDER%| findstr /b /i "phase" >nul 2>&1
if not errorlevel 1 (
  set "TITLE=!FOLDER:phase=Phase !"
  echo.
  echo   !TITLE!:
  echo.
) else (
  echo.
  echo   %FOLDER%:
  echo.
)
exit /b 0

:register_test
set "JMX=%~1"
if not exist "%JMX%" exit /b 0
findstr /m /c:"<ThreadGroup" "%JMX%" >nul 2>&1
if errorlevel 1 exit /b 0

set /a COUNT+=1
set "TEST_!COUNT!=%JMX%"
for %%N in ("%JMX%") do (
  set "NAME_!COUNT!=%%~nN"
  set "FILE_!COUNT!=%%~nxN"
)
echo %JMX%>>"%LIST_FILE%"

set "PAD=  "
if !COUNT! geq 10 set "PAD= "
echo   !PAD!!COUNT!   !FILE_%COUNT%!
exit /b 0

:resolve_jmeter
set "JMETER_CMD="
set "RUN_JM_DIR="
set "RUN_JM_JAR="

REM Prefer JMETER_HOME (full paths) over a bare jmeter.bat on PATH
if defined JMETER_HOME (
  call :try_jmeter_install "%JMETER_HOME%\bin"
  if not errorlevel 1 exit /b 0
)

for /f "delims=" %%J in ('where jmeter.bat 2^>nul') do (
  if not defined JMETER_CMD call :try_jmeter_install "%%~dpJ"
)
goto :resolve_done

:try_jmeter_install
set "TRY_BIN=%~1"
REM Trailing backslash: use delayed expansion (if "%VAR%\" breaks parsing)
if "!TRY_BIN:~-1!"=="\" set "TRY_BIN=!TRY_BIN:~0,-1!"
set "RUN_JM_BAT=!TRY_BIN!\jmeter.bat"
set "RUN_JM_JAR=!TRY_BIN!\ApacheJMeter.jar"
if not exist "!RUN_JM_BAT!" exit /b 1
if not exist "!RUN_JM_JAR!" exit /b 1
set "RUN_JM_DIR=!TRY_BIN!"
set "JMETER_CMD=!RUN_JM_BAT!"
exit /b 0

:verify_jmeter
echo   Checking JMeter installation...

if not defined JMETER_CMD goto :verify_missing
if not defined RUN_JM_DIR goto :verify_missing
if not defined RUN_JM_JAR goto :verify_missing

if not exist "!JMETER_CMD!" (
  echo   ERROR: Launcher not found: !JMETER_CMD!
  exit /b 1
)
if not exist "!RUN_JM_JAR!" (
  echo   ERROR: JAR not found: !RUN_JM_JAR!
  exit /b 1
)

where java >nul 2>&1
if errorlevel 1 (
  echo   ERROR: java not on PATH. Set JAVA_HOME and add %%JAVA_HOME%%\bin to PATH.
  exit /b 1
)

exit /b 0

:verify_missing
echo   ERROR: JMeter was not resolved. JMETER_HOME or PATH may be wrong.
exit /b 1

:resolve_done
if defined JMETER_CMD exit /b 0

echo.
echo   ERROR: JMeter not found.
echo   Set JMETER_HOME to your install folder, e.g. C:\PerformanceTools\apache-jmeter-5.6.3
echo   Expected: %%JMETER_HOME%%\bin\jmeter.bat and ApacheJMeter.jar
echo.
exit /b 1

REM ---------------------------------------------------------------------------
REM Main menu
REM ---------------------------------------------------------------------------

:menu
cls
echo.
echo   JMeter Learning - Test Runner
echo   =============================
echo.

call :build_catalog
if !COUNT! equ 0 (
  echo   No runnable test plans found.
  echo   Looked under scripts\ for *.jmx containing a Thread Group.
  echo.
  goto :cleanup
)

echo.
echo   Options:
echo     A   Run ALL tests (in order^)
echo     Q   Quit
echo.
set "CHOICE="
set /p "CHOICE=   Select number, A, or Q: "

if /i "!CHOICE!"=="Q" goto :cleanup
if /i "!CHOICE!"=="A" goto :run_all

set "SEL=0"
for /f "tokens=1" %%N in ("!CHOICE!") do set "SEL=%%N"
for /f %%D in ('echo !SEL! ^| findstr /r "^[0-9][0-9]*$"') do set "SEL=%%D"
if "!SEL!"=="" goto :bad_choice
if !SEL! lss 1 goto :bad_choice
if !SEL! gtr !COUNT! goto :bad_choice

call :run_selected !SEL!
set "RUN_RC=!ERRORLEVEL!"
set "BASE="
for %%i in (!SEL!) do set "BASE=!NAME_%%i!"
echo.
if !RUN_RC! equ 0 (
  echo   Finished OK.
  echo   JTL:    results\!BASE!.jtl
  echo   Report: reports\!BASE!\index.html
) else (
  echo   Finished with errors. Exit code: !RUN_RC!
)
echo.
pause
goto :menu

:run_all
echo.
echo   Running all !COUNT! test plan(s^)...
echo.
set "FAIL=0"
for /f "usebackq delims=" %%F in ("%LIST_FILE%") do (
  call :run_test "%%F" "%%~nF"
  if errorlevel 1 set "FAIL=1"
)
echo.
if !FAIL! equ 0 (
  echo   All tests finished OK.
) else (
  echo   One or more tests failed.
)
echo.
pause
goto :menu

:bad_choice
echo.
echo   Invalid choice. Enter a number from 1 to !COUNT!, A, or Q.
timeout /t 2 >nul
goto :menu

:cleanup
if exist "%LIST_FILE%" del "%LIST_FILE%"
endlocal
exit /b 0
