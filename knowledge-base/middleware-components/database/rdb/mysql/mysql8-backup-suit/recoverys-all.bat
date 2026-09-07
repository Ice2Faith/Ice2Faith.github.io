@echo off
:: %需要转义
set esc_per=%%

set bak_dir=%1
:: 获取完整路径
for %%a in (%bak_dir%) do set bak_dir=%%~fa

set _recoverys_ret_path=%cd%
cd .\mysql8\bin

for /r %bak_dir% %%a in ("*.sql") do (
    echo call rec.bat %%~fa
    call rec.bat %%~fa
)

cd %_recoverys_ret_path%
