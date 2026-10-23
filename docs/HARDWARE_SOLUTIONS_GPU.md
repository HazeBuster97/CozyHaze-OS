# Technische Hardware-Lösung: Defekte AMD GPU & Intel HD 3000 Umschaltung
**Detaillierte Dokumentation für Apple MacBook Pro 15" (MacBookPro8,2 – A1286, 2011)**

---

## 1. Problemstellung: Der AMD-GPU-Hardwaredefekt (Radeongate)

Das 15"- und 17"-MacBook Pro aus dem Jahr 2011 (`MacBookPro8,2` und `MacBookPro8,3`) besitzt zwei Grafikeinheiten:
1. **Integrierte GPU (iGPU)**: Intel HD Graphics 3000 (im Intel Sandy Bridge Core i5/i7 Prozessor integriert).
2. **Dedizierte GPU (dGPU)**: AMD Radeon HD 6490M / 6750M / 6770M.

### Die Ursache des Ausfalls:
Durch thermische Wechselbelastungen und das damals verwendete bleifreie BGA-Lot ermüden die Lötverbindungen unter dem AMD-Grafikchip nach einigen Betriebsjahren. Dies führt zu:
- Streifenbildung, Artefakten und Grafikfehlern.
- Einfrieren des Systems beim Initialisieren des AMD-Grafiktreibers.
- Dauerschleifen mit grauem oder schwarzem Bildschirm beim Startvorgang.
- Kernel-Panics (`radeon: fatal error initializing`).

---

## 2. Der Apple GMUX Multiplexer: Warum Treiber-Blacklisting allein nicht reicht

Auf normalen PCs schaltet der Treiber die Grafikkarten um. Bei Apple-MacBooks dieser Generation existiert jedoch ein dedizierter Hardware-Chip: der **Apple GMUX** (ein programmierter FPGA / Mikrocontroller).

> [!WARNING]
> **Kritische Erkenntnis**:
> Eine reine Treiber-Blacklist (`blacklist radeon` in `/etc/modprobe.d/`) verhindert lediglich, dass Linux den Treiber für die AMD-Karte lädt. **Sie schaltet jedoch die Hardware-Verdrahtung des internen Displays (LVDS) nicht auf die Intel-Grafik um!**
> Die Apple-Firmware schaltet den GMUX beim Booten standardmäßig auf die AMD-Karte. Wird nun der Treiber blockiert, bleibt der Bildschirm schwarz, da das Display weiterhin auf das tote Signal der stromlosen AMD-Karte geschaltet ist.

---

## 3. Die CozyHaze OS Dual-Ebenen-Lösung

CozyHaze OS löst das Problem auf zwei ineinandergreifenden Ebenen:

### Ebene 1: Hardware-Multiplexing via GRUB I/O-Ports (`outb`)
Direkt im Bootloader – noch bevor der Linux-Kernel den ersten Treiber lädt – sendet GRUB rohe Byte-Befehle direkt an die I/O-Register des Apple GMUX-Controllers:

```grub
outb 0x728 1    # Schaltet das interne LVDS-Display auf die Intel HD 3000 iGPU
outb 0x710 2    # Konfiguriert die GMUX Betriebsspannung
outb 0x740 2    # Konfiguriert den GMUX Energiestatus
outb 0x750 0    # Trennt die Stromversorgung der defekten AMD Radeon dGPU vollständig
```

**Ergebnis**:
- Die defekte Radeon-Karte wird komplett abgeschaltet (spart bis zu 15–20 Watt Strom, das MacBook bleibt kühl und der Akku hält deutlich länger).
- Das interne Display erhält sofort das Bildsignal der funktionierenden Intel HD 3000.
- Dieser Vorgang greift selbst dann, wenn die EFI-Variablen gelöscht wurden (z.B. nach einem PRAM-Reset).

### Ebene 2: Dauerhafte Apple EFI NVRAM-Variable (`gpu-power-prefs`)
Auf Firmware-Ebene wertet das Apple-EFI beim Einschalten die NVRAM-Variable `gpu-power-prefs` aus:
- GUID: `fa4ce28d-b62f-4c99-9cc3-6815686e30f9`
- Pfad unter Linux: `/sys/firmware/efi/efivars/gpu-power-prefs-fa4ce28d-b62f-4c99-9cc3-6815686e30f9`

