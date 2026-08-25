default:
    just --list

build:
    podman build -t ghcr.io/jkhaak/devc-mistral-vibe:latest .

