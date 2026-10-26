# typed: false
# frozen_string_literal: true

class TroveCli < Formula
  desc "KeePassXC-compatible secrets CLI (trove) + daemon (troved)"
  homepage "https://github.com/antimatter-studios/trove"
  version "0.27.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-arm64.tar.gz"
      sha256 "8c55854e2e77ca507178f863b13a15b6655fd0d69276cad5cea499ff8eadd91e"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-x86_64.tar.gz"
      sha256 "bf8ff9776b64032c38dbda6153ab60c06ef110afff3e6a2b6e68eb49324891e3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-arm64.tar.gz"
      sha256 "6abd1bc997a25dca183a580d6478cfff9085f7f0c505eb915e5867f09331d99a"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-x86_64.tar.gz"
      sha256 "9f5df1ae327fa048229af5c42839944d7ee1331512e50cefa6cf94ce6fae7446"
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
