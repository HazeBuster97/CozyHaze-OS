# Installationsanleitung: CozyHaze OS
**Spezialisiert für Apple MacBook Pro 15" (2011 – Modell MacBookPro8,2)**

---

## 1. Vorbereitung & Voraussetzungen

### 1.1 Benötigte Hardware
- **Zielrechner**: Apple MacBook Pro 15 Zoll (Frühjahr/Spät 2011, `MacBookPro8,2` oder 17" `MacBookPro8,3`).
- **USB-Stick**: Mindestens 8 GB Speicherkapazität (USB 2.0 oder 3.0).
- **Netzteil**: Schließen Sie das MagSafe-Netzteil während der gesamten Installation an.

> [!IMPORTANT]
> **Datensicherung**: Sichern Sie vor Beginn alle wichtigen persönlichen Daten auf einer externen Festplatte oder Cloud-Speicher. Eine Betriebssystem-Installation birgt immer das Risiko von Datenverlust bei fehlerhafter Partitionsauswahl.

---

## 2. Erstellen des bootfähigen USB-Sticks

### Option A: Grafisch mit Balena Etcher oder Raspberry Pi Imager
1. Laden Sie die erstellte ISO `cozyhaze-os-2026.10-macbookpro82-amd64.iso` herunter.
2. Öffnen Sie [Balena Etcher](https://etcher.balena.io/).
3. Wählen Sie die CozyHaze OS ISO-Datei aus.
4. Wählen Sie Ihren USB-Stick als Ziellaufwerk.
5. Klicken Sie auf **Flash!**.

### Option B: Unter Linux / macOS via Terminal (`dd`)
```bash
# Ermitteln Sie die Laufwerksbezeichnung (z.B. /dev/sdb unter Linux oder /dev/disk2 unter macOS)
lsblk  # Linux
diskutil list  # macOS

# Schreiben der ISO (Beispiel Linux; ersetzen Sie /dev/sdX durch Ihren USB-Stick):
sudo dd if=output/cozyhaze-os-2026.10-macbookpro82-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

---

## 3. Booten auf dem MacBook Pro 2011

1. Schalten Sie das MacBook Pro vollständig aus.
2. Stecken Sie den USB-Stick in einen USB-Port des MacBooks.
3. Halten Sie die **[Alt / Option]**-Taste auf der Tastatur gedrückt und schalten Sie das MacBook ein.
4. Halten Sie die Taste gedrückt, bis der Apple-Bootmanager erscheint.
5. Wählen Sie das gelbe Laufwerkssymbol mit dem Namen **EFI Boot** aus und drücken Sie `[Enter]`.

### Bootmenü-Auswahl:
Im CozyHaze OS GRUB-Bootmenü haben Sie folgende Optionen:
- **`CozyHaze OS Live starten (Intel HD 3000 Standard)`**: Der empfohlene Standardstart. GRUB schaltet über I/O-Portbefehle die Display-Bridge sofort auf die Intel HD 3000 um und trennt die Stromversorgung der defekten Radeon GPU.
- **`CozyHaze OS im sicheren Grafikmodus (nomodeset)`**: Startet mit CPU-Software-Rendering, falls das Display hängen bleibt.
- **`Intel-Grafikdiagnose & Hardware-Status`**: Führt direkt einen Hardware-Check der Grafikkarten und Apple-GMUX-Register durch.
- **`CozyHaze OS installieren`**: Startet das Live-System und öffnet unmittelbar den Calamares Installer.

---

## 4. Installation mit dem Calamares Installer

1. Auf dem Desktop finden Sie das Symbol **`CozyHaze OS installieren`**. Doppelklicken Sie darauf.
2. **Willkommen & Sprache**: Die deutsche Sprache und Tastaturbelegung sind bereits standardmäßig vorausgewählt.
3. **Standort & Zeitzone**: Wählen Sie `Europa/Berlin`.
4. **Tastaturbelegung**: Standard `Deutsch` (Apple MacBook kompatibel).
5. **Partitionierung**:
   - **Ganze Festplatte löschen**: Installiert CozyHaze OS als alleiniges Betriebssystem auf der internen 512 GB SSD. Erstellt automatisch eine 512 MB EFI-Partition (`/boot/efi`) und die Root-Partition (`/`).
   - **Manuelle Partitionierung**: Ermöglicht Dual-Boot neben einer bestehenden macOS-Partition.
   - **Vollverschlüsselung (LUKS)**: Setzen Sie bei Bedarf den Haken bei *System verschlüsseln* und vergeben Sie eine sichere Passphrase.
6. **Benutzerkonto**: Erstellen Sie Ihren primären Benutzer und das Administrator-Passwort.
7. **Zusammenfassung & Sicherheitsabfrage**:
   - Calamares zeigt vor dem Schreibvorgang alle geplanten Änderungen detailliert an.
   - Erst nach Klick auf **`Jetzt installieren`** werden Partitionen formatiert.
8. **Automatischer Hardware-Hook**:
   - Während der Installation führt Calamares den Hook `cozyhaze-postinstall` aus.
   - Die GMUX-Befehle, Treiber-Blacklists und Intel HD 3000 LVDS-Parameter werden fest im installierten System und im GRUB-Bootloader verankert.
9. **Abschluss**: Starten Sie das MacBook nach Abschluss der Installation neu und entfernen Sie den USB-Stick.

---

## 5. Nachbereitung & Verifikation im installierten System

Öffnen Sie nach dem ersten Start das vorinstallierte **CozyHaze Kontrollzentrum** oder führen Sie im Terminal aus:
```bash
cozyhaze-gpu-diag
```

Prüfen Sie:
1. `i915 (Intel)` ist als aktives Modul mit Status `GELADEN` gekennzeichnet.
2. `radeon` und `amdgpu` stehen auf `GESPERRT / NICHT GELADEN`.
3. Der Akku- und Lüfterbetrieb läuft ruhig und kühl, da die defekte dGPU keine unnötige Wärme mehr erzeugt.
