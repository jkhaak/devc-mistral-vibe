#!/usr/bin/env bash

set -euo pipefail

# Write API key to ~/.vibe/.env if provided at runtime
if [ -n "${MISTRAL_API_KEY:-}" ]; then
    echo "MISTRAL_API_KEY='${MISTRAL_API_KEY}'" > ~/.vibe/.env
elif [ -n "${OLLAMA_BASE_URL:-}" ]; then
    # Satisfy vibe's key check without enabling cloud access
    echo "MISTRAL_API_KEY='offline'" > ~/.vibe/.env
fi

# On first run, back up the baked-in config as a template
if [ ! -f ~/.vibe/config.toml.bak ]; then
    cp ~/.vibe/config.toml ~/.vibe/config.toml.bak
fi

# Regenerate config.toml from the backup template on every run
cp ~/.vibe/config.toml.bak ~/.vibe/config.toml

# Append ollama provider if OLLAMA_BASE_URL is set
if [ -n "${OLLAMA_BASE_URL:-}" ]; then
    echo "Querying Ollama at ${OLLAMA_BASE_URL}..." >&2

    # Query Ollama with a 15 second timeout
    ollama_response=$(curl --silent --fail --max-time 15 \
        "${OLLAMA_BASE_URL}/api/tags") || {
            echo "ERROR: Failed to reach Ollama at ${OLLAMA_BASE_URL} (timeout: 15s)" >&2
            return 1
        }

    # Parse models
    models=$(echo "$ollama_response" | \
        jq -r '.models | sort_by(.size) | .[] | "\(.name)|\(.size)"')

    if [ -z "$models" ]; then
        echo "ERROR: Ollama is reachable but returned no models" >&2
        return 1
    fi

    # Determine active model: env var takes precedence, otherwise smallest model
    smallest_model=$(echo "$models" | head -1 | cut -d'|' -f1)
    active="${VIBE_ACTIVE_MODEL:-$smallest_model}"

    # Validate that the requested active model actually exists
    if ! echo "$models" | cut -d'|' -f1 | grep -qx "$active"; then
        echo "ERROR: VIBE_ACTIVE_MODEL '${active}' not found in Ollama model list" >&2
        return 1
    fi

    # Write active_model FIRST, before any array tables
    cat >> ~/.vibe/config.toml <<EOF
active_model = "${active}"

EOF

    # Append provider block
    cat >> ~/.vibe/config.toml <<EOF
[[providers]]
name = "ollama"
api_base = "${OLLAMA_BASE_URL}/v1"
api_key_env_var = ""
api_style = "openai"
backend = "generic"

EOF

    # Append a [[models]] block for each model
    while IFS='|' read -r name _size; do
        cat >> ~/.vibe/config.toml <<EOF
[[models]]
name = "${name}"
provider = "ollama"
alias = "${name}"

EOF
    done <<< "$models"

    echo "Ollama configured with $(echo "$models" | wc -l) model(s), active: ${active}" >&2
elif [ -z "${MISTRAL_API_KEY:-}" ]; then
    echo "ERROR: Neither OLLAMA_BASE_URL nor MISTRAL_API_KEY is set" >&2
    return 1
fi
