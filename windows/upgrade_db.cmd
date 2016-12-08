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
SET sqllite_command=sqlite3 dbtest.db

CALL :setUp
CALL :log "Set-up complete"
CALL :getLatestDbVersion
::CALL :log "Found latest Db version : %db_version%"
CALL :processDbScripts

::A function to process files in db_scripts one by one to apply
:processDbScripts
setlocal EnableDelayedExpansion
rem Create an array with filenames in right order
for %%f in (*.sql) do (
   for /F "delims=-" %%n in ("%%f") do (
      set "number=00000%%n"
      set "file[!number:~-6!]=%%f"
   )
)
rem Process the filenames in right order
for /F "tokens=2 delims==" %%f in ('set file[') do (
   echo %%f
)
EXIT /B


::A function to get the latest available version on the Database
:getLatestDbVersion
::ECHO select max(version) from changelog;| sqlite3 dbtest.db > temp.txt
CALL :log "Fetching latest Db version from sqlite"
%sqllite_command% < getLatestDbVersion.sql > temp.txt
SET /p db_version=<temp.txt
SET db_version=%db_version: =%
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
