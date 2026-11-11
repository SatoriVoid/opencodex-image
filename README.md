# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

English · [Русский](README.ru.md)

Ready-to-run, multi-platform container images for [OpenCodex](https://github.com/lidge-jun/opencodex). OpenCodex does not publish an official image; this repository builds the upstream `Dockerfile` unchanged and publishes it to GitHub Container Registry.

```text
ghcr.io/satorivoid/opencodex
```

Supports `linux/amd64` and `linux/arm64`.

## Quick start with Docker Compose

Docker and the Docker Compose plugin are required.

### 1. Clone the repository

```bash
git clone https://github.com/SatoriVoid/opencodex-image.git
cd opencodex-image
```

The repository includes a ready-to-run [`compose.yaml`](compose.yaml). It uses `ghcr.io/satorivoid/opencodex:latest` and stores OpenCodex state in host directories under `./data`.

### 2. Create persistent directories and an API token

```bash
mkdir -p data/opencodex data/codex secrets

umask 077
openssl rand -hex 32 > secrets/opencodex_api_token
chmod 600 secrets/opencodex_api_token
```

### 3. Prepare the bind-mounted state

```bash
docker compose up init --abort-on-container-exit
```

The short-lived `init` service seeds the upstream container configuration and sets ownership for OpenCodex. This also makes the bind mounts work with rootless Docker without requiring `sudo` on the host.

### 4. Initialize the token

```bash
docker compose run --rm --no-deps -T hub \
  bun run docker/bootstrap-token.ts \
  < secrets/opencodex_api_token
```

The token is stored in `data/opencodex`. Keep `secrets/opencodex_api_token`: clients use it for authenticated access. Both paths are excluded from Git.

### 5. Start OpenCodex

```bash
docker compose up -d hub
```

### 6. Check readiness

```bash
curl --fail --silent http://127.0.0.1:10100/healthz
curl --fail --silent http://127.0.0.1:10100/readyz
```

## Configuration

`compose.yaml` works without `.env`. Create `.env` next to it only when you need to override network or host paths:

```dotenv
# Network exposure
OPENCODEX_BIND_ADDRESS=127.0.0.1
OPENCODEX_PORT=10100

# Persistent state on the host
OPENCODEX_STATE_DIR=./data/opencodex
CODEX_STATE_DIR=./data/codex
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `OPENCODEX_BIND_ADDRESS` | `127.0.0.1` | Host address that publishes OpenCodex. |
| `OPENCODEX_PORT` | `10100` | Host port mapped to OpenCodex port `10100` inside the container. |
| `OPENCODEX_STATE_DIR` | `./data/opencodex` | OpenCodex configuration, API token, and persistent state. |
| `CODEX_STATE_DIR` | `./data/codex` | Codex state used by OpenCodex. |

### Access modes

**Local host or reverse proxy on the same host — recommended**

Keep the default binding:

```dotenv
OPENCODEX_BIND_ADDRESS=127.0.0.1
```

Use an authenticated HTTPS reverse proxy when access from another network is required.

**LAN or Tailscale**

Bind only to the intended interface address:

```dotenv
OPENCODEX_BIND_ADDRESS=100.x.y.z
```

Keep the API token and use TLS or a trusted private network. Avoid binding directly to every interface unless that exposure is intentional and protected.

## Image tags

| Reference | Purpose |
| --- | --- |
| `:2.100.2` | Exact OpenCodex release |
| `:2.100` | Latest patch release in a minor series |
| `:2` | Latest minor release in a major series |
| `:latest` | Latest published stable release; used by `compose.yaml` |
| `@sha256:…` | Immutable deployment reference |

To pin a deployment or roll back, replace `:latest` in `compose.yaml` with an exact version tag or an immutable digest from a [release](https://github.com/SatoriVoid/opencodex-image/releases).

## What is verified

- The npm release is resolved to an immutable upstream Git tag and commit.
- The image is built from the upstream `Dockerfile` and smoke-tested before publishing.
- Every published image includes an SBOM and BuildKit provenance.
- A GitHub provenance attestation is published for each release.

## Verify provenance

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Upstream license: MIT
