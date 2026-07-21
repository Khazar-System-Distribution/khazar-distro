<p align="center">
  <img src="distro/branding/khazar-logo.svg" width="120" alt="KhazarOS">
</p>

<h1 align="center">KhazarOS</h1>
<p align="center"><strong>AI-powered Linux Desktop</strong></p>

<p align="center">
  <a href="https://github.com/Khazar-System-Distribution/khazar/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-GPLv3-blue.svg" alt="License">
  </a>
  <img src="https://img.shields.io/badge/C-11-%23e94560" alt="C11">
  <img src="https://img.shields.io/badge/build-0_errors-success" alt="Build">
  <img src="https://img.shields.io/badge/tests-22%2F22-brightgreen" alt="Tests">
  <img src="https://img.shields.io/badge/platform-Linux%20x86__64-orange" alt="Platform">
</p>

<p align="center">
  <b>Fedora Silverblue əsaslı, tamamilə Azərbaycan türkcəsində işləyən AI əməliyyat sistemi.</b><br>
  Kompüteri səslə və ya mətnlə idarə edin — "firefox aç", "wifi söndür", "sistemi yenilə".
</p>

---

## Demo

```bash
$ kha "firefox aç"
  Status: success
  Result: opened firefox

$ kha "wifi söndür"
  Status: success
  Result: WiFi disabled

$ kha "səs artır"
  Status: success
  Result: volume +5%

$ kha status
  orchestrator    ● active
  rule-engine     ● active
  policy-engine   ● active
  desktop-agent   ● active
  ...
```

## Arxitektura

```
┌──────────────────────────────────────────────────────────────┐
│                      KhazarOS Desktop                        │
│                                                              │
│  ┌──────────┐    ┌──────────────────────────────────────┐    │
│  │  GNOME   │    │          Khazar Daemon                │    │
│  │  Shell   │    │         (systemd services)            │    │
│  │          │    │                                       │    │
│  │  Panel   │    │  Tier 0            Tier 1             │    │
│  │  Icon  ──┼────┤  ┌───────────┐   ┌───────────────┐   │    │
│  │          │    │  │Rule Engine│──▶│Classifier     │   │    │
│  │  Ctrl+   │    │  │(49 test)  │   │(LLM fallback) │   │    │
│  │  Space ──┼────┤  └─────┬─────┘   └───────┬───────┘   │    │
│  │          │    │        │                  │           │    │
│  └──────────┘    │  ┌─────▼──────────────────▼───────┐   │    │
│                  │  │       Orchestrator (v0.3)      │   │    │
│                  │  └─────┬──────────────┬───────────┘   │    │
│                  │        │              │                │    │
│                  │  ┌─────▼──────┐  ┌───▼──────────┐    │    │
│                  │  │Policy      │  │Agent Dispatch│    │    │
│                  │  │Engine      │  │desktop       │    │    │
│                  │  │ALLOW/DENY  │  │package       │    │    │
│                  │  │(13 rules)  │  │network       │    │    │
│                  │  └────────────┘  │power audio   │    │    │
│                  │                  └──────────────┘    │    │
│                  └──────────────────────────────────────┘    │
│                                                              │
│  Base:  Fedora Silverblue (rpm-ostree, immutable)            │
│  Build: podman build → bootc → ISO                           │
└──────────────────────────────────────────────────────────────┘
```

## Xüsusiyyətlər

| Xüsusiyyət | Açıqlama |
|-----------|----------|
| 🎤 **Səsli əmrlər** | Azərbaycan türkcəsində 31+ intent |
| 🔒 **Təhlükəsizlik** | Policy Engine — hər əməliyyat icazə yoxlamasından keçir |
| 🧠 **İki səviyyəli AI** | Tier 0: sürətli deterministik (49 test) + Tier 1: LLM (GGUF/llama.cpp) |
| 🏗️ **İmmutable OS** | Fedora Silverblue əsaslı — atomik yeniləmələr, rollback |
| 🔌 **5 Agent** | Desktop, Package, Network, Power, Audio |
| 🖥️ **GNOME Shell** | Panel ikonu, Ctrl+Space komanda paneli |
| 📦 **Tək repoda** | SDK + 5 komponent + 5 agent — `make all` ilə qurulur |

## Sürətli Başlanğıc

```bash
# Reponu klonla
git clone https://github.com/Khazar-System-Distribution/khazar
cd khazar

# Bütün sistemi qur (0 error)
make all

# Testləri çalışdır
make -C sdk test

# Quraşdır
sudo bash distro/installer/setup.sh
systemctl enable khazar.target --now

# İstifadə
kha "firefox aç"
```

