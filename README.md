# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

English · [Русский](README.ru.md)

Ready-to-run, multi-architecture [OpenCodex](https://github.com/lidge-jun/opencodex) images for GitHub Container Registry:

```text
ghcr.io/satorivoid/opencodex
```

Supports `linux/amd64` and `linux/arm64`.

This is a packaging image, not an unchanged upstream image: each release builds the exact OpenCodex Git tag/commit with its upstream Dockerfile, then appends a small verified runtime layer. It bundles the official **Codex CLI** and **Claude Code** executables so OpenCodex can launch its Codex app-server integration and has a tested Claude Code runtime available.

## Bundled runtimes

| Runtime | Pinned version | Why it is present | It does not do |
| --- | --- | --- | --- |
| OpenCodex | matches image tag | Hub/dashboard service | Supply an OpenAI or Anthropic account. |
| Codex CLI | `0.167.1` | Provides `codex` and `codex app-server` for the dashboard integration. | Authenticate or make requests until its user config is authorized. |
| Claude Code | `2.1.322` | Provides the CLI needed for future OpenCodex/Claude Code use. | Authenticate, configure a provider, or make Claude available without authorization. |

The two client artifacts are fetched from their official release locations for each target architecture and verified against pinned SHA-256 values during the image build. No API key, OAuth token, or user credentials are included in the image. Codex is Apache-2.0; Claude Code remains subject to Anthropic's applicable terms.

OpenCodex, Codex, and Claude Code keep separate homes because their state and credentials are not interchangeable:

- `/home/bun/.opencodex`
- `/home/bun/.codex`
- `/home/bun/.claude`

## Quick start with Docker Compose

Docker and the Docker Compose plugin are required.

### 1. Clone the repository

```bash
git clone https://github.com/SatoriVoid/opencodex-image.git
cd opencodex-image
```

The included [`compose.yaml`](compose.yaml) is ready to run. It uses `ghcr.io/satorivoid/opencodex:latest`, hardened non-root hub runtime settings, and host-visible bind mounts below `./data`.

### 2. Create persistent directories and an API token

```bash
mkdir -p data/opencodex data/codex data/claude secrets

umask 077
openssl rand -hex 32 > secrets/opencodex_api_token
chmod 600 secrets/opencodex_api_token
```

### 3. Prepare the bind-mounted state

```bash
docker compose up init --abort-on-container-exit
```

The short-lived `init` service seeds OpenCodex configuration and fixes ownership for the non-root runtime. It makes fresh bind mounts work with rootless Docker without host `sudo`.

### 4. Initialize the OpenCodex API token

```bash
docker compose run --rm --no-deps -T hub \
  bun run docker/bootstrap-token.ts \
  < secrets/opencodex_api_token
```

The token is stored under `data/opencodex`. Keep `secrets/opencodex_api_token`: authenticated clients need it. Both paths are excluded from Git.

### 5. Start and check the hub

```bash
docker compose up -d hub
curl --fail --silent http://127.0.0.1:10100/healthz
curl --fail --silent http://127.0.0.1:10100/readyz
```

### 6. Check bundled runtimes as the service user

```bash
docker compose exec hub codex --version
docker compose exec hub codex app-server --help
docker compose exec hub claude --version
```

These checks prove the executables are available; they do not authenticate either vendor account.

## Configuration

`compose.yaml` works without `.env`. Create `.env` only to override ports or state paths:

```dotenv
OPENCODEX_BIND_ADDRESS=127.0.0.1
OPENCODEX_PORT=10100
OPENCODEX_STATE_DIR=./data/opencodex
CODEX_STATE_DIR=./data/codex
CLAUDE_STATE_DIR=./data/claude
```

| Variable | Default | Purpose |
| --- | --- | --- |
| `OPENCODEX_BIND_ADDRESS` | `127.0.0.1` | Host address that publishes OpenCodex. |
| `OPENCODEX_PORT` | `10100` | Published host port. |
| `OPENCODEX_STATE_DIR` | `./data/opencodex` | OpenCodex configuration, API token, and state. |
| `CODEX_STATE_DIR` | `./data/codex` | Codex configuration and authorized client state. |
| `CLAUDE_STATE_DIR` | `./data/claude` | Claude Code configuration and authorized client state. |

Keep the default loopback binding unless you intentionally deploy an authenticated TLS/private-network frontend. Do not publish the hub management port `10101`.

## Image tags and provenance

| Reference | Purpose |
| --- | --- |
| `:2.100.2` | Exact OpenCodex release packaged with the pinned clients above. |
| `:2.100` | Latest patch image in an OpenCodex minor series. |
| `:2` | Latest image in an OpenCodex major series. |
| `:latest` | Latest published stable image; used by `compose.yaml`. |
| `@sha256:…` | Immutable deployment reference. |

Each publication records the packaging repository/source revision, upstream OpenCodex commit, and bundled-client versions in OCI labels. It also includes an SBOM, BuildKit provenance, and a GitHub provenance attestation.

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Upstream and licensing

- OpenCodex: [source](https://github.com/lidge-jun/opencodex) — MIT
- Codex CLI: [source and releases](https://github.com/openai/codex) — Apache-2.0
- Claude Code: [installation documentation](https://code.claude.com/docs/en/getting-started) — use subject to Anthropic terms
