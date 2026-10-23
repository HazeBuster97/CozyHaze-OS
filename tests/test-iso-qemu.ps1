<#
.SYNOPSIS
    CozyHaze OS - QEMU UEFI Boottest unter Windows
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$IsoPath = Join-Path $ProjectRoot "output\cozyhaze-os-2026.10-macbookpro82-amd64.iso"

if (-not (Test-Path $IsoPath)) {
    Write-Warning "Keine ISO-Datei gefunden unter: $IsoPath"
    Write-Host "Bitte erstellen Sie die ISO zuerst mit der Build-Pipeline."
    exit 1
}

$QemuCmd = Get-Command "qemu-system-x86_64.exe" -ErrorAction SilentlyContinue
if (-not $QemuCmd) {
    Write-Warning "qemu-system-x86_64.exe nicht im PATH gefunden. (Installation via 'winget install SoftwareFreedomConservancy.QEMU' möglich)."
    exit 1
}

Write-Host "=== Starte CozyHaze OS in QEMU (Windows) ===" -ForegroundColor Cyan
& qemu-system-x86_64.exe -m 4096 -smp 4 -cdrom $IsoPath -boot d -vga std -name "CozyHaze OS Test-VM"
