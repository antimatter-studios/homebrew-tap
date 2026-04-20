class Virtiofsd < Formula
  desc "Virtio-fs vhost-user device daemon (macOS port)"
  homepage "https://github.com/christhomas/virtiofsd"
  license any_of: ["Apache-2.0", "BSD-3-Clause"]

  version "1.13.6"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/virtiofsd-v#{version}/virtiofsd-#{version}-darwin-arm64.tar.gz"
      sha256 "d6cacb888adcf02c10f03f283cd6f7684a4d93a2fb45a756a1b6b4824988a649"
    end
    on_intel do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/virtiofsd-v#{version}/virtiofsd-#{version}-darwin-x86_64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  depends_on :macos

  def install
    bin.install "virtiofsd"
  end

  def caveats
    msg = ""

    qemu_name = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    qemu_bin = which(qemu_name)
    if qemu_bin.nil?
      msg += <<~EOS
        WARNING: QEMU is not installed. virtiofsd requires QEMU built with
        vhost-user-fs support. The standard Homebrew QEMU does not include this.

        Install the compatible QEMU from this tap:
          brew install antimatter-studios/tap/qemu

      EOS
    elsif !`#{qemu_bin} -device help 2>&1`.include?("vhost-user-fs")
      msg += <<~EOS
        WARNING: Your installed QEMU lacks vhost-user-fs support.
        virtiofsd will not work with it.

        Install the compatible QEMU from this tap:
          brew install antimatter-studios/tap/qemu

      EOS
    end

    msg += <<~EOS
      Usage:
        virtiofsd --socket-path=/tmp/virtiofsd.sock \\
                  --shared-dir=/path/to/share \\
                  --sandbox none \\
                  --inode-file-handles=never
    EOS

    msg
  end

  test do
    assert_match "virtiofsd", shell_output("#{bin}/virtiofsd --help 2>&1")

    qemu_name = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    qemu_bin = which(qemu_name)
    if qemu_bin
      devices = shell_output("#{qemu_bin} -device help 2>&1")
      assert_match "vhost-user-fs", devices,
        "QEMU is installed but lacks vhost-user-fs support. " \
        "Install a compatible QEMU: brew install antimatter-studios/tap/qemu"
    end
  end
end
