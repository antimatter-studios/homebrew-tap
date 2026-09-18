# typed: false
# frozen_string_literal: true

class TroveCli < Formula
  desc "KeePassXC-compatible secrets CLI (trove) + daemon (troved)"
  homepage "https://github.com/antimatter-studios/trove"
  version "0.17.2"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-arm64.tar.gz"
      sha256 "0262a908b6b3d3ba3331aedb40126651d809a51a15c4865cf07b77415042eb86"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-x86_64.tar.gz"
      sha256 "3c01dbc00af6d38c14f5b6ed7eacf2704a8e10e03f9b7c2cace807a1e35be070"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-arm64.tar.gz"
      sha256 "6b85dfbe7deb9929bb81177a8299b10aeb499ad804d5b336b20923456fcc0414"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-x86_64.tar.gz"
      sha256 "2114189b3368b372596f48a28ff9ed5391d9266516a4e52b86073013100114df"
    end
  end

  def install
    bin.install "trove", "troved"
  end

  def caveats
    <<~EOS
      Two binaries installed:
        trove   — CLI client
        troved  — long-running daemon

      Quickstart:
        troved &
        trove unlock ~/path/to/your.kdbx
        export SSH_AUTH_SOCK="$(trove agent socket)"

      `troved` is not installed as a service; start it manually for now.
      Full quickstart + threat model:
        https://github.com/antimatter-studios/trove#quickstart
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/trove --version")
    assert_path_exists bin/"troved"
    assert_predicate bin/"troved", :executable?
  end
end
