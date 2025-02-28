@echo off
set PIDMD_ROOT=%~dp0
set PATH=%PATH%;%PIDMD_ROOT%
set PM_VER=1.1.0-lite
set PIDMD_DISABLE_RUN=true

set LANG=zh
:: DO NOT CHANG LANG STR
set en_check_pid_info=INFO:
set zh_check_pid_info=信息:

if not exist "%PIDMD_ROOT%SYS\PID\" mkdir "SYS\PID"
if not exist "%PIDMD_ROOT%TMP\" mkdir "TMP\"

if /i "%1"=="/run" goto run
if /i "%1"=="/start" goto start
if /i "%1"=="/check_pid" goto check_pid
if /i "%1"=="/killpid" goto kill
if /i "%1"=="/killpid-f" goto kill
if /i "%1"=="/list" goto list
if /i "%1"=="/version" goto version
exit /b -3

:version
	echo.%PM_VER%
exit /b 0

:list
	set _cd=%cd%
	cd /d "%PIDMD_ROOT%"
	for /r %%f in (SYS/PID/*) do echo %%~nxf
	cd /d "%cd%"
exit /b 0

:kill
	call :exist_pid %2
	if "%errorlevel%"=="1" (
		echo -ERR- %2 Not exist
		if exist "%PIDMD_ROOT%SYS\PID\*-%2" echo -ERR- Clear file &del "%PIDMD_ROOT%SYS\PID\*-%2"
		exit /b -1
	)
	if /i "%1"=="/killpid-f" (taskkill /F /PID %2) else (taskkill /PID %2)
	del "%PIDMD_ROOT%SYS\PID\*-%2"
exit /b 0

:run
	if /i "%PIDMD_DISABLE_RUN%"=="true" exit /b -2
	if DEFINED PID_RUN_PATH_SET (getpid %PID_RUN_PATH_SET%) else (
		if not "%2"=="" (getpid %2 %3 %4 %5 %6 %7 %8 %9) else (echo -ERR- Path not set & exit /b -1)
	)
	set PG_PID=%errorlevel%
	
	if "%PG_PID%"=="0" echo -ERR- Create fail & exit /b -1
	
	goto SET_PID_FILE

:start
	if /i not "%2"=="SOLO" (
		if not exist "%PIDMD_ROOT%SYS\PID\*-%2" (
			echo -ERR- Rely on pid not exist!
			exit /b
		)
	)
	
	if DEFINED PID_START_PATH_SET (getpid %PID_START_PATH_SET%) else 	(
		if not "%3"=="" (getpid %3 %4 %5 %6 %7 %8 %9) else (echo -ERR- Path not set & exit /b -1)
	)

	set PG_PID=%errorlevel%
	
	if "%PG_PID%"=="0" echo -ERR- Create fail & exit /b -1
	
	goto SET_PID_FILE

:SET_PID_FILE
	if /i "%1"=="/RUN" (
		echo PID=%PG_PID%>"%PIDMD_ROOT%SYS\PID\%2-%PG_PID%"
		echo NAME=%2>>"%PIDMD_ROOT%SYS\PID\%2-%PG_PID%"
	) else (
		echo PID=%PG_PID%>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		echo NAME=%3>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
	)
	
	if /i "%1"=="/RUN" (
		if DEFINED PID_RUN_PATH_SET (
			echo COMVAL=%PID_RUN_PATH_SET%>>"%PIDMD_ROOT%SYS\PID\%2-%PG_PID%"
		) else (
			echo COMVAL=%3 %4 %5 %6 %7 %8>>"%PIDMD_ROOT%SYS\PID\%2-%PG_PID%"
		)
		echo RELY_ON=SOLO>>"%PIDMD_ROOT%SYS\PID\%2-%PG_PID%"
		start hiderun PID.cmd /check_pid %PG_PID% SOLO
	) else (
		if DEFINED PID_START_PATH_SET (
			echo COMVAL=%PID_START_PATH_SET%>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		) else (
			echo COMVAL=%4 %5 %6 %7 %8>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		)
		echo RELY_ON=%2>>"%PIDMD_ROOT%SYS\PID\%3-%PG_PID%"
		start hiderun PID.cmd /check_pid %PG_PID% %2
	)
	
	set PID_START_PATH_SET=
	SET PID_RUN_PATH_SET=
	
	exit /b %PG_PID%

:exist_pid
::call :exist_pid [PID]
	FOR /F %%s in ('TASKLIST /FI "PID eq %1"') do set cmdput=%%s
	if /i "%LANG%"=="zh" (
		if "%cmdput%"=="%zh_check_pid_info%" exit /b 1
	)
	if /i "%LANG%"=="en" (
		if "%cmdput%"=="%en_check_pid_info%" exit /b 1
	)
exit /b 0

:check_pid
	:check_pid_loop
		if /i not "%3"=="SOLO" (
			IF NOT EXIST "%PIDMD_ROOT%SYS\PID\*-%3" (
				start hiderun call PID.cmd /killpid-f %PG_PID%
				exit /b
			)
		)
		
		if not exist "%PIDMD_ROOT%SYS\PID\*-%2" (
			start hiderun call PID.cmd /killpid-f %PG_PID%
			exit /b
		)
		
		call :exist_pid %2
		if "%errorlevel%"=="1" (
			start hiderun call PID.cmd /killpid %PG_PID%
			exit /b
		)
	goto check_pid_loop
