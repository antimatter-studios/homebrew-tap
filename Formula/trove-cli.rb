# typed: false
# frozen_string_literal: true

class TroveCli < Formula
  desc "KeePassXC-compatible secrets CLI (trove) + daemon (troved)"
  homepage "https://github.com/antimatter-studios/trove"
  version "0.25.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-arm64.tar.gz"
      sha256 "fc384e17941876af5a14557300f62ac792a509f3862f3b6168d5e6dd0ed00a08"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-darwin-x86_64.tar.gz"
      sha256 "43566a3c81d8a3618bb83fd2411078553cfcf9193345bb9c7e63e5841e9c50d4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-arm64.tar.gz"
      sha256 "12295334415f735acb211f71848bcbaa5b2505c9420187694868203a9761b87e"
    end
    on_intel do
      url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/trove-#{version}-linux-x86_64.tar.gz"
      sha256 "248e94964349bf03adc18a879a08e8b2cc7c9b51d6df371b7b3895c708c1a5aa"
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
