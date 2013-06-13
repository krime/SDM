@echo off

set PTK=C:\PTK
set CYGWIN_PATH=%PTK%\cygwin
set JAVA_PATH=%PTK%\Java
set JAVA_HOME=%JAVA_PATH%\jdk7
set JRE_HOME=%JAVA_PATH%\jre7
set CLASSPATH=".;%JRE_HOME%\lib\rt.jar
set ECLIPSE_PATH=%PTK%\eclipse
set HOME=%CYGWIN_PATH%\home\%USERNAME%

mkdir %PTK%
mkdir %CYGWIN_PATH%
mkdir %JAVA_PATH%
mkdir %JAVA_HOME%
mkdir %JRE_HOME%
mkdir %ECLIPSE_PATH%
mkdir %HOME%

setx -m HOME %HOME%
setx -m PATH "%CYGWIN_PATH%\bin;%CYGWIN_PATH%\usr\bin;%CYGWIN_PATH%\usr\sbin;%CYGWIN_PATH%\usr\local\bin;%JAVA_HOME%\bin;%JRE_HOME%\bin;%PATH%"
setx -m JAVA_HOME %JAVA_HOME%
setx -m JRE_HOME %JRE_HOME%
setx -m CLASSPATH "%CLASSPATH%"
setx -m CYGWIN "binmode ntsec"

REM You can extract the PTK package to the C:\ disk now.
pause
