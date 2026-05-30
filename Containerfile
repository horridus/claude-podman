FROM node:20-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Installa Claude Code globalmente
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

ENTRYPOINT ["claude"]
