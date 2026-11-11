# OpenCodex Image Factory

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

English · [Русский](README.ru.md)

A minimal, reproducible container-image pipeline for [OpenCodex](https://github.com/lidge-jun/opencodex).

It builds OpenCodex from an immutable upstream Git tag and publishes multi-architecture images to GitHub Container Registry. This repository contains packaging and CI only; it does not fork or modify OpenCodex itself.

## Images

```text
ghcr.io/satorivoid/opencodex
```

| Platform | Supported |
| --- | --- |
| `linux/amd64` | Yes |
| `linux/arm64` | Yes |

## Guarantees

- Upstream npm version is resolved to a matching immutable Git tag and commit SHA.
- The image is built from the upstream `Dockerfile`.
- Every release passes an HTTP smoke test before publication.
- BuildKit SBOM and provenance are attached to the OCI image.
- GitHub Actions publishes a provenance attestation.

## Tags and deployment

The workflow publishes version, minor, major, `latest`, and `upstream-<commit>` tags.

For any real deployment, pin the immutable digest from the corresponding GitHub Release:

```yaml
image: ghcr.io/satorivoid/opencodex@sha256:<digest>
```

Do not deploy `latest`.

## Build a release

Open **Actions → Release OpenCodex image → Run workflow**.

- Leave `version` empty to resolve the current stable npm release.
- Use `force_rebuild` only when rebuilding an already released upstream version.

A scheduled check runs every six hours and skips versions already recorded as releases.

## Quick start with Docker Compose

Copy [`compose.example.yaml`](compose.example.yaml), replace the digest, then initialize the local service token before the first start:

```bash
openssl rand -hex 32 | docker compose run --rm -T hub bun run docker/bootstrap-token.ts
docker compose up -d
```

Keep the generated token in the configuration of clients that access the service. Do not commit it.

## Verify provenance

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Rollback

Redeploy a digest from an earlier GitHub Release. No image build is needed on the target host.

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Upstream license: MIT
