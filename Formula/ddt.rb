# typed: false
# frozen_string_literal: true

# Maintained by this tap, not by the project that ships ddt. Only the version and
# the four checksums are rewritten by "Sync formulae from releases" — everything
# else here is edited by hand.
#
# Was Casks/ddt.rb. A cask made sense while ddt's own pipeline generated the file
# with goreleaser, which had deprecated its formula writer; once this tap took
# over the file that constraint went away, and a cask carried two costs a formula
# does not:
#
#   * Homebrew quarantines what a cask stages. These binaries are only ad-hoc
#     signed, so Gatekeeper killed the first run unless the cask cleared the
#     attribute in a postflight.
#   * That postflight ran `/usr/bin/xattr` unconditionally, and the cask DSL's
#     `system_command` raises on failure. On Linux, where the binary does not
#     exist and quarantine is not a thing, the install failed at that step.
#
# Nothing quarantines what a formula installs, so both problems are gone rather
# than worked around. Same shape as chore and trove-cli.
class Ddt < Formula
  desc "Docker development tools CLI"
  homepage "https://github.com/antimatter-studios/docker-dev-tools"
  version "2.2.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
      sha256 "16c46922982dc08223d27fe2fe8b2f7680f24e0f7c1aed0f90a1350ee1795c4a"
    end
    on_intel do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
      sha256 "f03aac25acdce5f9818052a279a5df76cda18391382dcbfdd428d60e0f80f82e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
      sha256 "37a6f849ddd61f25e9609190d03f17c29011aacecb68459bb809b4ab5c86232e"
    end
    on_intel do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
      sha256 "836d0726c8b69ba073a8d43738a0cdffd750baa2b4b1d28751f161c06c6e227b"
    end
  end

  def install
    bin.install "ddt"
  end

  def caveats
    <<~EOS
      Anyone who installed ddt as a cask should remove that first, because
      Homebrew tracks the two separately and the cask's symlink shadows this one:

        brew uninstall --cask ddt
        brew install antimatter-studios/tap/ddt
    EOS
  end

  test do
    # `ddt --version` prints "ddt 2.2.2", with no v prefix.
    assert_match version.to_s, shell_output("#{bin}/ddt --version")
  end
end
