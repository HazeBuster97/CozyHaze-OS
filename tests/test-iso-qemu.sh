#!/bin/bash
# ==============================================================================
# CozyHaze OS - QEMU UEFI Boottest
# Bootet die erstellte Hybrid-ISO mit OVMF (UEFI Firmware) in einer virtuellen Maschine
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ISO_PATH="${PROJECT_ROOT}/output/cozyhaze-os-2026.10-macbookpro82-amd64.iso"

if [ ! -f "$ISO_PATH" ]; then
    echo "[!] Keine ISO-Datei gefunden unter: $ISO_PATH"
    echo "    Bitte führen Sie zuerst 'sudo ./build/build-iso.sh' aus."
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "[!] qemu-system-x86_64 nicht gefunden. Bitte installieren mit:"
    echo "    sudo apt-get install qemu-system-x86 ovmf"
    exit 1
fi

# OVMF Firmware suchen
OVMF_CODE="/usr/share/OVMF/OVMF_CODE.fd"
if [ ! -f "$OVMF_CODE" ]; then
    OVMF_CODE="/usr/share/ovmf/OVMF.fd"
fi

echo "=== Starte CozyHaze OS in QEMU mit UEFI (OVMF) ==="
echo "ISO: $ISO_PATH"
echo "RAM: 4096 MB, CPU-Kerne: 4"

qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -cpu host \
    -bios "$OVMF_CODE" \
    -cdrom "$ISO_PATH" \
    -boot d \
    -vga std \
    -net nic -net user \
    -name "CozyHaze OS Test-VM"
