@echo off
set HOSTFILE=c:/Windows/System32/drivers/etc/hosts

rem Initialise hosts file
set NET=%1
echo 127.0.0.1       localhost > %HOSTFILE%
echo ::1             localhost >> %HOSTFILE%

echo %NET%.2    server.rudder.local server rudder >> %HOSTFILE%

rem allow variable modification for iteration
setlocal enabledelayedexpansion
SET /A "i=2"

rem iterate over parameters to generate hosts file lines
:loop
if NOT [%2]==[] (
  echo %NET%.!i!    %2 >> %HOSTFILE%
  SET /A "i=!i!+1"
  shift
)
if NOT [%2]==[] goto loop

