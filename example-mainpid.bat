@echo off
::v1.1.0
IF /I "%1"=="/SHOW" GOTO :SHOW 

set PID_START_PATH_SET=%~nx0 /SHOW Main_form
call pid /start solo cmd

set getpid=%errorlevel%

set PID_START_PATH_SET=%~nx0 /SHOW Subform:%getpid%
call pid /start %getpid% cmd
set PID_START_PATH_SET=%~nx0 /SHOW Subform:%getpid%
call pid /start %getpid% cmd
set PID_START_PATH_SET=%~nx0 /SHOW Subform:%getpid%
call pid /start %getpid% cmd

EXIT /B

:SHOW
	title [%PIDMD_PRID%]MSG
	ECHO [%2]
	ECHO.
	ECHO.PID VER
	CALL PID /VERSION
	PAUSE
	EXIT
