#!/usr/bin/env python3
"""Every filesystem-driver formula has the shape of the driver template.

    check-driver-formulae.py [file ...]

With no arguments, checks Formula/rust-fs-*.rb, Formula/rust-img-*.rb and the
pre-release templates for them in .github/formula-templates/.

A driver formula installs whatever its release tarball holds and shows the
CAVEATS the release shipped, so it has nothing of its own to say beyond
where its tarballs are. Allowed to differ from .github/driver-formula/
template.rb: the class name, desc, homepage, license, version, url and
sha256 lines, the repository name in the CAVEATS path (which must be the
file's own name), and the lines after the test block's "Specific to this
formula" marker. Anything else is drift -- a tool named here, caveat text
written here, an install step one driver has and the others lack -- and it
fails, printing the difference.
"""

import difflib
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TEMPLATE = os.path.join(ROOT, ".github", "driver-formula", "template.rb")
MARKER = "    # Specific to this formula:"

VARIABLE = [
    (re.compile(r"^class \w+ < Formula$"), "class NAME < Formula"),
    (re.compile(r'^  desc ".*"$'), "  desc DESC"),
    (re.compile(r'^  homepage ".*"$'), "  homepage HOMEPAGE"),
    (re.compile(r"^  license .*$"), "  license LICENSE"),
    (re.compile(r'^  version ".*"$'), "  version VERSION"),
    (re.compile(r'^(\s+)url ".*"$'), r"\1url URL"),
    (re.compile(r'^(\s+)sha256 ".*"$'), r"\1sha256 SHA256"),
]


def shape(path, name):
    """The file's lines with everything allowed to vary replaced by a token."""
    with open(path) as fh:
        lines = fh.read().split("\n")

    # Everything before the class: the template explains itself there, and a
    # formula carries a one-line pointer back to it.
    start = next((i for i, l in enumerate(lines) if l.startswith("class ")), 0)
    lines = lines[start:]

    out, specific = [], False
    for line in lines:
        if specific:
            if line == "  end":
                specific = False
            else:
                continue
        if line == MARKER:
            specific = True
        for pattern, token in VARIABLE:
            line = pattern.sub(token, line)
        line = line.replace(f"share/{name}/CAVEATS", "share/REPO/CAVEATS")
        out.append(line)
    return out


def main(argv):
    files = argv[1:] or sorted(
        glob.glob(os.path.join(ROOT, "Formula", "rust-fs-*.rb"))
        + glob.glob(os.path.join(ROOT, "Formula", "rust-img-*.rb"))
        + glob.glob(os.path.join(ROOT, ".github", "formula-templates", "rust-fs-*.rb"))
        + glob.glob(os.path.join(ROOT, ".github", "formula-templates", "rust-img-*.rb"))
    )
    if not files:
        sys.exit("no driver formulae found; the glob or the layout is wrong")

    want = shape(TEMPLATE, "REPO")
    failed = 0
    for path in files:
        name = os.path.basename(path)[: -len(".rb")]
        got = shape(path, name)
        rel = os.path.relpath(path, ROOT)
        if got == want:
            print(f"  ok  {rel}")
            continue
        failed += 1
        print(
            f"::error file={rel}::{rel} differs from the driver template",
            file=sys.stderr,
        )
        sys.stderr.writelines(
            l + "\n"
            for l in difflib.unified_diff(
                want, got, "driver-formula/template.rb", rel, lineterm=""
            )
        )
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main(sys.argv)
