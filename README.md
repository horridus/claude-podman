# Claude Code in Podman + Ollama

Esegui [Claude Code](https://github.com/anthropics/claude-code) in un container Podman isolato, usando un server **Ollama** locale come backend LLM.

```
┌─────────────────────────────────────────┐
│  Host Linux                             │
│                                         │
│  ┌─────────────┐                        │
│  │ claude-code │                        │
│  │  (Podman)   │                        │
│  └──────┬──────┘                        │
│         │                               │
└─────────┼───────────────────────────────┘
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
cp env.example .env
nano .env   # imposta WORKSPACE_PATH, OLLAMA_BASE_URL, OLLAMA_MODEL e, opzionalmente, CLAUDE_CONFIG_PATH

# 3. Rendi eseguibile lo script
chmod +x run.sh
```

## Utilizzo

```bash
# Usa il percorso definito in .env
./run.sh

# Oppure passa il percorso direttamente
./run.sh /home/tuoutente/progetti/mio-progetto

# Oppure passa argomenti direttamente a claude (es. modello)
./run.sh --model qwen2.5-coder:32b
```

## Configurazione modelli

Configura il modello direttamente in `.env`:

```bash
# Seleziona endpoint e modello Ollama
OLLAMA_BASE_URL=http://192.168.0.188:11434
OLLAMA_MODEL=qwen2.5-coder:32b

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

## Persistenza configurazione Claude Code

La configurazione di Claude Code viene montata dall'host nel container su `/root/.claude`, così credenziali, preferenze e cronologia persistono tra una sessione e l'altra.

Per default viene usato `~/.claude` sull'host. Se vuoi usare un percorso diverso, imposta `CLAUDE_CONFIG_PATH` nel file `.env`:

```bash
CLAUDE_CONFIG_PATH=~/.claude
```

## Sicurezza

- Il container accede **solo** alla cartella specificata in `WORKSPACE_PATH`
- Claude Code si connette direttamente a `OLLAMA_BASE_URL`
- `ANTHROPIC_AUTH_TOKEN=ollama` è richiesto ma Ollama non valida realmente il token
- Telemetry di Claude Code disabilitata
- Flag `no-new-privileges` attivo sul container

> Nota: da Ollama **>= 0.14.0** è disponibile il supporto nativo all'endpoint compatibile con le Anthropic Messages API, quindi non serve più un proxy LiteLLM.
