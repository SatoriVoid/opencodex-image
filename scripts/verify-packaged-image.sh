#!/bin/sh
set -eu

image=${1:?usage: verify-packaged-image.sh IMAGE}

# Explicitly run as the image's service account: a successful root invocation
# would not prove dashboard runtime support in the hardened hub container.
docker run --rm --user bun "$image" codex --version
docker run --rm --user bun "$image" codex app-server --help >/dev/null
docker run --rm --user bun "$image" claude --version
