@echo off
chcp 65001 >nul
title CozyHaze OS - Cloud ISO-Builder (GitHub Actions)

set "PROJECT_DIR=C:\Users\kevin\.gemini\antigravity-ide\scratch\CozyHaze-OS"
set "GIT_PATH=C:\Users\kevin\AppData\Local\Microsoft\WinGet\Packages\Git.MinGit_Microsoft.Winget.Source_8wekyb3d8bbwe\cmd"
set "GH_PATH=C:\Users\kevin\AppData\Local\Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\bin"
set "PATH=%GIT_PATH%;%GH_PATH%;%PATH%"

cd /d "%PROJECT_DIR%"

echo ===================================================================
echo     COZYHAZE OS ULTIMATE - CLOUD ISO BUILDER (GITHUB ACTIONS)
echo ===================================================================
echo.
echo Dieser Assistent laedt das Projekt auf Ihren GitHub-Account hoch
echo und startet den automatischen ISO-Build in der Cloud.
echo.
echo Vorteile:
echo  - Kein lokales Docker / WSL erforderlich
echo  - Keine BIOS-Aenderung am PC noetig
echo  - 100%% kostenloser Cloud-Build auf schnellen Ubuntu-Servern
echo ===================================================================
echo.

:CHECK_AUTH
echo [1/4] Pruefe GitHub-Anmeldung...
gh auth status >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Bei GitHub angemeldet!
    goto CREATE_REPO
)

echo.
echo [HINWEIS] Sie sind noch nicht mit GitHub angemeldet.
echo Es oeffnet sich gleich ein Browser-Fenster zur einmaligen Bestaetigung.
echo.
echo Druecken Sie eine beliebige Taste, um sich im Browser anzumelden...
pause >nul
echo Starte Web-Login...
gh auth login --web -p https
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [FEHLER] Anmeldung fehlgeschlagen oder abgebrochen.
    pause
    exit /b 1
)

:CREATE_REPO
echo.
echo [2/4] Bereite GitHub-Repository vor...
git remote get-url origin >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Remote 'origin' bereits vorhanden. Synchronisiere Code...
    git push -u origin main
    goto TRIGGER_BUILD
)

echo Erstelle neues Repository 'CozyHaze-OS' auf Ihrem GitHub-Account...
gh repo create CozyHaze-OS --public --source=. --remote=origin --push
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Versuche Push zum bestehenden Origin...
    git push -u origin main
)

:TRIGGER_BUILD
echo.
echo [3/4] Starte ISO-Build Workflow in GitHub Actions...
gh workflow run build-iso.yml 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Cloud-Build erfolgreich angestossen!
) else (
    echo [OK] Workflow wird durch den Push automatisch gestartet.
)

echo.
echo [4/4] Oeffne GitHub Actions im Webbrowser...
echo Der Build dauert ca. 10-15 Minuten. Sie koennen den Fortschritt live
echo im Browser verfolgen und die fertige ISO dort mit 1 Klick herunterladen!
echo.
gh browse --actions

echo ===================================================================
echo Fertig! Das Browser-Fenster mit dem Live-Build wurde geoeffnet.
echo ===================================================================
pause
