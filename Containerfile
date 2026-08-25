FROM ghcr.io/jkhaak/devc-base:latest

LABEL org.opencontainers.image.source="https://github.com/jkhaak/devc-mistral-vibe"
LABEL org.opencontainers.image.description="AI agent layer with mistral-vibe"

# Install uv and python
RUN brew install uv python

# Install mistral-vibe
RUN uv tool install mistral-vibe

COPY --chown=dev:dev vibe.config.toml /home/dev/.vibe/config.toml
COPY --chown=dev:dev vibe.trusted_folders.toml /home/dev/.vibe/trusted_folders.toml

# Drop agent entrypoint script
COPY --chown=dev:dev --chmod=755 entrypoint.agent.sh /entrypoint.d/20-agent.sh

VOLUME ["/home/dev/.vibe"]
WORKDIR /workspace