## KhazarOS ISO Quruşu

```bash
# ISO yarat
make -C distro build-iso
→ distro/iso/output/khazaros.iso

# QEMU-da test
make -C distro test-qemu

# USB-yə yaz
make -C distro flash DISK=/dev/sdX
```

## Repo Strukturu

```
khazar/
├── sdk/                      ← Agent SDK (IPC, protocol, logger, events) — 22 test
├── components/
│   ├── orchestrator/         ← Tier 0+1 router, registry, policy client, agent dispatch
│   ├── rule-engine/          ← Deterministik intent classifier — 31 intent, 49 test
│   ├── policy-engine/        ← Təhlükəsizlik siyasəti — 13 qayda, fnmatch
│   ├── model-runtime/        ← LLM inference server (mock + llama.cpp stub)
│   └── intent-classifier/    ← Tier 1 LLM fallback + 32 keyword rules
├── agents/
│   ├── desktop-agent/        ← fork+exec ilə tətbiq açma
│   ├── package-agent/        ← apt/pacman ilə paket idarəsi
│   ├── network-agent/        ← nmcli ilə WiFi/ethernet
│   ├── power-agent/          ← systemctl/loginctl ilə enerji
│   └── audio-agent/          ← pactl ilə səs idarəsi
├── protocol/                 ← IPC kontraktları (JSON Schema, RPC, error codes)
├── distro/
│   ├── bootc/Containerfile   ← KhazarOS distro təsviri
│   ├── systemd/              ← 10 systemd servis + khazar.target
│   ├── gnome-extension/      ← GNOME Shell extension
│   ├── iso/build.sh          ← ISO qurucu
│   ├── installer/setup.sh    ← Quraşdırma skripti
│   └── cli/kha               ← İstifadəçi CLI aləti
└── docs/
```

## Pipeline — Tam Axın

```
    İstifadəçi:  "firefox aç"
         │
    ┌────▼─────────────────────────────────────────┐
    │ 1. Orchestrator  ── sorğunu qəbul edir       │
    └────┬─────────────────────────────────────────┘
         │
    ┌────▼─────────────────────────────────────────┐
    │ 2. Rule Engine   ── Tier 0: intent tapır     │
    │    "firefox ac" → open_application            │
    │    UNKNOWN? → Tier 1 (LLM)                    │
    └────┬─────────────────────────────────────────┘
         │
    ┌────▼─────────────────────────────────────────┐
    │ 3. Registry      ── capability → agent tapır  │
    │    open_application → desktop-agent           │
    └────┬─────────────────────────────────────────┘
         │
    ┌────▼─────────────────────────────────────────┐
    │ 4. Policy Engine ── təhlükəsizlik yoxlaması  │
    │    ALLOW / DENY                               │
    └────┬─────────────────────────────────────────┘
         │ ALLOW
    ┌────▼─────────────────────────────────────────┐
    │ 5. Agent Dispatch ── agent socket-ə göndərir │
    │    desktop-agent: fork+exec firefox           │
    └────┬─────────────────────────────────────────┘
         │
    ┌────▼────┐
    │ SUCCESS │
    └─────────┘
```

## Texnologiyalar

| Texnologiya | İstifadə |
|------------|---------|
| C11 | Bütün komponentlər (25000+ sətir) |
| GCC/Clang | Kompilyator |
| Unix Domain Sockets | IPC rabitəsi (epoll, non-blocking) |
| JSON | Mesaj formatı (strstr əsaslı parser) |
| systemd | Daemon idarəsi |
| GNOME Shell | İstifadəçi interfeysi |
| Fedora Silverblue | İmmutable baza OS |
| bootc / podman | Distro qurma |
| llama.cpp | LLM inference (Tier 1) |

## Build Status

| Komponent | Build | Test |
|-----------|-------|------|
| SDK | 0 error | 22/22 ✓ |
| Orchestrator | 0 error | — |
| Rule Engine | 0 warning | 49/49 ✓ |
| Policy Engine | 0 error | 7/7 ✓ |
| Model Runtime | 0 error | 4/4 ✓ |
| Intent Classifier | 0 error | 12/12 ✓ |
| Desktop Agent | 0 error | — |
| Package Agent | 0 error | — |
| Network Agent | 0 error | — |
| Power Agent | 0 error | — |
| Audio Agent | 0 error | — |

## Əlaqə

- **GitHub**: [github.com/Khazar-System-Distribution/khazar](https://github.com/Khazar-System-Distribution/khazar)
- **Lisensiya**: [GNU GPL v3](LICENSE)

---

<p align="center">
  <sub>Built with C11 • Fedora Silverblue • GNU/Linux</sub>
</p>
