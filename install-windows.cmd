@ECHO OFF

REM define variables
REM ================

SET myzip=%~dp0Windows\RT-Perl5\RT-Perl5.zip
SET path1=C:\Program Files\Inkscape\
SET path2=C:\Program Files (x86)\Inkscape\
SET inkdir=NONE
SET perlexe=NONE
SET perlpath=NONE

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

REM set perlpath to  %inkdir%\Perl5
SET perlpath=%inkdir:"=%Perl5

REM Set the origami modules path
SET origamipath=%inkdir:"=%share\extensions\Origami

REM If RT-Perl5 is available, add it to the PATH
IF EXIST %perlPath%\perl\bin\perl.exe (
  PATH=%PATH%;%perlPath%\perl\bin;
)

REM Check if any Perl (even th RT-Perl5) is available on
REM system. If yes, do not install the RT 
REM ==================================================

perl -v >NUL 2>&1 && GOTO :PERLOK

REM Perl5 runtime install
REM =====================

REM Check if RT-Perl5 zip file is available
IF NOT EXIST "%myzip%" (
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

REM Unzip the runtime
REM echo Installing Perl5 runtime...

echo install RT-Perl5
%~dp0\Windows\unzip -qo -d "%perlpath%" "%myzip%" || GOTO :ERROR
echo done

REM End of Perl runtime install
REM ===========================

:PERLOK

REM Now we know we have Perl to execute Windows/install-windows.pl

REM If Origami module is present, it is an uninstall
IF EXIST "%origamipath%" GOTO :UNINSTALL

REM Installation of Origami-Ext
CALL perl "%~dp0\Windows\install-windows.pl" "INSTALL" || GOTO :SUCCESS

GOTO CLEANUP

REM Uninstallation process
REM ======================

:UNINSTALL

REM Removal of Origami-Ext
CALL perl "%~dp0\Windows\install-windows.pl" "UNINSTALL" || GOTO ERROR



REM Closing script
REM===============

:SUCCESS

CALL :CLEANUP
REM exit with success code
EXIT /B 0

:ERROR
CALL :CLEANUP
echo:
echo Sorry, it seems something went wrong during intallation.
echo:
PAUSE
REM exit with error code
EXIT /B 1

:CLEANUP

REM Removal of RT-Perl5 if installed if Origami not installed
IF NOT EXIST "%origamipath%" (
  IF EXIST "%perlpath%" (
      REM echo Removing Perl5 runtime...
      rmdir "%perlpath%" /s /q
      REM echo Done.
  )
)
EXIT /B 0