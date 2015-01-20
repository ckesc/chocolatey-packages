@echo off

rem -------------------------------------------------------------
rem  ReBuild package for chocolatey.
rem -------------------------------------------------------------

@SetLocal EnableExtensions EnableDelayedExpansion

rem  Get package name.
cd ..\
for %%a in (".") do set CURRENT_DIR_NAME=%%~na
cd ./src

echo === ReInstall "%CURRENT_DIR_NAME%" package ===

set "PACKAGE_NANE=%CURRENT_DIR_NAME%"
set "SRC_DIR=%~dp0"
set "BUILD_DIR=..\build\%PACKAGE_NANE%"

cmd /C 1-build-package.bat
choco uninstall %PACKAGE_NANE%
2-test-package.bat

@endlocal