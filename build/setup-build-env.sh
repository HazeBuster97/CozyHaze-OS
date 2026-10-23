#!/bin/bash
# CozyHaze OS - Vorbereitung eines Debian/Ubuntu Host-Systems für den ISO-Build

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Bitte mit sudo ausführen: sudo ./build/setup-build-env.sh"
    exit 1
fi

echo "=== Aktualisiere Paketquellen und installiere Live-Build Werkzeuge ==="
apt-get update
apt-get install -y \
    live-build \
    debootstrap \
    xorriso \
    squashfs-tools \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    python3 \
    python3-pil \
    git \
    curl \
    qemu-system-x86 \
    ovmf

echo "=== Host-System ist bereit für 'sudo ./build/build-iso.sh' ==="
exit 0
