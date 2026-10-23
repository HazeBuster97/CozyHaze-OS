#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CozyHaze OS Ultimate - Vorbereitungsskript für live-build (Python 3)
Assembliert Konfigurationen, Paketlisten, Themes und Hardware-Hooks
vollständig plattformunabhängig (Windows, Linux, macOS).
"""

import os
import shutil
import glob

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))
CONFIG_DIR = os.path.join(PROJECT_ROOT, "config")

def main():
    print("=== [1/6] Erstelle live-build Verzeichnisstruktur ===")
    dirs = [
        "package-lists",
        "includes.chroot/etc/modprobe.d",
        "includes.chroot/etc/X11/xorg.conf.d",
        "includes.chroot/etc/grub.d",
        "includes.chroot/etc/default/grub.d",
        "includes.chroot/etc/systemd/system",
        "includes.chroot/etc/lightdm",
        "includes.chroot/etc/calamares/modules",
        "includes.chroot/usr/lib/calamares/modules",
        "includes.chroot/etc/skel/Desktop",
        "includes.chroot/etc/skel/.config/gtk-3.0",
        "includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml",
        "includes.chroot/usr/local/bin",
        "includes.chroot/usr/local/sbin",
        "includes.chroot/usr/share/backgrounds",
        "includes.chroot/usr/share/pixmaps",
        "includes.chroot/usr/share/applications",
        "includes.chroot/usr/share/plymouth/themes/cozyhaze-glow",
        "includes.chroot/usr/share/calamares/branding/cozyhaze",
        "includes.chroot/usr/share/cozyhaze/hardware",
        "bootloaders/grub-pc/themes/cozyhaze",
        "hooks/live"
    ]
    for d in dirs:
        os.makedirs(os.path.join(CONFIG_DIR, d), exist_ok=True)

    print("=== [2/6] Kopiere Paketlisten & Software-Kataloge ===")
    for f in glob.glob(os.path.join(PROJECT_ROOT, "packages", "*.list.chroot")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "package-lists"))
    shutil.copy2(os.path.join(PROJECT_ROOT, "packages", "profiles.json"),
                 os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze"))
    shutil.copy2(os.path.join(PROJECT_ROOT, "packages", "extras.json"),
                 os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze"))

    print("=== [3/6] Kopiere Hardware- und Treiber-Konfigurationen ===")
    for f in glob.glob(os.path.join(PROJECT_ROOT, "hardware", "modprobe.d", "*.conf")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "modprobe.d"))
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    for f in glob.glob(os.path.join(PROJECT_ROOT, "hardware", "X11", "*.conf")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "X11", "xorg.conf.d"))
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    gmux = os.path.join(PROJECT_ROOT, "hardware", "grub.d", "06_cozyhaze_gmux")
    shutil.copy2(gmux, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "grub.d"))
    shutil.copy2(gmux, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    cfg = os.path.join(PROJECT_ROOT, "hardware", "grub.d", "cozyhaze.cfg")
    shutil.copy2(cfg, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "default", "grub.d"))
    shutil.copy2(cfg, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    tune_svc = os.path.join(PROJECT_ROOT, "hardware", "systemd", "macbook-tune.service")
    shutil.copy2(tune_svc, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "systemd", "system"))
    shutil.copy2(tune_svc, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    tune_sh = os.path.join(PROJECT_ROOT, "hardware", "scripts", "macbook-tune.sh")
    shutil.copy2(tune_sh, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "local", "sbin"))
    shutil.copy2(tune_sh, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "cozyhaze", "hardware"))

    postinst = os.path.join(PROJECT_ROOT, "hardware", "scripts", "cozyhaze-postinstall")
    shutil.copy2(postinst, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "local", "sbin"))

    print("=== [4/6] Kopiere Systemskripte & Desktop-Starter ===")
    scripts = [
        "cozyhaze-gpu-diag",
        "cozyhaze-gpu-repair",
        "cozyhaze-control-center",
        "cozyhaze-software-center",
        "cozyhaze-ai-center",
        "cozyhaze-automation-center",
        "cozyhaze-web-starter"
    ]
    for s in scripts:
        src = os.path.join(PROJECT_ROOT, "scripts", s)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "local", "bin"))

    for dtop in glob.glob(os.path.join(PROJECT_ROOT, "scripts", "*.desktop")):
        shutil.copy2(dtop, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "applications"))
        shutil.copy2(dtop, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "skel", "Desktop"))

    # Calamares Starter auf den Desktop legen
    cal_desk_content = """[Desktop Entry]
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
"""
    with open(os.path.join(CONFIG_DIR, "includes.chroot", "etc", "skel", "Desktop", "calamares.desktop"), "w", encoding="utf-8") as f:
        f.write(cal_desk_content)

    print("=== [5/6] Kopiere Themes, Branding & Bootloader-Dateien ===")
    for f in glob.glob(os.path.join(PROJECT_ROOT, "themes", "wallpaper", "*")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "backgrounds"))

    for f in glob.glob(os.path.join(PROJECT_ROOT, "themes", "icons", "*")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "pixmaps"))

    gtk_css = os.path.join(PROJECT_ROOT, "themes", "gtk-3.0", "gtk.css")
    if os.path.exists(gtk_css):
        shutil.copy2(gtk_css, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "skel", ".config", "gtk-3.0"))

    for f in glob.glob(os.path.join(PROJECT_ROOT, "themes", "xfce4", "*.xml")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "skel", ".config", "xfce4", "xfconf", "xfce-perchannel-xml"))

    lightdm_conf = os.path.join(PROJECT_ROOT, "themes", "lightdm", "lightdm-gtk-greeter.conf")
    if os.path.exists(lightdm_conf):
        shutil.copy2(lightdm_conf, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "lightdm"))

    # Plymouth Theme
    for f in glob.glob(os.path.join(PROJECT_ROOT, "boot", "plymouth", "themes", "cozyhaze-glow", "*")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "plymouth", "themes", "cozyhaze-glow"))

    # GRUB Theme & Live Bootloader
    for f in glob.glob(os.path.join(PROJECT_ROOT, "boot", "grub", "themes", "cozyhaze", "*")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "bootloaders", "grub-pc", "themes", "cozyhaze"))

    for f in ["grub.cfg", "live.cfg"]:
        src = os.path.join(PROJECT_ROOT, "boot", "grub", f)
        if os.path.exists(src):
            shutil.copy2(src, os.path.join(CONFIG_DIR, "bootloaders", "grub-pc"))

    # Calamares Konfiguration & Branding
    shutil.copy2(os.path.join(PROJECT_ROOT, "installer", "settings.conf"),
                 os.path.join(CONFIG_DIR, "includes.chroot", "etc", "calamares"))

    for f in glob.glob(os.path.join(PROJECT_ROOT, "installer", "modules", "*.conf")):
        shutil.copy2(f, os.path.join(CONFIG_DIR, "includes.chroot", "etc", "calamares", "modules"))

    cal_mods_dir = os.path.join(PROJECT_ROOT, "installer", "calamares-modules")
    if os.path.exists(cal_mods_dir):
        for item in os.listdir(cal_mods_dir):
            s = os.path.join(cal_mods_dir, item)
            d = os.path.join(CONFIG_DIR, "includes.chroot", "usr", "lib", "calamares", "modules", item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    cal_brand_dir = os.path.join(PROJECT_ROOT, "installer", "branding", "cozyhaze")
    if os.path.exists(cal_brand_dir):
        for item in os.listdir(cal_brand_dir):
            s = os.path.join(cal_brand_dir, item)
            d = os.path.join(CONFIG_DIR, "includes.chroot", "usr", "share", "calamares", "branding", "cozyhaze", item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    print("=== [6/6] Erstelle Live-Build Chroot Setup Hook ===")
    hook_content = r"""#!/bin/sh
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
"""
    hook_file = os.path.join(CONFIG_DIR, "hooks", "live", "01-cozyhaze-setup.hook.chroot")
    with open(hook_file, "w", encoding="utf-8", newline="\n") as f:
        f.write(hook_content)

    print("=== Live-Build Vorbereitung erfolgreich abgeschlossen! ===")

if __name__ == "__main__":
    main()
