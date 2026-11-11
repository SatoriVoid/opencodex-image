# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

English · [Русский](README.ru.md)

Ready-to-run, multi-platform container images for [OpenCodex](https://github.com/lidge-jun/opencodex). OpenCodex does not publish an official image; this repository builds the upstream `Dockerfile` unchanged and publishes it to GitHub Container Registry.

```text
ghcr.io/satorivoid/opencodex
```

Supports `linux/amd64` and `linux/arm64`.

## Quick start

1. Copy [`compose.example.yaml`](compose.example.yaml) to `compose.yaml`.
2. Replace `REPLACE_WITH_RELEASE_DIGEST` with the digest from the [release](https://github.com/SatoriVoid/opencodex-image/releases) you want.
3. Initialize the service token, then start the service:

```bash
openssl rand -hex 32 | docker compose run --rm -T hub bun run docker/bootstrap-token.ts
docker compose up -d
```

Keep the generated token in the configuration of clients that access the service. Do not commit it.

## Image tags

| Reference | Purpose |
| --- | --- |
| `:2.100.2` | Exact OpenCodex release |
| `:2.100` | Latest patch release in a minor series |
| `:2` | Latest minor release in a major series |
| `:latest` | Latest published stable release |
| `@sha256:…` | Immutable deployment reference |

For production, deploy the immutable digest from a GitHub Release:

```yaml
image: ghcr.io/satorivoid/opencodex@sha256:<digest>
```

`latest` is convenient for evaluation, not for a pinned deployment.

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

## Rollback

Select a digest from an earlier [release](https://github.com/SatoriVoid/opencodex-image/releases) and redeploy it. No build is needed on the target host.

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Upstream license: MIT
