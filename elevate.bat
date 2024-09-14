@echo off
echo ============================
echo Invoke Admin Rights...
echo ============================
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
echo [MAIN/Thread]\CheckPrivileges.vasb
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else (
    echo [MAIN/Thread]\CheckPrivileges.vasb: None
    goto getPrivileges )

:getPrivileges
echo [MAIN/Thread]\getPrivilages.vasb
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  echo [MAIN/Thread]\getPrivilages.vasb: Requested Invoke... Awaiting for response!
  echo [MAIN/Thread]\Invoke.vabs
  if '%cmdInvoke%'=='1' goto InvokeCmd 
  

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation

 if "%2"=="-a" ( echo [CHILD/Thread]\RunThread: -a found, program=%1, arg=%3,%4 )
echo [MAIN/Thread]\Invoke.vabs: UAC service Started.
echo [MAIN/Thread]\TaskHandller: Passing (%1 %2 %3 %4) to execution...
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*

 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
 

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::

 cls
 net session >nul 2>&1
    if %errorLevel% == 0 (
        echo [MAIN/Thread]\Invoke.vabs: Success: Elevation approved!
    ) else (
        echo [MAIN/Thread]\Invoke.vabs: Failure: Elevation Not approved!
        echo [MAIN/Thread]\Invoke.vabs: Retrying current jod...
        goto getPrivileges
        cls
    )


 if NOT "%2"=="-a" (
  start %1
    
 ) else (
    echo [MAIN/Thread]\RunThread: -a found, program=%1, arg=%3,%4
    start %1 %3 %4
 )