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
      sha256 "b85020f52c9afe3e0f65cdf0ffa7ad01253306b95edb6a9a8079310653ed583a"
    end
    on_intel do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-darwin-x86_64.tar.gz"
      sha256 "3321758da120f566156422dc066d7822b377d999439b787dc60c4cfbf37297b1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-linux-arm64.tar.gz"
      sha256 "0f737f732bb9daee72a70aeaffff0697f0a24f91fd229066e28c8d3abf37aae3"
    end
    on_intel do
      url "https://github.com/antimatter-studios/deionizer/releases/download/v#{version}/deionizer-#{version}-linux-x86_64.tar.gz"
      sha256 "4a15a8e6e8c20df5a091cd006db3f40c7bdab8b04185c969b5c973a14b3f7a07"
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
