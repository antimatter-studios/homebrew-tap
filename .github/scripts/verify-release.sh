#!/usr/bin/env bash
# verify-release.sh <project> <version>
#
# Before a sync's pull request is merged: check that what the formula points
# at is what the project's release workflow built.
#
# For every platform the project declares in projects.json and its formula
# carries, this downloads the release asset and requires
#
#   1. its sha256 to be the one in the formula, and
#   2. a build-provenance attestation for it, signed by the project's own
#      .github/workflows/release.yml (`gh attestation verify
#      --signer-workflow`), so the bytes were built by that workflow in that
#      repository and not uploaded by hand.
#
# The formula must already declare <version>: run this on the sync's branch.
# A release made before its project attested its builds has no attestation
# and fails here; that is the answer, not a reason to skip the check.
#
# Needs gh (authenticated), jq and python3.
set -euo pipefail

project="${1:-}"
version="${2:-}"
[ -n "$project" ] && [ -n "$version" ] || { echo "usage: verify-release.sh <project> <version>" >&2; exit 2; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

field() { jq -r --arg n "$project" --arg f "$1" '.[$n][$f] // empty' projects.json; }
repo="$(field repo)"
[ -n "$repo" ] || { echo "verify-release: $project is not in projects.json" >&2; exit 1; }
prefix="$(field tag_prefix)"
formula="$(field formula)"
asset_template="$(jq -r --arg n "$project" '.[$n].asset // "{name}-{version}-{platform}.tar.gz"' projects.json)"
platforms="$(jq -r --arg n "$project" '(.[$n].platforms // ["darwin-arm64","darwin-x86_64","linux-arm64","linux-x86_64"])[]' projects.json)"

declared="$(sed -nE '/^  version "/{s/^  version "([^"]+)".*/\1/p;q;}' "$formula")"
[ "$declared" = "$version" ] \
    || { echo "verify-release: $formula declares $declared, not $version" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
tag="${prefix}${version}"
fails=0
checked=0

for platform in $platforms; do
    grep -q -- "$platform" "$formula" || continue
    asset="${asset_template//\{name\}/$project}"
    asset="${asset//\{version\}/$version}"
    asset="${asset//\{platform\}/$platform}"

    # The sha256 stanza beside this platform's url, either side, as
    # set-sha256.py finds it.
    want="$(python3 - "$formula" "$platform" <<'PY'
import re, sys
lines = open(sys.argv[1]).read().split("\n")
i = next(i for i, l in enumerate(lines) if sys.argv[2] in l and "url " in l)
for j in (i - 1, i + 1):
    m = re.search(r'sha256 "([0-9a-f]{64})"', lines[j])
    if m:
        print(m.group(1))
        break
PY
)"

    if ! gh release download "$tag" --repo "$repo" --pattern "$asset" --dir "$work" --clobber >/dev/null 2>&1; then
        echo "FAIL $asset: not attached to $repo $tag" >&2
        fails=$((fails + 1))
        continue
    fi
    got="$(shasum -a 256 "$work/$asset" | cut -d' ' -f1)"
    checked=$((checked + 1))
    if [ "$got" != "$want" ]; then
        echo "FAIL $asset: sha256 $got, formula says ${want:-nothing}" >&2
        fails=$((fails + 1))
    else
        echo "  ok  $asset sha256 matches $formula"
    fi

    if gh attestation verify "$work/$asset" --repo "$repo" \
        --signer-workflow "$repo/.github/workflows/release.yml" >/dev/null 2>"$work/attest.err"; then
        echo "  ok  $asset was built by $repo/.github/workflows/release.yml"
    else
        echo "FAIL $asset: no build-provenance attestation from $repo/.github/workflows/release.yml:" >&2
        sed 's/^/       /' "$work/attest.err" >&2
        fails=$((fails + 1))
    fi
done

if [ "$checked" -eq 0 ]; then
    echo "verify-release: $formula carries none of $project's platforms" >&2
    exit 1
fi
if [ "$fails" -gt 0 ]; then
    echo "verify-release: $project $version: $fails problem(s); do not merge" >&2
    exit 1
fi
echo "verify-release: $project $version: every asset matches its formula and was built by its release workflow"
