#!/usr/bin/env sh
# Refresh Formula/leaf.rb version + sha256 from a published GitHub Release.
# Usage: ./scripts/update-homebrew-formula.sh [tag]
# Example: ./scripts/update-homebrew-formula.sh 1.26.3
set -eu

REPO="${REPO:-Shi1xin/leaf}"
TAG="${1:-}"
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
FORMULA="$ROOT/Formula/leaf.rb"

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

need_cmd curl
need_cmd python3

if [ -z "$TAG" ]; then
    TAG="$(
        curl -fsSIL "https://github.com/$REPO/releases/latest" |
            sed -n 's/^[Ll]ocation: .*\/releases\/tag\/\([^[:space:]\r]*\).*/\1/p' |
            tail -n 1
    )"
fi

[ -n "$TAG" ] || {
    echo "Unable to resolve release tag" >&2
    exit 1
}

VERSION="${TAG#v}"
CHECKSUMS_URL="https://github.com/$REPO/releases/download/$TAG/checksums.txt"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

curl -fsSL "$CHECKSUMS_URL" -o "$TMP"
echo "Using $CHECKSUMS_URL"

sha_for() {
    # checksums.txt lines: "<sha256>  <filename>" or "<sha256> <filename>"
    grep -E "[[:space:]]$1\$" "$TMP" | awk '{print $1}' | head -n 1
}

MAC_ARM="$(sha_for leaf-macos-arm64)"
MAC_X64="$(sha_for leaf-macos-x86_64)"
LIN_ARM="$(sha_for leaf-linux-arm64)"
LIN_X64="$(sha_for leaf-linux-x86_64)"

for name in MAC_ARM MAC_X64 LIN_ARM LIN_X64; do
    eval "val=\$$name"
    [ -n "$val" ] || {
        echo "Missing checksum for required asset ($name)" >&2
        cat "$TMP" >&2
        exit 1
    }
done

python3 - "$FORMULA" "$VERSION" "$MAC_ARM" "$MAC_X64" "$LIN_ARM" "$LIN_X64" <<'PY'
import pathlib, re, sys

path = pathlib.Path(sys.argv[1])
version, mac_arm, mac_x64, lin_arm, lin_x64 = sys.argv[2:7]
text = path.read_text()

text = re.sub(r'version "[^"]+"', f'version "{version}"', text, count=1)

def set_sha(text, asset, sha):
    # Replace the sha256 that follows the url line for this asset.
    pattern = (
        rf'(url "https://github.com/[^"]+/releases/download/[^/]+/{re.escape(asset)}"\n\s*sha256 ")([a-fA-F0-9]+)(")'
    )
    new, n = re.subn(pattern, rf'\g<1>{sha}\g<3>', text, count=1)
    if n != 1:
        raise SystemExit(f"failed to patch sha256 for {asset}")
    return new

# Also rewrite download tag/version in urls
text = re.sub(
    r'(https://github.com/Shi1xin/leaf/releases/download/)[^/]+(/)',
    rf'\g<1>{version}\g<2>',
    text,
)

for asset, sha in [
    ("leaf-macos-arm64", mac_arm),
    ("leaf-macos-x86_64", mac_x64),
    ("leaf-linux-arm64", lin_arm),
    ("leaf-linux-x86_64", lin_x64),
]:
    text = set_sha(text, asset, sha)

# Keep the usage comment version in sync
text = re.sub(
    r'(#   \./scripts/update-homebrew-formula\.sh )[\d.]+',
    rf'\g<1>{version}',
    text,
    count=1,
)

path.write_text(text)
print(f"Updated {path} for {version}")
PY
