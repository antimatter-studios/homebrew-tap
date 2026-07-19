# typed: false
# frozen_string_literal: true

class TroveCli < Formula
  desc "KeePassXC-compatible secrets CLI (trove) + daemon (troved)"
  homepage "https://github.com/antimatter-studios/trove"
  version "0.6.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-arm64.tar.gz"
      sha256 "01031a3dc2e426a7a12ed10cb18884200bf8084a938f576beb55eb3921f81fbc"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-x86_64.tar.gz"
      sha256 "b0565f326605fd2d3907fbdfdd05d98ec5cea1ecc7f53fab21ac0d6e0493e43f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-arm64.tar.gz"
      sha256 "3e77089968d0363ed327c7443954f7f6903ce2a0a9ab3de15f2fb037e06f72be"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-x86_64.tar.gz"
      sha256 "3411f5c168bc9c07d4f3ab00aad628ca582301b793114020fd22aa83f4ea7f17"
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
