@echo off

set bak_table=%1

set bak_dir=%2

:: 获取完整路径
for %%a in (%bak_dir%) do set bak_dir=%%~fa

:: 在此处配置MySQL的连接信息
set bak_host=
set bak_user=
set bak_password=
set bak_db=

:: 如果没有在此处配置连接信息，则从配置文件中读取
if "%bak_host%" == "" (
    for /f "delims=" %%i in ('type ..\conf\host.conf') do (
    set bak_host=%%i
    )
)

if "%bak_user%" == "" (
    for /f "delims=" %%i in ('type ..\conf\user.conf') do (
    set bak_user=%%i
    )
)

if "%bak_password%" == "" (
    for /f "delims=" %%i in ('type ..\conf\password.conf') do (
    set bak_password=%%i
    )
)

if "%bak_db%" == "" (
    for /f "delims=" %%i in ('type ..\conf\database.conf') do (
    set bak_db=%%i
    )
)

set _bak_ret_path=%cd%
cd ..\sbin
echo [script exec]: call sbin\backup.bat %bak_host% %bak_user% %bak_password% %bak_db% %bak_table% "%bak_dir%"
call backup.bat %bak_host% %bak_user% %bak_password% %bak_db% %bak_table% "%bak_dir%"
cd %_bak_ret_path%