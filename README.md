# devc-mistral-vibe

Development container image extending
[devc-base](https://github.com/jkhaak/devc-base) with the [Mistral
Vibe](https://docs.mistral.ai/vibe/code/cli) AI coding agent.

## What's included

- Everything from `devc-base`
- Python and `uv` via Homebrew
- `mistral-vibe` CLI installed via `uv tool`
- Runtime configuration for Mistral API and/or local Ollama models

## Runtime environment variables

| Variable            | Description                                                                                   |
|---------------------|-----------------------------------------------------------------------------------------------|
| `MISTRAL_API_KEY`   | Mistral API key for cloud models. Optional if using Ollama only.                              |
| `OLLAMA_BASE_URL`   | Ollama endpoint, e.g. `http://192.168.1.1:11434`. Optional.                                   |
| `VIBE_ACTIVE_MODEL` | Override the default active model. Must match full Ollama model name including tag. Optional. |

## Build

```bash
just build
```

## Reuse

```dockerfile
FROM ghcr.io/jkhaak/devc-mistral-vibe:latest
```

Drop additional entrypoint scripts into `/entrypoint.d` to extend startup
behaviour. Scripts are sourced in lexicographic order — prefix with a number
above `20` to run after the agent setup.

## Container registry

Images are published to the GitHub Container Registry and can be browsed at: https://github.com/jkhaak/devc-base/pkgs/container/devc-mistral-vibe

Built daily for `amd64` and `arm64` architectures.

Available tags:
- `latest` — most recent build
- `YYYmmDD.patch` — date versioned build, e.g. `20260826.0`
- `sha-<commit>` — build tied to a specific commit

## LICENCE

Copyright Jani Haakana, 2026, licenced under the EUPL.
