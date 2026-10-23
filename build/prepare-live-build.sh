#!/bin/bash
# ==============================================================================
# CozyHaze OS - Vorbereitungsskript für Debian live-build
# Assembliert Konfigurationen, Paketlisten, Themes und Hardware-Hooks
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== [1/6] Bereinige und erstelle Live-Build Verzeichnisstruktur ==="
mkdir -p "${PROJECT_ROOT}/config/package-lists"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/modprobe.d"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/X11/xorg.conf.d"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/grub.d"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/default/grub.d"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/systemd/system"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/lightdm"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/calamares/modules"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/lib/calamares/modules"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/skel/Desktop"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/skel/.config/gtk-3.0"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/local/sbin"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/backgrounds"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/pixmaps"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/applications"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/plymouth/themes/cozyhaze-glow"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/calamares/branding/cozyhaze"
mkdir -p "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware"
mkdir -p "${PROJECT_ROOT}/config/bootloaders/grub-pc/themes/cozyhaze"
mkdir -p "${PROJECT_ROOT}/config/hooks/live"

echo "=== [2/6] Kopiere Paketlisten & Software-Kataloge ==="
cp -f "${PROJECT_ROOT}/packages"/*.list.chroot "${PROJECT_ROOT}/config/package-lists/"
cp -f "${PROJECT_ROOT}/packages/profiles.json" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/"
cp -f "${PROJECT_ROOT}/packages/extras.json" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/"

echo "=== [3/6] Kopiere Hardware- und Treiber-Konfigurationen ==="
cp -f "${PROJECT_ROOT}/hardware/modprobe.d"/*.conf "${PROJECT_ROOT}/config/includes.chroot/etc/modprobe.d/"
cp -f "${PROJECT_ROOT}/hardware/X11"/*.conf "${PROJECT_ROOT}/config/includes.chroot/etc/X11/xorg.conf.d/"
cp -f "${PROJECT_ROOT}/hardware/grub.d/06_cozyhaze_gmux" "${PROJECT_ROOT}/config/includes.chroot/etc/grub.d/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/etc/grub.d/06_cozyhaze_gmux"
cp -f "${PROJECT_ROOT}/hardware/grub.d/cozyhaze.cfg" "${PROJECT_ROOT}/config/includes.chroot/etc/default/grub.d/"
cp -f "${PROJECT_ROOT}/hardware/systemd/macbook-tune.service" "${PROJECT_ROOT}/config/includes.chroot/etc/systemd/system/"
cp -f "${PROJECT_ROOT}/hardware/scripts/macbook-tune.sh" "${PROJECT_ROOT}/config/includes.chroot/usr/local/sbin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/sbin/macbook-tune.sh"
cp -f "${PROJECT_ROOT}/hardware/scripts/cozyhaze-postinstall" "${PROJECT_ROOT}/config/includes.chroot/usr/local/sbin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/sbin/cozyhaze-postinstall"

# Hardware-Dateien auch für das Zielsystem bereitstellen
cp -f "${PROJECT_ROOT}/hardware/modprobe.d"/*.conf "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"
cp -f "${PROJECT_ROOT}/hardware/X11"/*.conf "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"
cp -f "${PROJECT_ROOT}/hardware/grub.d/06_cozyhaze_gmux" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"
cp -f "${PROJECT_ROOT}/hardware/grub.d/cozyhaze.cfg" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"
cp -f "${PROJECT_ROOT}/hardware/scripts/macbook-tune.sh" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"
cp -f "${PROJECT_ROOT}/hardware/systemd/macbook-tune.service" "${PROJECT_ROOT}/config/includes.chroot/usr/share/cozyhaze/hardware/"

echo "=== [4/6] Kopiere Systemskripte & Desktop-Starter ==="
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-gpu-diag" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-gpu-diag"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-gpu-repair" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-gpu-repair"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-control-center" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-control-center"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-software-center" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-software-center"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-ai-center" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-ai-center"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-automation-center" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-automation-center"
cp -f "${PROJECT_ROOT}/scripts/cozyhaze-web-starter" "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/"
chmod +x "${PROJECT_ROOT}/config/includes.chroot/usr/local/bin/cozyhaze-web-starter"

for dtop in "${PROJECT_ROOT}/scripts"/*.desktop; do
    if [ -f "$dtop" ]; then
        cp -f "$dtop" "${PROJECT_ROOT}/config/includes.chroot/usr/share/applications/"
        cp -f "$dtop" "${PROJECT_ROOT}/config/includes.chroot/etc/skel/Desktop/"
    fi
done

# Calamares Starter auf den Desktop legen
cat << 'CAL_DESK' > "${PROJECT_ROOT}/config/includes.chroot/etc/skel/Desktop/calamares.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=CozyHaze OS installieren
GenericName=System Installer
Comment=CozyHaze OS dauerhaft auf SSD installieren
Exec=sh -c "pkexec calamares -d"
Icon=install-debian
Terminal=false
Categories=System;
StartupNotify=true
CAL_DESK
chmod +x "${PROJECT_ROOT}/config/includes.chroot/etc/skel/Desktop"/*.desktop

echo "=== [5/6] Kopiere Themes, Branding & Bootloader-Dateien ==="
# Wallpaper & Icons
cp -f "${PROJECT_ROOT}/themes/wallpaper"/* "${PROJECT_ROOT}/config/includes.chroot/usr/share/backgrounds/" 2>/dev/null || true
cp -f "${PROJECT_ROOT}/themes/icons"/* "${PROJECT_ROOT}/config/includes.chroot/usr/share/pixmaps/" 2>/dev/null || true

# Xfce4 Konfiguration
cp -f "${PROJECT_ROOT}/themes/gtk-3.0/gtk.css" "${PROJECT_ROOT}/config/includes.chroot/etc/skel/.config/gtk-3.0/"
cp -f "${PROJECT_ROOT}/themes/xfce4"/*.xml "${PROJECT_ROOT}/config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/"
cp -f "${PROJECT_ROOT}/themes/lightdm/lightdm-gtk-greeter.conf" "${PROJECT_ROOT}/config/includes.chroot/etc/lightdm/"

# Plymouth Theme
cp -f "${PROJECT_ROOT}/boot/plymouth/themes/cozyhaze-glow"/* "${PROJECT_ROOT}/config/includes.chroot/usr/share/plymouth/themes/cozyhaze-glow/"

# GRUB Theme & Live Bootloader
cp -f "${PROJECT_ROOT}/boot/grub/themes/cozyhaze"/* "${PROJECT_ROOT}/config/bootloaders/grub-pc/themes/cozyhaze/"
cp -f "${PROJECT_ROOT}/boot/grub/grub.cfg" "${PROJECT_ROOT}/config/bootloaders/grub-pc/"
cp -f "${PROJECT_ROOT}/boot/grub/live.cfg" "${PROJECT_ROOT}/config/bootloaders/grub-pc/"

# Calamares Konfiguration & Branding
cp -f "${PROJECT_ROOT}/installer/settings.conf" "${PROJECT_ROOT}/config/includes.chroot/etc/calamares/"
cp -f "${PROJECT_ROOT}/installer/modules"/*.conf "${PROJECT_ROOT}/config/includes.chroot/etc/calamares/modules/"
cp -rf "${PROJECT_ROOT}/installer/calamares-modules"/* "${PROJECT_ROOT}/config/includes.chroot/usr/lib/calamares/modules/"
cp -rf "${PROJECT_ROOT}/installer/branding/cozyhaze"/* "${PROJECT_ROOT}/config/includes.chroot/usr/share/calamares/branding/cozyhaze/"

echo "=== [6/6] Erstelle Live-Build Chroot Setup Hook ==="
cat << 'HOOK_EOF' > "${PROJECT_ROOT}/config/hooks/live/01-cozyhaze-setup.hook.chroot"
#!/bin/sh
set -e

echo "=== CozyHaze Live-Build Hook: System-Initialisierung ==="

# 1. Berechtigungen für Desktop-Starter & CozyHaze Share-Verzeichnis setzen
chmod -R 755 /etc/skel/Desktop 2>/dev/null || true
chmod -R 755 /usr/share/cozyhaze 2>/dev/null || true

# 2. Plymouth Bootsplash aktivieren
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    plymouth-set-default-theme -R cozyhaze-glow || true
fi

# 3. Systemd Services aktivieren
systemctl enable macbook-tune.service 2>/dev/null || true
systemctl enable fstrim.timer 2>/dev/null || true
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl enable lightdm.service 2>/dev/null || true
systemctl enable apparmor.service 2>/dev/null || true

# 4. Standard-Sicherheitsarchitektur: UFW Firewall aktivieren & SSH-Server deaktivieren
if command -v ufw >/dev/null 2>&1; then
    ufw default deny incoming 2>/dev/null || true
    ufw default allow outgoing 2>/dev/null || true
    ufw enable 2>/dev/null || true
    systemctl enable ufw.service 2>/dev/null || true
fi

# SSH Server standardmäßig inaktiv halten (keine offenen Ports ab Werk)
systemctl disable ssh.service 2>/dev/null || true
systemctl disable sshd.service 2>/dev/null || true

# 5. Wireshark/Dumpcap Berechtigungen ohne Root konfigurieren
if command -v setcap >/dev/null 2>&1 && [ -f /usr/bin/dumpcap ]; then
    setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap 2>/dev/null || true
fi

# 6. Standard-Shell & User-Gruppen für Live-User
if [ -f /etc/default/useradd ]; then
    sed -i 's/SHELL=.*/SHELL=\/bin\/bash/' /etc/default/useradd
fi

# 7. Flatpak Flathub Repository vorkonfigurieren (ohne Netzwerkfehler)
if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
fi

# 8. Sudoers-Rechte für Live-Benutzer ohne Passwort
echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/live-users
chmod 0440 /etc/sudoers.d/live-users

echo "=== CozyHaze Live-Build Hook abgeschlossen ==="
HOOK_EOF
chmod +x "${PROJECT_ROOT}/config/hooks/live/01-cozyhaze-setup.hook.chroot"

echo "=== Live-Build Vorbereitung erfolgreich abgeschlossen! ==="
exit 0

