@echo off

REM  Run sendto

REM  Run regedit
REM
REM  Open/Edit (e.g. %SystemRoot%\system32\NOTEPAD.EXE %1    or C:\WINDOWS\system32\notepad.exe %1)
REM  Print     (e.g. %SystemRoot%\system32\NOTEPAD.EXE /p %1 or C:\WINDOWS\system32\notepad.exe /p %1)
REM
:: "C:\Program Files (x86)\Vim\vim73\gvim.exe" --remote-tab-silent "%1"
:: "C:\Program Files (x86)\Vim\vim73\gvim.exe" +hardcopy "%1"

assoc .=txtfile
assoc .log=txtfile

assoc .c=sourcecode
assoc .cc=sourcecode
assoc .cpp=sourcecode
assoc .h=sourcecode
assoc .hh=sourcecode
assoc .hpp=sourcecode
assoc .java=sourcecode
assoc .cs=sourcecode
assoc .py=sourcecode
assoc .rb=sourcecode
assoc .pl=sourcecode
assoc .sh=sourcecode
assoc .vim=sourcecode
assoc .js=sourcecode
assoc .php=sourcecode
assoc .l=sourcecode
assoc .y=sourcecode

ftype sourcecode="C:\Program Files (x86)\Vim\vim73\gvim.exe" --servername CODE --remote-tab-silent "%%1"

pause
