class Virtiofsd < Formula
  desc "Virtio-fs vhost-user device daemon (macOS port)"
  homepage "https://github.com/christhomas/virtiofsd"
  license any_of: ["Apache-2.0", "BSD-3-Clause"]

  version "1.13.3"
  url "https://github.com/antimatter-studios/homebrew-tap/releases/download/virtiofsd-v#{version}/virtiofsd-#{version}-darwin-arm64.tar.gz"
  sha256 "fa37691b21db34733edd88f9e7cfed64b18684cd10f063cdc390030985bb5078"

  depends_on :macos
  depends_on arch: :arm64

  def install
    bin.install "virtiofsd"
  end

  def caveats
    <<~EOS
      virtiofsd requires QEMU built with vhost-user-fs support.
      The standard Homebrew QEMU does not include this.

      Install the patched QEMU from this tap:
        brew install antimatter-studios/tap/qemu

      Usage:
        # Start virtiofsd
        virtiofsd --socket-path=/tmp/virtiofsd.sock \\
                  --shared-dir=/path/to/share \\
                  --sandbox none \\
                  --inode-file-handles=never

        # Start QEMU with virtiofs device (see qemu-virtiofs caveats)
    EOS
  end

  test do
    assert_match "virtiofsd", shell_output("#{bin}/virtiofsd --help 2>&1")

    qemu_bin = which("qemu-system-aarch64")
    if qemu_bin
      devices = shell_output("#{qemu_bin} -device help 2>&1")
      assert_match "vhost-user-fs", devices,
        "QEMU is installed but lacks vhost-user-fs support. " \
        "Install a compatible QEMU: brew install antimatter-studios/tap/qemu"
    end
  end
end
