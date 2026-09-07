@echo off
:: %需要转义
set esc_per=%%

set bak_dir=.\db_backup

:: 获取完整路径
for %%a in (%bak_dir%) do set bak_dir=%%~fa

:: 表列表文件
set _tables_list_file=%cd%\tables.txt

set _backups_ret_path=%cd%
cd .\mysql8\bin

:: load from tables.txt
:: add your table names into tables.txt
:: every line is an table
for /f "delims=" %%i in (%_tables_list_file%) do (
    call bak.bat %%i %bak_dir%
)

cd %_backups_ret_path%
