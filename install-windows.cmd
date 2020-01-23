@ECHO OFF

REM define variables
REM ================

SET myzip="%~dp0Windows\RT-Perl5\RT-Perl5.zip"
SET path1=C:\Program Files\Inkscape\
SET path2=C:\Program Files (x86)\Inkscape\
SET inkdir=NONE
SET perlpath=NONE
SET perlexe=NONE

REM Test if sript is run with Admin rights
REM If not, the abort install.
REM ======================================
net session >NUL 2>&1 && GOTO :OK_ADMIN

echo:
echo:
echo Sorry, this script must be run with Admin rights.
echo:
echo Aborting installation of Origami-Ext!
echo:
PAUSE
GOTO ERROR

REM We know now we are running as Admin...
:OK_ADMIN

REM Check if Inkscsape is installed on the system :
REM Check for either the 64-bits (version (in Program Files)
REM or in 32-bits version (in Program Files (x86))
REM ========================================================
IF EXIST "%path1%" (
  SET inkdir="%path1%"
) ELSE (
    IF EXIST "%path2%" (
      SET inkdir="%path2%"
    ) 
)

REM Inkscape directory has not been found so abort the installation 
IF %inkdir% == NONE (
    echo:
    echo:
    echo Sorry: Inkscape is not installed on your computer :
    echo:
    echo Aborting installation of Origami-Ext!
    echo:
    PAUSE
    GOTO ERROR
)

REM Check if RT-Perl5 zip file is available :
IF NOT EXIST %myzip% (
    echo:
    echo:
    echo Sorry, the Perl5 runtime was not found :
    echo:
    echo You are maybe running install-windows.cmd from
    echo outside the Origami-Ext directory.
    echo:
    echo CD to it and retry.
    echo:
    echo:
    echo Aborting installation of Origami-Ext!
    echo:
    PAUSE
    GOTO ERROR
)

echo Loading: please wait...

REM variable setup
SET perlpath="%inkdir:"=%Perl5"
SET perlexe="%perlpath:"=%\bin\perl.exe"

REM If runtime unavailable, install it
IF NOT EXIST %perlpath% (
    SET action=INSTALL
    CALL :INSTALL_RUNTIME
) ELSE (
    SET action=UNINSTALL
)

SET PATH=%perlPath:"=%\bin;%PATH%;

CALL perl "%~dp0\Windows\install-windows.pl" %action% || GOTO :ERROR

IF %action% == UNINSTALL (
    CALL :REMOVE_RUNTIME
)
EXIT /B 0

:ERROR

REM Intallation error : suppress Perl5
IF %action% == INSTALL (
    CALL :REMOVE_RUNTIME
)
EXIT /B 1
    
:INSTALL_RUNTIME
REM ECHO installing Perl5 runtime...
%~dp0\Windows\unzip -qo -d "%perlpath:"=%-TMP" %myzip% || GOTO :ERROR
MOVE /y "%perlpath:"=%-TMP\perl" %perlpath% >nul
RD /q "%perlpath:"=%-TMP"
REM ECHO done.
EXIT /B

:REMOVE_RUNTIME
    REM ECHO Remove Perl Runtime...
    RD /q /s %perlpath%
    REM ECHO done.
EXIT /B


