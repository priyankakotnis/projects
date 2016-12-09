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
CALL :processDbScripts
::CALL :validateAndApplyDbScript db_scripts\052.insert_city.sql
GOTO :eof

::A function to process files in db_scripts one by one to apply
:processDbScripts
setlocal EnableDelayedExpansion
REM Create an array with filenames in right order
CD %input_dir%
for /F "tokens=*" %%p in ('dir /b "*.sql"') do CALL :validateAndApplyDbScript %%p
EXIT /B

::A function to validate the Db script
:validateAndApplyDbScript
CALL :log "Received file %~1"
CALL :getLatestDbVersion
CALL :getProposedScriptVersion
CALL :log "Found Db version %db_version% and proposed new version %proposed_version%"
if "%db_version%" LSS "%proposed_version%" (
	CALL :executeUpdate %~1
) else (
    CALL :log "No change to apply for %~1"
	CALL :log "Moving file  %~1 to %skipped_dir%"
	MOVE %input_dir%\%~1 %skipped_dir%\ > nul 2> nul
)
EXIT /B

::A function to execute the Db script
:executeUpdate
CALL :log "Executing script %~1"
%sqllite_command% < %input_dir%\%~1 > nul 2> %logfile_name%
::ECHO %ERRORLEVEL%
if %ERRORLEVEL% GTR 0 (
 CALL :log "Error while processing script %~1 , please check %logfile_name% for details."
 CALL :log "Moving file  %~1 to %rejected_dir%"
 MOVE %input_dir%\%~1 %rejected_dir%\ > nul 2> nul
 EXIT /B
)
CALL :insertNewDbVersion %~1
EXIT /B

::A function to get version in the script - currently has hardcoding because of time limit on test
:getProposedScriptVersion
SET proposed_version=15
EXIT /B

::A function to insert new Db version to changelog
:insertNewDbVersion
ECHO INSERT INTO `changelog` (script_name,version,log_date) VALUES ('%~1','%proposed_version%',date('now')); | %sqllite_command%
CALL :log "Processing completed for %~1 now moving file to %output_dir%"
MOVE %~1 %output_dir%\ > nul 2> nul
EXIT /B

::A function to get the latest available version on the Database
:getLatestDbVersion
CALL :log "Fetching latest Db version from sqlite"
cd %base_dir%
sqlite3 dbtest.db < getLatestDbVersion.sql > db_version.txt
SET /p db_version=<db_version.txt
if %ERRORLEVEL% GTR 0 CALL :log "Error occured while fetching Db version"
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
