@echo off
chcp 65001 >nul
title Docker Desktop & Virtual Machine Platform Installer (Administrator)

:: 1. Prfe auf Administratorrechte
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ===================================================================
    echo   Fordere Administrator-Berechtigung an...
    echo ===================================================================
    echo Bitte besttigen Sie die Windows-Sicherheitsabfrage mit "JA".
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~dpnx0\"\"' -Verb RunAs"
    exit /b
)

:: 2. Ab hier luft das Skript mit vollen Administrator-Rechten:
echo ===================================================================
echo   Schritt 1: Aktiviere Windows Virtual Machine Platform
echo ===================================================================
echo Aktiviere VirtualMachinePlatform via DISM...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

echo.
echo ===================================================================
echo   Schritt 2: Aktiviere Windows Subsystem for Linux (WSL)
echo ===================================================================
echo Aktiviere Microsoft-Windows-Subsystem-Linux via DISM...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

echo.
echo ===================================================================
echo   Schritt 3: Starte Docker Desktop Installation
echo ===================================================================
set "INSTALLER=C:\Users\kevin\Downloads\Docker Desktop Installer.exe"

if not exist "%INSTALLER%" (
    echo [FEHLER] Installer nicht gefunden unter: %INSTALLER%
    pause
    exit /b 1
)

echo Fhre Docker Desktop Installer aus...
"%INSTALLER%" install --accept-license

echo.
echo ===================================================================
echo  HINWEIS ZUM NEUSTART:
echo ===================================================================
echo Wenn Windows Features neu aktiviert wurden, ist ein einmaliger
echo PC-Neustart erforderlich, damit die Virtualisierung aktiv wird.
echo.
echo Nach dem Neustart:
echo 1. Starten Sie "Docker Desktop" ber das Windows-Startmen.
echo 2. Doppelklick auf "STARTE_ISO_BUILD.bat" auf Ihrem Desktop!
echo ===================================================================
pause
