#!/usr/bin/env bash
# test-verify-release.sh
#
# verify-release.sh against a stubbed `gh`, so it runs without the network or
# credentials. The stub serves one asset and answers `gh attestation verify`
# as if that asset carried a single attestation from one signer workflow, and
# only for the project's own repository.
#
# A project's tarballs are signed either by its own release.yml or, once it
# packages through the shared reusable workflow, by rust-fs-core's
# release-cli.yml. Both must be accepted; any other signer must be refused, as
# must an attestation that does not belong to the project's repository.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fails=0
ok()   { echo "  ok  $1"; }
fail() { echo "FAIL $1" >&2; fails=$((fails + 1)); }

sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT

repo="example-org/example-tool"

# A tap with one project, one platform and one formula.
tap="$sandbox/tap"
mkdir -p "$tap/.github/scripts" "$tap/Formula" "$sandbox/bin"
cp "$here/verify-release.sh" "$tap/.github/scripts/"
cat > "$tap/projects.json" <<JSON
{
  "example-tool": {
    "repo": "$repo",
    "tag_prefix": "v",
    "formula": "Formula/example-tool.rb",
    "platforms": ["linux-x86_64"]
  }
}
JSON
printf 'payload\n' > "$sandbox/payload"
sum="$(shasum -a 256 "$sandbox/payload" | cut -d' ' -f1)"
cat > "$tap/Formula/example-tool.rb" <<RB
class ExampleTool < Formula
  version "1.2.3"
  url "https://example.invalid/example-tool-#{version}-linux-x86_64.tar.gz"
  sha256 "$sum"
end
RB

# The stub gh. STUB_SIGNER is the workflow that signed the asset; STUB_REPO the
# repository the attestation belongs to.
cat > "$sandbox/bin/gh" <<'SH'
#!/usr/bin/env bash
case "$1 $2" in
  "release download")
    shift 2
    while [ $# -gt 0 ]; do
      case "$1" in
        --pattern) pattern="$2"; shift ;;
        --dir) dir="$2"; shift ;;
      esac
      shift
    done
    cp "$STUB_PAYLOAD" "$dir/$pattern"
    ;;
  "attestation verify")
    shift 3
    repo="" signer=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --repo) repo="$2"; shift ;;
        --signer-workflow) signer="$2"; shift ;;
      esac
      shift
    done
    [ "$repo" = "$STUB_REPO" ] || { echo "attestation does not belong to $repo" >&2; exit 1; }
    [ "$signer" = "$STUB_SIGNER" ] || { echo "signer is $STUB_SIGNER, not $signer" >&2; exit 1; }
    ;;
  *) echo "stub gh: unexpected $*" >&2; exit 99 ;;
esac
SH
chmod +x "$sandbox/bin/gh"

run() { # <attesting repo> <signer workflow>
    PATH="$sandbox/bin:$PATH" STUB_PAYLOAD="$sandbox/payload" \
        STUB_REPO="$1" STUB_SIGNER="$2" \
        bash "$tap/.github/scripts/verify-release.sh" example-tool 1.2.3 \
        > "$sandbox/out" 2>&1
}

own="$repo/.github/workflows/release.yml"
shared="antimatter-studios/rust-fs-core/.github/workflows/release-cli.yml"

if run "$repo" "$own"; then
    ok "a tarball signed by the project's own release.yml is accepted"
else
    fail "a tarball signed by the project's own release.yml was refused:"; cat "$sandbox/out" >&2
fi

if run "$repo" "$shared"; then
    ok "a tarball signed by rust-fs-core's release-cli.yml is accepted"
else
    fail "a tarball signed by rust-fs-core's release-cli.yml was refused:"; cat "$sandbox/out" >&2
fi

for other in \
    "someone-else/rust-fs-core/.github/workflows/release-cli.yml" \
    "$repo/.github/workflows/ci.yml" \
    "antimatter-studios/rust-fs-core/.github/workflows/release.yml"; do
    if run "$repo" "$other"; then
        fail "a tarball signed by $other was accepted"
    else
        ok "a tarball signed by $other is refused"
    fi
done

# The accepted signer, but the attestation belongs to another repository.
if run "someone-else/example-tool" "$shared"; then
    fail "an attestation from another repository was accepted"
else
    ok "an attestation from another repository is refused"
fi

[ "$fails" -eq 0 ] && echo "test-verify-release.sh: all checks passed"
exit $(( fails > 0 ))
