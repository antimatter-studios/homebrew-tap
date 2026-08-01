# typed: false
# frozen_string_literal: true

class Deionizer < Formula
  desc "Recover readable PHP source from ionCube-encoded code you own"
  homepage "https://github.com/antimatter-studios/deionizer"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-darwin-arm64.tar.gz"
      sha256 "fe9904776dc036a783bc900694d88593ad614fdf9e28e3b6842f427d471482ae"
    end
    on_intel do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-darwin-x86_64.tar.gz"
      sha256 "fd9757e36ed6670df8ad8bf92e0fa815e1c338d6902e1e732b3d7989db44c35f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-linux-arm64.tar.gz"
      sha256 "706bcbb972694872091446e0b25ad55ca9d5a487c56fed90a377ddb03a9e8250"
    end
    on_intel do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-linux-x86_64.tar.gz"
      sha256 "2e386ef57922799502bdb3a0c0ddb7b2827c9cc05bc6d1c90aa2dda3c5d96332"
    end
  end

  def install
    bin.install "deionizer"
  end

  def caveats
    <<~EOS
      deionizer recovers readable PHP from ionCube-encoded code you own, by running
      each file through a version-matched loader in a throwaway Docker container. It
      does not decrypt or crack anything, and bundles no vendor loader or key.

      It needs Docker running; you supply the loader download URL and, for deep
      decode, the decode-extension source.

        deionizer help
        deionizer --skeleton process /path/to/encoded/src   # exact signatures, no bodies
        deionizer decode <file> > recovered.php             # one file to stdout
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deionizer version")
    assert_match "decode", shell_output("#{bin}/deionizer help")
  end
end
