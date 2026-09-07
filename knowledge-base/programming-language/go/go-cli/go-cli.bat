@echo off
echo go project initializer ...

set projName=%1

:INPUT_PROJECT_NAME
if "%projName%" == "" (
    echo please input project name which match regex : [a-zA-Z0-9_.]+
    set /p projName=
    goto INPUT_PROJECT_NAME
)

echo go project [%projName%] initializing ...

echo build go mod %projName%...
mkdir %projName%
cd %projName%
go mod init %projName%

echo make %projName%/main.go ...
echo package main > main.go
echo import "fmt" >> main.go
echo func main() { >> main.go
echo     fmt.Println("hello") >> main.go
echo } >> main.go

echo make %projName%/readme.md ...
echo # %projName% > readme.md
echo ----------------------------------- >> readme.md

echo make %projName%/run.bat ...
echo @echo off > run.bat
echo echo project running ... >> run.bat
echo go run main.go >> run.bat
echo echo project exit. >> run.bat
echo pause >> run.bat

echo make %projName%/build.bat ...
echo @echo off > build.bat
echo echo project building ... >> build.bat
echo go build main.go >> build.bat
echo echo build exit. >> build.bat
echo echo to run main.exe >> build.bat
echo pause >> build.bat

cd ..

echo initialied project [%projName%]
echo to run project [%projName%]
echo     cd %projName%
echo     run.bat

echo initialied done.