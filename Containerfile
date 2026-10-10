FROM ghcr.io/jkhaak/devc-base:latest

LABEL org.opencontainers.image.source="https://github.com/jkhaak/devc-mistral-vibe"
LABEL org.opencontainers.image.description="AI agent layer with mistral-vibe"

# Install uv and python
RUN brew update \
    && brew install -y uv python \
    && brew cleanup --prune=all \
    && rm -rf "$(brew --cache)"

# Install mistral-vibe
# Pin Python 3.13: miniaudio (a mistral-vibe dependency) has no
# c4315 wheels yet and its source build requires a C++ compiler.
RUN uv tool install --python 3.14 mistral-vibe

COPY --chown=dev:dev vibe.config.toml /home/dev/.vibe/config.toml
COPY --chown=dev:dev vibe.trusted_folders.toml /home/dev/.vibe/trusted_folders.toml

# Drop agent entrypoint script
COPY --chown=dev:dev --chmod=755 entrypoint.agent.sh /entrypoint.d/20-agent.sh

VOLUME ["/home/dev/.vibe"]
WORKDIR /workspace

