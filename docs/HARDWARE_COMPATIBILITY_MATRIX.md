# CozyHaze OS Ultimate: Hardware- & Befehlssatz-Kompatibilitätsmatrix
**Plattform: Apple MacBook Pro 15" (Frühjahr/Spät 2011 – MacBookPro8,2 / A1286)**

---

## 1. Prozessor & CPU-Befehlssätze (Intel Sandy Bridge)

- **CPU-Architektur**: Intel Core i5-2415M / i7-2635QM / i7-2720QM / i7-2820QM (Sandy Bridge, 32nm)
- **Vorhandene Befehlssätze**: MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2, AVX (1.0), VT-x (Virtualisierung), AES-NI
- **NICHT vorhandene Befehlssätze**:
  - ❌ **AVX2 / FMA3**: Erst ab Haswell (4. Gen). Wichtig für moderne lokale KI-Inferenz (z.B. neuere Default-Builds von `llama.cpp` und `Ollama`).
  - ❌ **AVX-512**: Nicht vorhanden.

### Konsequenzen & Lösungen für CozyHaze OS Ultimate:
1. **Lokale KI (Ollama / llama.cpp)**:
   - Standard-Binaries von Ollama/llama.cpp setzen oft AVX2 voraus.
   - *CozyHaze-Lösung*: Bereitstellung von AVX1-kompatiblen Fallback-Builds bzw. Umschaltung auf den **CozyHaze AI Network Mode**, bei dem rechenintensive Inferenz auf Heimnetzwerk-Server (LAN-GPUs) ausgelagert wird, während das MacBook als schlanker Steuerungs-Client dient.
2. **Compiler & C/C++-Entwicklung**:
   - GCC, Clang, Rust und Node.js laufen uneingeschränkt nativ und hochperformant mit `-march=sandybridge`.

---

## 2. Grafikarchitektur (Intel HD Graphics 3000 vs. Defekte AMD Radeon)

- **Integrierte GPU (iGPU)**: Intel HD Graphics 3000 (Gen6 Architektur)
  - Treiber: Mesa `crocus` / `i915`
  - Unterstützte API: **OpenGL 3.3** (Core), OpenGL ES 3.0
  - ❌ **Kein Vulkan**: Vulkan erfordert mindestens Intel Ivy Bridge (HD 4000) bzw. Haswell.
  - ❌ **Kein OpenCL 2.0+**: Keine GPGPU-Beschleunigung für Blender Cycles GPU oder CUDA.
- **Dedizierte GPU (dGPU)**: AMD Radeon HD 6490M / 6750M / 6770M
  - Zustand: **Hardwaredefekt (Radeongate)**
  - Maßnahme: **Permanente Hardware-Trennung** via Apple GMUX (`outb 0x750 0`), Treiber-Blacklist und EFI-Variable `gpu-power-prefs` = 0x01.

### Konsequenzen & Lösungen für Multimedia & Gaming:
1. **Moderne 3D-Spiele / DXVK / Proton**:
   - Windows-Spiele, die Vulkan oder DirectX 11/12 über DXVK zwingend erfordern, können auf der HD 3000 nicht gestartet werden.
   - *CozyHaze-Lösung*: Fokus auf native Linux-Titel (OpenGL), RetroArch (SNES, PS1, N64, GBA, Arcade) und 2D-/Indie-Klassiker. Keine falschen Versprechungen im App-Store.
2. **Grafik & Video (GIMP, Inkscape, Kdenlive, HandBrake)**:
   - GIMP und Inkscape laufen hervorragend über CPU-Rendering und OpenGL 3.3.
   - Videobeschleunigung: VA-API decodiert MPEG-2 und H.264 (1080p). H.265/HEVC und AV1 werden rein über die Multicore-CPU decodiert.

---

## 3. Zwei-Ebenen-Softwarearchitektur (Core vs. Extras)

Um eine blitzschnelle Startzeit und niedrige RAM-Auslastung (< 600 MB im Leerlauf) zu garantieren, teilt CozyHaze OS Ultimate die Software in zwei klare Ebenen:

| Ebene | Beschreibung | Enthaltene Komponenten | Offline-Verfügbarkeit |
| :--- | :--- | :--- | :--- |
| **Ultimate Core** | Direkt im Live-Image & Grundsystem installiert. Keine trägen Daemons. | C/C++, Python, Node, Git, Wireshark, Nmap, LibreOffice, Firefox, GIMP, Audacity, VLC, UFW Firewall, Calamares, Control Center. | **100% Offline nutzbar** |
| **Ultimate Extras** | Spezialisierte oder speicherintensive IDEs und Tools. Werden über das **CozyHaze Software Center** mit 1-Klick installiert. | VSCodium, JetBrains IDEA Community, PyCharm, DBeaver, Burp Suite, Ollama, HandBrake, Steam, RetroArch Cores, Kubernetes CLI. | Online bzw. lokales Repo |

---

## 4. Systemsicherheits-Architektur

1. **Firewall (UFW)**: Standardmäßig aktiv (`default deny incoming`, `default allow outgoing`).
2. **Keine offenen Ports**: OpenSSH Client ist installiert, aber der SSH-Server-Daemon (`sshd.service`) ist standardmäßig deaktiviert.
3. **AppArmor**: Standardmäßig im Kernel aktiv zur Isolation von Webbrowsern und unsicheren Prozessen.
4. **Keine automatischen Root-Rechte für Penetrationstests**: Tools wie Wireshark oder Nmap nutzen Capabilities (`cap_net_raw`) oder `pkexec`, niemals automatische Root-Dauerläufe.
