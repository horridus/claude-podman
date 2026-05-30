#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Permetti di passare il percorso come argomento, altrimenti usa .env
if [[ -n "${1:-}" ]]; then
  export WORKSPACE_PATH="$(realpath "$1")"
  echo "📂 Workspace: $WORKSPACE_PATH"
else
  source .env
  echo "📂 Workspace da .env: $WORKSPACE_PATH"
fi

# Verifica che la cartella esista
if [[ ! -d "$WORKSPACE_PATH" ]]; then
  echo "❌ Errore: la cartella '$WORKSPACE_PATH' non esiste."
  exit 1
fi

# Build dell'immagine se non esiste
echo "🔨 Build immagine Claude Code..."
podman-compose build claude-code

# Avvia il proxy in background (se non già attivo)
echo "🚀 Avvio LiteLLM proxy..."
podman-compose up -d litellm-proxy

# Aspetta che il proxy sia pronto
echo "⏳ Attendo che il proxy sia pronto..."
until podman-compose exec -T litellm-proxy curl -sf http://localhost:4000/health > /dev/null 2>&1; do
  sleep 2
done
echo "✅ Proxy pronto!"

# Avvia Claude Code in modo interattivo
echo "🤖 Avvio Claude Code..."
podman-compose run --rm claude-code "$@"
