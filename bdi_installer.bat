@echo off
chcp 65001 >nul
title BDI Installer
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorLevel% neq 0 (
    exit /b
)

if "%1"=="" goto help

set "action=%1"
set "param=%2"

if /i "%action%"=="/d" (
    if "%param%"=="" (
        goto help
    )
    call :uninstall "%param%"
    exit /b
)

if /i "%action:~0,5%"=="/ext" (
    set "fullname=%action:~6%"
    if "!fullname!"=="" (
        goto help
    )
    call :install "!fullname!"
    exit /b
)

if /i "%action%"=="/ext" (
    if "%param%"=="" (
        goto help
    )
    call :install "%param%"
    exit /b
)
goto help

:install
set "archive=%~1"
if not exist "%archive%" (
    exit /b
)

for %%f in ("%archive%") do set "osname=%%~nf"

set "targetDir=C:\Program Files\BDI\Images\%osname%"

echo [BDI-INST] Установка системы '%osname%'...

if not exist "%targetDir%" mkdir "%targetDir%"

powershell -command "Expand-Archive -Path '%archive%' -DestinationPath '%targetDir%' -Force" >nul 2>&1

if %errorLevel% equ 0 (
    echo [BDI-EXT] Установка системы прошла успешно.
) else (
    echo [BDI-EXT] Не удалось установить систему.
)
exit /b

:uninstall
set "osname=%1"
set "targetDir=C:\Program Files\BDI\Images\%osname%"

if not exist "%targetDir%" (
    exit /b
)

echo Удаление системы '%osname%'...
rd /s /q "%targetDir%"

if %errorLevel% equ 0 (
    echo [BDI-DEL] %osname% успешно удалена.
) else (
    echo [BDI-DEL] Ошибка удаления.
)
exit /b

:help
echo.
echo BDI Installer — установщик BDI-образов
echo.
echo Использование:
echo   bdi_installer.bat /ext:имя_файла.bdi   - установить ОС
echo   bdi_installer.bat /d имя_ос             - удалить ОС
echo.
echo Примеры:
echo   bdi_installer.bat /ext:OS.bdi
echo   bdi_installer.bat /d OS
echo.
pause
exit /b