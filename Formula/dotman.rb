# typed: false
# frozen_string_literal: true

# Maintained by this tap, not by the project that ships dotman. Only the version
# and the four checksums are rewritten by "Sync formulae from releases" —
# everything else here is edited by hand.
#
# Was Casks/dotman.rb, written straight into this repository by dotman's own
# release pipeline. christhomas/dotman drops that push side; this takes over the
# file. A formula rather than a cask, for the reasons in Formula/ddt.rb and the
# check in ci.yml: nothing quarantines what a formula installs.
class Dotman < Formula
  desc "Git-backed dotfile workflow manager"
  homepage "https://github.com/christhomas/dotman"
  version "0.2.0"
  # The project had no LICENSE file; christhomas/dotman#1 adds MIT, and must land
  # before this does, or this stanza claims something the repository does not say.
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/christhomas/dotman/releases/download/v#{version}/dotman_#{version}_darwin_arm64.tar.gz"
      sha256 "a77ecb23762bbac25df001dccf3e22a2384faa0965e5190e95f423fe7adaa1fe"
    end
    on_intel do
      url "https://github.com/christhomas/dotman/releases/download/v#{version}/dotman_#{version}_darwin_amd64.tar.gz"
      sha256 "1d8146ff4305da8aa56b66afd5814e3c92e8085589aacb319479211b05517544"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/christhomas/dotman/releases/download/v#{version}/dotman_#{version}_linux_arm64.tar.gz"
      sha256 "c11edb072131c8af9db7a26c3be23408b6101add3f9c5bd49e730dcfc8abf644"
    end
    on_intel do
      url "https://github.com/christhomas/dotman/releases/download/v#{version}/dotman_#{version}_linux_amd64.tar.gz"
      sha256 "fc6a0332503174b35271e296ad783b374c658b25e628ffb82b6c887cb91724c3"
    end
  end

  def install
    bin.install "dotman"
  end

  def caveats
    <<~EOS
      Replacing the dotman cask? Remove it and clear the cached download, or the
      binary arrives quarantined and macOS refuses to run it — Homebrew
      deliberately quarantines cask downloads, and the cached tarball is reused:

        brew uninstall --cask dotman
        rm -f "$(brew --cache)/dotman--"*.tar.gz
        brew install antimatter-studios/tap/dotman
    EOS
  end

  test do
    # `dotman version`, not `--version`, which the CLI rejects as an unknown flag.
    assert_match version.to_s, shell_output("#{bin}/dotman version")
  end
end
