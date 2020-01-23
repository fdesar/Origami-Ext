@echo off

SET sysperl=NONE
SET syswperl=NONE
SET inkpath=NONE
SET path1="C:\Program Files\Inkscape"
SET path2="C:\Program Files (x86)\Inkscape"

net session >NUL 2>&1 || GOTO :NO_ADMIN

IF EXIST %path1% (
  SET inkpath=%path1%
) ELSE (
  IF EXIST %path2% (
    SET inkpath=%path2%
  )
)

IF %inkpath% == NONE (
  GOTO NO_INKSCAPE
)

IF NOT EXIST "%inkpath:"=%\Perl5" (
  GOTO NO_ORIGAMI-EXT
)
 
CALL where perl >null 2>&1 || GOTO NOPERL 
CALL where wperl >null 2>&1 || GOTO NOPERL 

FOR /F %%i IN ('where perl') DO set sysperl=%%i
FOR /F %%i IN ('where wperl') DO set syswperl=%%i

perl -e "use XML::LibXML" >nul 2>&1|| GOTO NO_XML 

COPY "%syswperl%" "%inkpath:"=%\wperl.exe" >null
COPY "%syswperl%" "%inkpath:"=%\perl.exe" >null
RD /q /s  "%inkpath:"=%\Perl5"
MD "%inkpath:"=%\Perl5" >null

ECHO:
ECHO You are now using your system wide Perl.
ECHO:

PAUSE
EXIT /B 0

:NOPERL

ECHO:
echo No Perl found on your system.
ECHO:
PAUSE
EXIT /B 1

:NO_XML

ECHO:
echo Module XML::LibXML missing from your Perl installation.
ECHO:
echo Install it and then rerun.
ECHO:

PAUSE
EXIT /B 1

:NO_INKSCAPE

ECHO:
echo Sorry, Inkscape not found on your system.
ECHO:
ECHO Install it first and install Origami-EXT then rerun
ECHO:

PAUSE
EXIT /B 1

:NO_ORIGAMI-EXT

ECHO:
echo Sorry, Origami-EXT not installed on your system.
ECHO:
ECHO Install it first and then rerun.
ECHO:

PAUSE
EXIT /B 1

:NO_ADMIN

ECHO:
echo Sorry, this script must be run with Admin rights!
ECHO:

PAUSE
EXIT /B 1

