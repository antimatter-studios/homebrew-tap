# typed: false
# frozen_string_literal: true

class TroveCli < Formula
  desc "KeePassXC-compatible secrets CLI (trove) + daemon (troved)"
  homepage "https://github.com/antimatter-studios/trove"
  version "0.21.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-arm64.tar.gz"
      sha256 "3a42e51cd8cb9587f97850abee72c5668d0921e23a4bf8a84d9aa2f21e51a321"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-x86_64.tar.gz"
      sha256 "b25902bad7327b997b074e37d9a74fcd9bf054bc6f346ead8f2dd5ada8e9c4d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-arm64.tar.gz"
      sha256 "d6f561385414b9d74a8e23d1e63606e46888dcde5a2aeeda1091df26eeb8bb0a"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-x86_64.tar.gz"
      sha256 "4291b114ead1e8f88e7bef202618e8742f52f0e8e154e41fecbc78f6a67f7550"
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
