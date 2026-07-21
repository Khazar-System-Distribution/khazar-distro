# Khazar System Distribution

AI əsaslı əməliyyat sistemi üçün agent platforması.

## Arxitektura

```
protokol/              ← Ortaq IPC kontraktları (sənəd)
sdk/                   ← Agent SDK (kitabxana)
components/
  orchestrator/        ← Tier 0 + Tier 1 router
  rule-engine/         ← Deterministik intent classifier (Tier 0)
  policy-engine/       ← Təhlükəsizlik siyasəti yoxlaması
  model-runtime/       ← LLM inference server (GGUF/llama.cpp)
  intent-classifier/   ← Tier 1 LLM classifier
agents/
  desktop-agent/       ← Tətbiq açma/bağlama
  package-agent/       ← Paket idarəsi (apt/pacman)
  network-agent/       ← WiFi/ethernet idarəsi
  power-agent/         ← Söndürmə/yenidən başlatma
  audio-agent/         ← Səs idarəsi (PulseAudio)
```

## Build

```bash
make          # Hamısını qur
make sdk      # Yalnız SDK
make test     # Bütün testlər
make install  # Sistemə quraşdır
```

## Pipeline

```
İstifadəçi → Orchestrator → Rule Engine (Tier 0)
                ↓ UNKNOWN
           Intent Classifier → Model Runtime (Tier 1, LLM)
                ↓
           Registry → Agent tap
                ↓
           Policy Engine → ALLOW/DENY
                ↓
           Agent → İcra
```

## Lisensiya

GNU General Public License v3.0
