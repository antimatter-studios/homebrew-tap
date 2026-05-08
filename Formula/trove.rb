# typed: false
# frozen_string_literal: true

class Trove < Formula
  desc "KeePassXC-compatible secrets daemon for developer machines"
  homepage "https://github.com/antimatter-studios/trove"
  url "https://github.com/antimatter-studios/trove/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "f47d6f5f19222457f8fc284e5f37377d8025d99ec4eaa6ccd4a4a2d2f6c60d91"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/antimatter-studios/trove.git", branch: "main"

  depends_on "rust" => :build

  def install
    # Build both binaries from the workspace. Each crate is a separate
    # cargo target; install them one at a time to keep `target/` isolated
    # per crate, which matches `cargo install --path` semantics.
    system "cargo", "install", *std_cargo_args(path: "crates/trove-cli")
    system "cargo", "install", *std_cargo_args(path: "crates/troved")
  end

  def caveats
    <<~EOS
      Two binaries installed:
        trove   — CLI client
        troved  — long-running daemon

      Quickstart (after `brew install`):
        troved &
        trove unlock ~/path/to/your.kdbx
        export SSH_AUTH_SOCK="$(trove agent socket)"
        ssh-add -L

      For GPG signing (git commit -S):
        ln -sf "$(trove gpg-agent socket)" "${GNUPGHOME:-$HOME/.gnupg}/S.gpg-agent"

      `troved` is not installed as a launchd service yet (planned for a
      future release). Start it manually for now, or run inside a
      terminal/tmux session.

      Full quickstart + threat model:
        https://github.com/antimatter-studios/trove#quickstart
    EOS
  end

  test do
    # `trove --version` exercises clap's auto-generated --version path.
    assert_match version.to_s, shell_output("#{bin}/trove --version")
    # `troved` exists and is executable.
    assert_predicate bin/"troved", :exist?
    assert_predicate bin/"troved", :executable?
  end
end
