# CozyHaze Control Center – Handbuch & Architektur

---

## 1. Übersicht

Das **CozyHaze Control Center** (`cozyhaze-control-center`) ist das zentrale Verwaltungs- und Diagnosewerkzeug von CozyHaze OS. Es wurde speziell für ältere Hardware und insbesondere das Apple MacBook Pro 2011 entwickelt.

### Leitprinzipien der Entwicklung:
- **Schlank & Nativ**: Entwickelt in Python 3 mit PyGObject (`GTK 3`). Nutzt direkt die nativen Xfce-Bibliotheken ohne Electron, Node.js oder WebViews.
- **Null Hintergrundlast**: Keine dauerhaft laufenden Daemon-Dienste oder Hintergrundprozesse. Abfragen (DMI, PCI, EFI, CPU) werden erst beim Öffnen des jeweiligen Reiters on-demand ausgeführt.
- **Konsistentes Design**: Nahtlos in das CozyHaze Dark Neon Design integriert (Anthrazit `#0F1117`, Slate-Karten `#181B22` und Neon-Cyan `#00F2FE` Akzentuierungen).

---

## 2. Funktionsmodule im Detail

### 2.1 Systemübersicht
- **Hardware-Erkennung**: DMI-Modellkennung (`MacBookPro8,2`), Apple EFI-Firmwareversion, Hauptplatinen-Typ.
- **Prozessor**: Genaue Modellbezeichnung des Intel Core i5/i7 (Sandy Bridge), Anzahl der aktiven Kerne und Threads.
- **Ressourcenmonitore**: Grafische Verlaufsbalken für RAM-Belegung (z.B. von 16 GB DDR3) und SSD-Speicherplatz der Root-Partition.

### 2.2 GPU & Hardware-Umschaltung
- **Intel HD 3000 Status**: Zeigt an, ob das `i915`-Modul aktiv geladen ist und mit Hardwarebeschleunigung arbeitet.
- **AMD Radeon Status**: Grüne Warnanzeige, wenn die fehlerhafte dGPU wie gewünscht isoliert und stromlos ist.
- **Apple EFI gpu-power-prefs**: Zeigt den im NVRAM gespeicherten Zustand an.
- **Aktionsknöpfe**:
  - *GPU-Reparaturwerkzeug*: Startet `cozyhaze-gpu-repair` mit Root-Rechten im Terminal.
  - *Hardwarediagnose*: Startet `cozyhaze-gpu-diag` für einen vollständigen Terminalbericht.

### 2.3 Kernel-Verwaltung
- Zeigt den aktuell laufenden Kernel (`uname -r`).
- Listet alle unter `/boot/vmlinuz-*` installierten Kernel auf und markiert den aktiven Kernel.
- Ermöglicht das Neugenerieren der GRUB-Bootkonfiguration per Klick.

### 2.4 Energie- & Lüftersteuerung
- **CPU-Gouverneure**:
  - *powersave*: Senkt Takt und Spannung im Akkubetrieb.
  - *schedutil / ondemand*: Dynamische Anpassung je nach Arbeitslast.
  - *performance*: Maximaler CPU-Takt für Compiler- und Rendering-Aufgaben.
- **Apple SMC Lüftersensoren**: Liest die Drehzahlen der beiden internen Lüfter direkt aus `/sys/devices/platform/applesmc.768/`.

### 2.5 Systemwartung & Bereinigung
- **SSD-TRIM**: Führt `fstrim -v /` aus, um gelöschte Blöcke der SATA-SSD freizugeben und maximale Schreibgeschwindigkeiten zu sichern.
- **Paket-Cache bereinigen**: Ruft `apt-get clean` auf, um heruntergeladene `.deb`-Archive zu entfernen.

### 2.6 Netzwerkdiagnose
- Testet mit einem Klick die Internet-Verbindung zum Cloudflare Anycast-Server (`1.1.1.1`) und prüft die DNS-Namensauflösung (`debian.org`).

### 2.7 Backup & Wiederherstellung
- Direkter Zugriff auf die gesicherten Apple-EFI-Variablen unter `/var/backups/cozyhaze-efivars/`.
