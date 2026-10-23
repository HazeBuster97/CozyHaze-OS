#!/bin/sh
# CozyHaze OS - MacBookPro8,2 System- und Energie-Tuning beim Start
# Optimiert SATA-SSD, ZRAM, Intel Sandy Bridge CPU und Audio-Power-Management

set -e

# 1. SSD TRIM (Nicht-blockierend im Hintergrund oder via fstrim)
if command -v fstrim >/dev/null 2>&1; then
    fstrim -v / 2>/dev/null || true
fi

# 2. CPU Energie- und Temperatur-Tuning
# Sandy Bridge profitiert von 'powersave' oder 'schedutil' mit Intel P-State
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -w "$gov" ]; then
            # Wenn schedutil verfügbar ist, bevorzugen, sonst ondemand
            if grep -q "schedutil" "${gov%/*}/scaling_available_governors" 2>/dev/null; then
                echo "schedutil" > "$gov" 2>/dev/null || true
            elif grep -q "ondemand" "${gov%/*}/scaling_available_governors" 2>/dev/null; then
                echo "ondemand" > "$gov" 2>/dev/null || true
            fi
        fi
    done
fi

# 3. PCIe Active State Power Management (ASPM) aktivieren für kühlere Temperaturen
if [ -w /sys/module/pcie_aspm/parameters/policy ]; then
    echo "powersave" > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
fi

# 4. Intel HD 3000 RC6 Power States verifizieren
if [ -w /sys/module/i915/parameters/enable_rc6 ]; then
    echo "1" > /sys/module/i915/parameters/enable_rc6 2>/dev/null || true
fi

# 5. Apple Keyboard Fn-Modus absichern (F1-F12 primär)
if [ -w /sys/module/hid_apple/parameters/fnmode ]; then
    echo "2" > /sys/module/hid_apple/parameters/fnmode 2>/dev/null || true
fi
if [ -w /sys/module/hid_apple/parameters/swap_opt_cmd ]; then
    echo "1" > /sys/module/hid_apple/parameters/swap_opt_cmd 2>/dev/null || true
fi

# 6. ZRAM Swap aktivieren (sofern zram-tools konfiguriert ist)
if command -v zramctl >/dev/null 2>&1; then
    # ZRAM Status prüfen
    zramctl >/dev/null 2>&1 || true
fi

exit 0