**Wertbelegung**:
- `\x07\x00\x00\x00\x01\x00\x00\x00`: Erzwingt bereits ab Firmware-Start die Intel HD 3000 (`0x01`).
- `\x07\x00\x00\x00\x00\x00\x00\x00`: Apple Standard (Aktiviert die defekte AMD dGPU, Wert `0x00`).

---

## 4. Die CozyHaze Systemwerkzeuge

### 4.1 `cozyhaze-gpu-diag` (Hardware-Diagnose)
Führen Sie im Terminal oder über das Kontrollzentrum aus:
```bash
cozyhaze-gpu-diag
```
Liefert einen vollständigen Statusbericht:
- Erkennt, ob das System ein verifiziertes `MacBookPro8,2` ist.
- Zeigt aktive PCI-Geräte (Intel 8086:0116 / 8086:0126 vs. AMD 1002:6741 / 1002:6760).
- Prüft die Kernelmodule (`i915` geladen, `radeon` gesperrt).
- Prüft das Apple Backlight und den Zustand der EFI-Variable.

### 4.2 `cozyhaze-gpu-repair` (Interaktives Reparaturwerkzeug)
Starten mit:
```bash
sudo cozyhaze-gpu-repair
```
**Sicherheitsmerkmale**:
1. **Automatisches Backup**: Sichert vor jedem Schreibvorgang die existierenden EFI-Variablen nach `/var/backups/cozyhaze-efivars/`.
2. **Explizite Bestätigung**: Keine automatische Modifikation; der Benutzer muss ausdrücklich mit `JA` bestätigen.
3. **Schreibschutz-Entfernung**: Verwendet `chattr -i`, schreibt den 8-Byte-Payload und verifiziert das 5. Byte (`0x01`).
4. **Wiederherstellungsfunktion**: Erlaubt das Einspielen beliebiger früherer Backups mit einem Klick.
5. **Update-Sicherheit**: Verankert den GMUX-Hook in `/etc/grub.d/06_cozyhaze_gmux`, sodass auch zukünftige Kernel-Updates (`update-grub`) die Intel-Konfiguration niemals überschreiben.

---

## 5. Notfallanleitung: Rettung bei schwarzem Bildschirm

Falls das MacBook nach einem Hardware-Eingriff oder einem Apple-Firmware-Reset (PRAM/NVRAM) mit einem schwarzen Bildschirm startet:

### Methode 1: Rettungsboot mit `nomodeset`
1. Starten Sie das MacBook.
2. Drücken Sie im CozyHaze Bootmenü die Taste **[E]** auf dem ersten Eintrag.
3. Hängen Sie an das Ende der `linux`-Zeile an: `nomodeset radeon.modeset=0`
4. Drücken Sie **[F10]** oder **[Strg]+[X]**. Das System bootet über die CPU und erlaubt die Reparatur via `cozyhaze-gpu-repair`.

### Methode 2: Direktschaltung in der GRUB-Kommandozeile
1. Drücken Sie im GRUB-Menü die Taste **[C]** für die Befehlszeile.
2. Geben Sie folgende vier Befehle ein:
   ```text
   outb 0x728 1
   outb 0x710 2
   outb 0x740 2
   outb 0x750 0
   ```
3. Tippen Sie `exit` ein, um zum Menü zurückzukehren, und starten Sie CozyHaze OS normal.

### Wichtiger Hinweis zu externen Monitoren
Der Mini-DisplayPort / Thunderbolt-Port des MacBookPro8,2 ist hardwareseitig fest mit den Leiterbahnen der diskreten AMD Radeon verlötet. Durch das Abschalten der AMD-Karte kann dieser Port für Bildschirme nicht mehr genutzt werden.
**Lösung für externe Monitore**: USB-Grafikadapter auf DisplayLink-Basis (z.B. Dell, StarTech, Plugable), die über den USB-2.0-Port des MacBooks angeschlossen werden.
