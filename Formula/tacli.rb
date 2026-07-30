# typed: false
# frozen_string_literal: true

# Maintained by this tap, not by the project that ships tacli. Only the version
# and the four checksums are rewritten by "Sync formulae from releases" —
# everything else here is edited by hand.
#
# Was Casks/tacli.rb, written straight into this repository by teamagentica's own
# release pipeline. antimatter-studios/teamagentica drops that push side; this
# takes over the file. A formula rather than a cask, for the reasons in
# Formula/ddt.rb and the check in ci.yml: nothing quarantines what a formula
# installs.
#
# tacli is one binary out of a larger repository, which is why the release tag and
# the tool's version move together but the asset name is tacli's own.
class Tacli < Formula
  desc "Team Agentica CLI — inspect and manage the platform"
  homepage "https://github.com/antimatter-studios/teamagentica"
  version "0.2.0"
  # The project had no LICENSE file; antimatter-studios/teamagentica#1 adds MIT,
  # and must land before this does, or this stanza claims something the repository
  # does not say.
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/teamagentica/releases/download/v#{version}/tacli_#{version}_darwin_arm64.tar.gz"
      sha256 "cebebfdc5c7979ef971b4aa02a19cb7306ffc545d36d0d2791b215be99805e77"
    end
    on_intel do
      url "https://github.com/antimatter-studios/teamagentica/releases/download/v#{version}/tacli_#{version}_darwin_amd64.tar.gz"
      sha256 "d28a90fa405fbde69522d7b241104e7ef05fb00162e0b47338074dc7c89e6684"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/teamagentica/releases/download/v#{version}/tacli_#{version}_linux_arm64.tar.gz"
      sha256 "4e6f0dd98cbac407ed2d02b801de2045b420694040847bc26cba7edd634e2f32"
    end
    on_intel do
      url "https://github.com/antimatter-studios/teamagentica/releases/download/v#{version}/tacli_#{version}_linux_amd64.tar.gz"
      sha256 "033bb075212e60ce26d5a0df2ec41eb8bc979f072999611c1663d0967adb6ec6"
    end
  end

  def install
    bin.install "tacli"
  end

  def caveats
    <<~EOS
      Replacing the tacli cask? Remove it and clear the cached download, or the
      binary arrives quarantined and macOS refuses to run it — Homebrew
      deliberately quarantines cask downloads, and the cached tarball is reused:

        brew uninstall --cask tacli
        rm -f "$(brew --cache)/tacli--"*.tar.gz
        brew install antimatter-studios/tap/tacli
    EOS
  end

  test do
    # `tacli version`, not `--version`, which the CLI rejects as an unknown flag.
    # The output carries ANSI colour even when not attached to a terminal, so this
    # matches the digits rather than a whole line.
    assert_match version.to_s, shell_output("#{bin}/tacli version")
  end
end
