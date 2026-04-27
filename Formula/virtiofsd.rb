class Virtiofsd < Formula
  desc "Virtio-fs vhost-user device daemon (macOS port)"
  homepage "https://github.com/christhomas/virtiofsd"
  license any_of: ["Apache-2.0", "BSD-3-Clause"]

  version "1.13.7"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/virtiofsd-v#{version}/virtiofsd-#{version}-darwin-arm64.tar.gz"
      sha256 "fedd4b3590fa1944c0a16fd4b67b49f6af8e098b3f48fa5dabddc4e1d61d24ff"
    end
    on_intel do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/virtiofsd-v#{version}/virtiofsd-#{version}-darwin-x86_64.tar.gz"
      sha256 "a5be5a1a14f35a54e45303d032c9926dc2d2f507b375e95d0b4414ba54356f9d"
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
