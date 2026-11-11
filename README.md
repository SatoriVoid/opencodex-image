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

The repository includes a ready-to-run [`compose.yaml`](compose.yaml). It uses `ghcr.io/satorivoid/opencodex:latest` and keeps OpenCodex state in Docker volumes.

### 2. Configure the host binding

```bash
cp .env.example .env
```

The default `.env` keeps OpenCodex available only from this machine:

```dotenv
OPENCODEX_BIND_ADDRESS=127.0.0.1
OPENCODEX_PORT=10100
```

### 3. Create the API token

```bash
mkdir -p secrets
umask 077
openssl rand -hex 32 > secrets/opencodex_api_token

docker compose run --rm -T hub \
  bun run docker/bootstrap-token.ts \
  < secrets/opencodex_api_token
```

The token is stored in the OpenCodex state volume. Keep `secrets/opencodex_api_token`: clients use it for authenticated access. The file is excluded from Git.

### 4. Start OpenCodex

```bash
docker compose up -d
```

### 5. Check readiness

```bash
curl --fail --silent http://127.0.0.1:10100/healthz
curl --fail --silent http://127.0.0.1:10100/readyz
```

## Configuration

Docker Compose reads non-secret host settings from `.env`.

| Variable | Default | Purpose |
| --- | --- | --- |
| `OPENCODEX_BIND_ADDRESS` | `127.0.0.1` | Host address that publishes OpenCodex. |
| `OPENCODEX_PORT` | `10100` | Host port mapped to OpenCodex port `10100` inside the container. |

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
