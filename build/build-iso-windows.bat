@echo off
chcp 65001 >nul
title CozyHaze OS Ultimate - Automatischer ISO-Builder

set "PROJECT_DIR=C:\Users\kevin\.gemini\antigravity-ide\scratch\CozyHaze-OS"
set "PATH=C:\Users\kevin\AppData\Local\Programs\DockerDesktop\resources\bin;%PATH%"
cd /d "%PROJECT_DIR%"

echo ===================================================================
echo       COZYHAZE OS ULTIMATE - AUTOMATISCHER ISO BUILDER
echo ===================================================================
echo.

:CHECK_DOCKER
echo [1/3] Prfe Docker-Status...
docker info >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Docker luft und ist einsatzbereit!
    goto BUILD
)

echo.
echo [HINWEIS] Docker luft aktuell noch nicht auf diesem PC.
echo.
echo Wenn Sie Docker Desktop noch NICHT installiert haben:
echo  - Der Installer liegt bereits fertig heruntergeladen in Ihrem Downloads-Ordner:
echo    "C:\Users\kevin\Downloads\Docker Desktop Installer.exe"
echo  - Fhren Sie ihn einfach per Doppelklick aus (WSL2-Option aktivieren).
echo.
echo Wenn Docker Desktop bereits installiert ist:
echo  - Starten Sie einfach "Docker Desktop" ber das Windows-Startmen.
echo.
echo Sobald Docker Desktop luft, drcken Sie eine beliebige Taste, um fortzufahren...
pause >nul
goto CHECK_DOCKER

:BUILD
echo.
echo ===================================================================
echo [2/3] Baue isolierten Debian 13 Live-Build Container...
echo ===================================================================
docker build -t cozyhaze-builder -f build/Dockerfile.builder .
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [FEHLER] Docker Build fehlgeschlagen. Bitte prfen Sie die Docker-Ausgabe.
    pause
    exit /b 1
)

echo.
echo ===================================================================
echo [3/3] Kompiliere bootfhige CozyHaze OS Ultimate Hybrid-ISO...
echo ===================================================================
echo Dies ldt Debian 13 Basispakete herunter und erzeugt die SquashFS-ISO.
echo Bitte haben Sie etwas Geduld...
echo.

docker run --privileged -v "%CD%:/workspace" cozyhaze-builder /workspace/build/build-iso.sh
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [FEHLER] ISO-Erstellung im Container fehlgeschlagen.
    pause
    exit /b 1
)

echo.
echo ===================================================================
echo  ERFOLG: CozyHaze OS Ultimate ISO wurde erfolgreich erstellt!
echo ===================================================================
echo Speicherort: %CD%\output
echo.
explorer "%CD%\output"
pause
