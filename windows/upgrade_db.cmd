@echo off

:: script global variables
SET base_dir=E:\Workspace\ecs\db-upgrade-win-app
SET date_time=%date%
SET input_dir=%base_dir%\db_scripts
SET output_dir=%base_dir%\processed_files
SET skipped_dir=%base_dir%\skipped_files
SET rejected_dir=%base_dir%\rejected_files
SET log_dir=%base_dir%\logs
SET logfile_name=%log_dir%\execution_log.txt
SET db_version=0
SET proposed_version=0
SET sqllite_command=sqlite3 "%base_dir%\dbtest.db"

CALL :setUp
CALL :log "Set-up complete"
::CALL :getLatestDbVersion
::CALL :log "Found latest Db version : %db_version%"
CALL :processDbScripts
::CALL :validateAndApplyDbScript db_scripts\052.insert_city.sql
GOTO :eof

::A function to process files in db_scripts one by one to apply
:processDbScripts
setlocal EnableDelayedExpansion
REM Create an array with filenames in right order
CD %input_dir%
::for /F %%a in ('dir /b *.sql') do echo "Hii" %%a
::for  %%a in (*.sql) do echo "Hii" %%a
::for %%i in ('dir /b *.sql') do echo %%i
::for /f "skip=1" %%i in (1 2 3 4) do echo %%i
for /F "tokens=*" %%p in ('dir /b "*.sql"') do CALL :validateAndApplyDbScript %%p
EXIT /B



::A function to validate the Db script
:validateAndApplyDbScript
CALL :log "Received file %~1"
CALL :getLatestDbVersion
CALL :getProposedScriptVersion
CALL :log "Found Db version %db_version% and proposed new version %proposed_version%"
if "%db_version%" LSS "%proposed_version%" CALL :executeUpdate %~1
EXIT /B

::A function to execute the Db script
:executeUpdate
CALL :log "Executing script %~1"
%sqllite_command% < %input_dir%\%~1 > nul 2> %logfile_name%
::ECHO %ERRORLEVEL%
if %ERRORLEVEL% GTR 0 (
 CALL :log "Error while processing script %~1 , please check %logfile_name% for details."
 EXIT /B
)
CALL :insertNewDbVersion %~1
EXIT /B

::A function to get version in the script
:getProposedScriptVersion
SET proposed_version=11
EXIT /B

::A function to insert new Db version to changelog
:insertNewDbVersion
ECHO INSERT INTO `changelog` (script_name,version,log_date) VALUES ('%~1','%proposed_version%',date('now')); | %sqllite_command%
CALL :log "Processing completed for %~1 now moving file to %output_dir%"
MOVE %~1 %output_dir%\ > nul 2> nul
EXIT /B


::A function to get the latest available version on the Database
:getLatestDbVersion
::ECHO select max(version) from changelog;| sqlite3 dbtest.db > temp.txt
CALL :log "Fetching latest Db version from sqlite"
::%sqllite_command% < %base_dir%\getLatestDbVersion.sql > %base_dir%\temp.txt
cd %base_dir%
sqlite3 dbtest.db < getLatestDbVersion.sql > db_version.txt
SET /p db_version=<db_version.txt
::ECHO  "Database version found is -- : %db_version%"
::for /f "tokens=1" %%a in ('!db_version!') do set %db_version%=%%a
::ECHO  "Database version found is -- : %db_version%"
::SET db_version=%db_version: =%
::for /f "delims=" %%a in ('%sqllite_command% < %base_dir%\getLatestDbVersion.sql') do set "%db_version%=%%a"
if %ERRORLEVEL% GTR 0 CALL :log "Error occured while fetching Db version"
::SET db_version=<"%base_dir%\temp.txt"
::SET db_version=%db_version: =%
CALL :log "Database version found is : %db_version%"
EXIT /B

::A function to do initial set-up
:setUp
   MKDIR %log_dir% > nul 2> nul
   MKDIR %output_dir% > nul 2> nul
   MKDIR %skipped_dir% > nul 2> nul
   MKDIR %rejected_dir% > nul 2> nul
   CALL :log "Setting up"
   ECHO %date%_%time% >> %logfile_name%
   REM setUpMySQLConnectionForTest
EXIT /B

::A generic function to log a message passed as argument to screen and file
:log
ECHO %date% : %~1
ECHO %date% : %~1 >> %logfile_name%
EXIT /B
