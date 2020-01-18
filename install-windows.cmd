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
EXIT /B 1

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
    EXIT /B 1
)

REM set perlpath to  inkdir+\Perl5
SET perlpath=%inkdir:"=%Perl5

REM test if Origami-Ext is already installed
SET origamipath=%inkdir:"=%share\extensions\Origami
IF EXIST "%origamipath%" GOTO :UNINSTALL

REM Check if Perl is already installed on ths system
REM If it already is, do not install the runtime
REM ==================================================

REM RT-Perl5 is maybe already installed but PATH may not be
REM up to date so set it (maybe again !) before testing

IF EXIST %perlPath%\perl\bin\perl.exe (
  PATH=%PATH%;%perlPath%\perl\bin;
)

perl -v >NUL 2>&1 && GOTO :PERLOK

REM Install the Perl runtime
REM ========================

REM unzip the RT-Perl5 runtime
REM ==========================
REM Check if RT-Perl5 is available
IF NOT EXIST "%myzip%" (
    echo:
    echo:
    echo Sorry, RT-PERL5.zip not found :
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
    EXIT /B 1
)

REM Unzip the runtime
REM echo Installing PERL runtime...

echo install RT-Perl5
call %~dp0\Windows\unzip -qo -d "%perlpath%" "%myzip%" || GOTO :ERROR
echo done

REM echo Done

REM Set the fully qualified perl.exe program
SET perlexe=%perlpath:"=%\perl\bin\perl
SET perlexe="%perlexe%"

:PERLOK
call perl "%~dp0\Windows\install-windows.pl" "INSTALL" %perlexe% || GOTO :CLEANUP

GOTO CLEANUP

REM End of install
REM ==============


:UNINSTALL

call perl "%~dp0\Windows\install-windows.pl" "UNINSTALL" %perlexe% || GOTO :CLEANUP

:CLEANUP

IF NOT EXIST "%origamipath%" (
    IF EXIST "%perlpath%" (
        REM echo Removing PERL runtime...
        rmdir "%perlpath%" /s /q
        REM echo Done.
    )
)

REM exit with success
REM
EXIT /B 0
