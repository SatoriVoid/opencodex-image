#!/bin/sh
set -eu

requested_version=${1:-}

if [ -n "$requested_version" ]; then
  version=$requested_version
else
  version=$(curl -fsSL https://registry.npmjs.org/@bitkyc08%2Fopencodex/latest \
    | node -e 'let raw=""; process.stdin.on("data", c => raw += c); process.stdin.on("end", () => process.stdout.write(JSON.parse(raw).version));')
fi

case "$version" in
  ''|*[!0-9.]*|*..*|.*|*.)
    echo "Expected a stable numeric version, got: $version" >&2
    exit 1
    ;;
esac

major=$(printf '%s' "$version" | cut -d. -f1)
minor=$(printf '%s' "$version" | cut -d. -f1,2)
[ "$major" != "$minor" ] || { echo "Expected X.Y.Z version, got: $version" >&2; exit 1; }

remote=https://github.com/lidge-jun/opencodex.git
commit=$(git ls-remote "$remote" "refs/tags/v${version}^{}" | awk 'NR==1 { print $1 }')
if [ -z "$commit" ]; then
  commit=$(git ls-remote "$remote" "refs/tags/v${version}" | awk 'NR==1 { print $1 }')
fi
[ -n "$commit" ] || { echo "Upstream tag v${version} not found" >&2; exit 1; }

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    printf 'version=%s\n' "$version"
    printf 'major=%s\n' "$major"
    printf 'minor=%s\n' "$minor"
    printf 'commit=%s\n' "$commit"
  } >> "$GITHUB_OUTPUT"
else
  printf 'version=%s\nmajor=%s\nminor=%s\ncommit=%s\n' "$version" "$major" "$minor" "$commit"
fi
