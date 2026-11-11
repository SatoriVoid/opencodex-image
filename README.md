# OpenCodex image factory

This repository publishes a minimal, multi-architecture OpenCodex runtime image to:

```text
ghcr.io/satorivoid/opencodex
```

It does **not** fork or patch OpenCodex. GitHub Actions resolves the stable npm version of `@bitkyc08/opencodex`, verifies that the matching immutable upstream tag exists, checks out that exact commit, and builds upstream's own `Dockerfile`.

## Published platforms

- `linux/amd64`
- `linux/arm64`

## Image policy

- The production deployment must use `image@sha256:<digest>`, never `latest`.
- The release workflow publishes `<version>`, `<major>.<minor>`, `<major>`, `latest`, and `upstream-<commit>` tags as conveniences.
- A GitHub Release named `upstream-v<version>` is the release record and contains the authoritative digest.
- The image includes BuildKit SBOM and provenance metadata. GitHub Actions additionally writes a provenance attestation.

## Triggering a build

Open **Actions → Release OpenCodex image → Run workflow**.

- Leave `version` empty to use the current stable npm `latest`.
- Set `force_rebuild` only to rebuild a version that already has a published GitHub Release.

Scheduled checks run every six hours. Existing releases are skipped.

## Deployment

Copy `compose.example.yaml` into the Dockhand project and replace the digest with one from the GitHub Release:

```yaml
image: ghcr.io/satorivoid/opencodex@sha256:<digest>
```

Before the first `up -d`, initialize the owner-only service token in the local `ocx-state` volume:

```bash
openssl rand -hex 32 | docker compose run --rm -T hub bun run docker/bootstrap-token.ts
docker compose up -d
```

Store that token in the client-side configuration that talks to OpenCodex. Never commit it.

## Verify provenance

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Rollback

Replace the deployed digest with the prior release digest and redeploy through Dockhand. No rebuild occurs on the deployment host.
