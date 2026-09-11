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
  version "2.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
      sha256 "d43eb50cf7eced10ab6f52b983f17fac6cd2772a52a8cf12720436db3b6ba5f3"
    end
    on_intel do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
      sha256 "18f9d9c8ca3f2ba75bd4a5b8d750fa9f90424d9098be1da17dee59ac736d5d20"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
      sha256 "36bdf1a70e5e78df73cab45561043e440b158eb50d2954687fb5e05a2e484622"
    end
    on_intel do
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
      sha256 "8ad1e515660b53fa69ea10254b204a2b93488882eed6042147d1b8c115250c2f"
    end
  end

  def install
    bin.install "ddt"
  end

  def caveats
    <<~EOS
      Replacing the ddt cask? Remove it and clear the cached download. Homebrew
      tracks casks and formulae separately, so the cask's symlink would shadow this
      one — and it deliberately quarantines cask downloads, so reusing that cached
      tarball hands the extracted binary a quarantine attribute and macOS refuses
      to run it:

        brew uninstall --cask ddt
        rm -f "$(brew --cache)/ddt--"*.tar.gz
        brew install antimatter-studios/tap/ddt
    EOS
  end

  test do
    # `ddt --version` prints "ddt 2.2.2", with no v prefix.
    assert_match version.to_s, shell_output("#{bin}/ddt --version")
  end
end
