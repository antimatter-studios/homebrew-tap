#!/usr/bin/env python3
"""Rewrite the sha256 belonging to one platform of a formula or cask.

    set-sha256.py <file> <platform-token> <sha256>

The platform token (darwin-arm64, linux_amd64, …) is the string that appears in that
platform's url line. The sha256 to replace is the one ADJACENT to it — casks put sha256
before url, formulae after, and `brew style` enforces each, so neither order can be
assumed.

This replaced a `sed "/${platform}/{n;s|sha256 ...|}"` in tap-sync, which always took
the line AFTER the url. Against a cask that rewrote the wrong line or none at all and
left a stale checksum in place. Nothing downstream would notice: the file still parses,
still has a plausible-looking hash, and the mistake surfaces on a user's machine when
`brew install` refuses the download it just made.

Exits non-zero if the file does not have the shape it expects, so a sync fails loudly
rather than publishing something wrong.
"""

import re
import sys


def main(argv):
    if len(argv) != 4:
        sys.exit(__doc__)

    path, platform, sha = argv[1:4]

    if not re.fullmatch(r"[0-9a-f]{64}", sha):
        sys.exit(f"{sha!r} is not a sha256 digest")

    with open(path) as fh:
        lines = fh.read().split("\n")

    urls = [i for i, line in enumerate(lines) if platform in line and "url " in line]
    if len(urls) != 1:
        sys.exit(
            f"expected exactly one url line containing {platform!r} in {path}, "
            f"found {len(urls)}"
        )

    i = urls[0]
    for j in (i - 1, i + 1):
        if 0 <= j < len(lines) and re.search(r'sha256 "', lines[j]):
            lines[j] = re.sub(r'sha256 "[^"]*"', f'sha256 "{sha}"', lines[j])
            with open(path, "w") as fh:
                fh.write("\n".join(lines))
            return
    sys.exit(f"no sha256 stanza beside the {platform} url in {path}")


if __name__ == "__main__":
    main(sys.argv)
