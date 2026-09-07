@echo off
:: %需要转义
set esc_per=%%

set bak_file=%1
:: 获取完整路径
for %%a in (%bak_file%) do set bak_file=%%~fa

set _recoverys_ret_path=%cd%
cd .\mysql8\bin
call rec.bat %bak_file%
cd %_recoverys_ret_path%
