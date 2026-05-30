#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source .env

# Mantieni compatibilità: se il primo argomento è una directory, usalo come workspace override
if [[ -n "${1:-}" && -d "$1" ]]; then
  export WORKSPACE_PATH="$(realpath "$1")"
  shift
fi
echo "📂 Workspace: $WORKSPACE_PATH"

# Verifica che la cartella esista
if [[ ! -d "$WORKSPACE_PATH" ]]; then
  echo "❌ Errore: la cartella '$WORKSPACE_PATH' non esiste."
  exit 1
fi

# Build dell'immagine se non esiste
echo "🔨 Build immagine Claude Code..."
podman-compose build claude-code

# Avvia Claude Code in modo interattivo
echo "🤖 Avvio Claude Code..."
if [[ "$#" -gt 0 ]]; then
  podman-compose run --rm claude-code "$@"
else
  if [[ -z "${OLLAMA_MODEL:-}" ]]; then
    echo "❌ Errore: OLLAMA_MODEL non impostato in .env."
    exit 1
  fi
  podman-compose run --rm claude-code --model "${OLLAMA_MODEL}"
fi
