# Claude Code in Podman + Ollama

Esegui [Claude Code](https://github.com/anthropics/claude-code) in un container Podman isolato, usando un server **Ollama** locale come backend LLM tramite [LiteLLM](https://github.com/BerriAI/litellm) come proxy.

```
┌─────────────────────────────────────────┐
│  Host Linux                             │
│                                         │
│  ┌─────────────┐   ┌─────────────────┐  │
│  │ claude-code │──▶│ litellm-proxy   │  │
│  │  (Podman)   │   │   :4000         │  │
│  └─────────────┘   └────────┬────────┘  │
│                             │           │
└─────────────────────────────┼───────────┘
                              │
                              ▼
                   192.168.0.188:11434
                   (Ollama su rete locale)
```

## Requisiti

- Podman
- podman-compose (`pip install podman-compose`)
- Un server Ollama raggiungibile su `192.168.0.188:11434`

## Setup

```bash
# 1. Clona il repository
git clone https://github.com/horridus/claude-podman.git
cd claude-podman

# 2. Crea il file .env con il percorso della tua cartella di lavoro
cp .env.example .env
nano .env   # imposta WORKSPACE_PATH

# 3. (Opzionale) Cambia il modello Ollama in litellm-config.yaml
nano litellm-config.yaml

# 4. Rendi eseguibile lo script
chmod +x run.sh
```

## Utilizzo

```bash
# Usa il percorso definito in .env
./run.sh

# Oppure passa il percorso direttamente
./run.sh /home/tuoutente/progetti/mio-progetto

# Ferma il proxy quando hai finito
podman-compose down
```

## Configurazione modelli

Modifica `litellm-config.yaml` per usare i modelli che hai scaricato su Ollama:

```bash
# Elenca i modelli disponibili sul tuo server Ollama
curl http://192.168.0.188:11434/api/tags
```

Modelli consigliati per il coding:
| Modello | Dimensione | Note |
|---|---|---|
| `qwen2.5-coder:32b` | ~20GB | Migliore qualità |
| `qwen2.5-coder:7b` | ~4GB | Veloce, leggero |
| `deepseek-coder-v2:16b` | ~9GB | Ottimo compromesso |
| `codellama:13b` | ~8GB | Classico |

## Sicurezza

- Il container accede **solo** alla cartella specificata in `WORKSPACE_PATH`
- Il proxy LiteLLM è esposto **solo su loopback** (`127.0.0.1:4000`)
- La API key è fittizia (il traffico non esce dalla rete locale)
- Telemetry di Claude Code disabilitata
- Flag `no-new-privileges` attivo sul container
