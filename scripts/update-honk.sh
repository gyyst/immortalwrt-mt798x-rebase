#!/bin/sh
# Update package/honk/Makefile to a honk upstream release.
#
# Usage:
#   ./scripts/update-honk.sh                  # latest upstream release
#   ./scripts/update-honk.sh v0.1.0-beta.5    # specific tag
#
# Requires: gh (authenticated), curl, sha256sum, sed.
set -eu

REPO="daeuniverse/honk"
ASSET_RE='aarch64-unknown-linux-musl-stock-native-api\.tar\.gz$'
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAKEFILE="$ROOT/package/honk/Makefile"
TAG="${1:-}"

if [ -z "$TAG" ]; then
	TAG="$(gh api "repos/${REPO}/releases?per_page=10" \
		--jq '[.[] | select(.draft == false)] | sort_by(.published_at) | reverse | .[0].tag_name')"
fi

[ -n "$TAG" ] || { echo "error: could not resolve latest honk release" >&2; exit 1; }

URL="$(gh api "repos/${REPO}/releases/tags/${TAG}" \
	--jq '.assets[].browser_download_url' | grep -E "${ASSET_RE}" | head -n1)"
[ -n "$URL" ] || { echo "error: no aarch64 stock-native-api asset for ${TAG}" >&2; exit 1; }

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
curl -fsSL -o "$TMP" "$URL"
HASH="$(sha256sum "$TMP" | cut -d' ' -f1)"

# APK requires a valid version: v0.1.0-beta.5 -> 0.1.0_beta5
VERSION="$(echo "$TAG" | sed -E 's/^v//; s/-(alpha|beta|rc|pre)\.([0-9]+)$/_\1\2/')"

sed -i -E "s|^PKG_VERSION:=.*|PKG_VERSION:=${VERSION}|" "$MAKEFILE"
sed -i -E "s|^HONK_RELEASE:=.*|HONK_RELEASE:=${TAG}|" "$MAKEFILE"
sed -i -E "s|^PKG_HASH:=.*|PKG_HASH:=${HASH}|" "$MAKEFILE"

echo "honk ${TAG} -> PKG_VERSION=${VERSION}"
echo "sha256=${HASH}"
echo
git -C "$ROOT" diff -- package/honk/Makefile
