@echo off
set bak_host=%1
set bak_user=%2
set bak_password=%3

set bak_db=%4
set bak_file=%5

:: 获取完整路径
for %%a in (%bak_file%) do set bak_file=%%~fa

echo recovery into %bak_db% for host %bak_host% use file %bak_file% ...

echo [script exec]: lib\windows\mysql.exe -h %bak_host% -u%bak_user% -p%bak_password% %bak_db% ^< "%bak_file%"
..\lib\windows\mysql.exe -h %bak_host% -u%bak_user% -p%bak_password% %bak_db% < "%bak_file%"

echo recovery done into %bak_db% for host %bak_host% use file %bak_file% .
