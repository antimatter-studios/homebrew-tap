class Qemu < Formula
  desc "QEMU emulator with vhost-user-fs support for macOS"
  homepage "https://www.qemu.org/"
  license "GPL-2.0-only"

  version "10.2.2"
  url "https://github.com/antimatter-studios/homebrew-tap/releases/download/qemu-v#{version}/qemu-#{version}-darwin-arm64.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"

  depends_on :macos
  depends_on arch: :arm64
  depends_on "glib"
  depends_on "gnutls"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libslirp"
  depends_on "libssh"
  depends_on "libusb"
  depends_on "lzo"
  depends_on "ncurses"
  depends_on "pixman"
  depends_on "snappy"
  depends_on "vde"
  depends_on "zstd"

  conflicts_with "qemu", because: "both install qemu-system-* binaries"

  def install
    bin.install Dir["bin/*"]
    share.install Dir["share/*"] if File.directory?("share")
  end

  def caveats
    <<~EOS
      This is QEMU built with --enable-vhost-user for virtiofs support.
      It conflicts with the standard Homebrew QEMU formula.

      To verify you have the virtiofs-enabled build:
        qemu-system-aarch64 -device help 2>&1 | grep vhost-user-fs

      Usage with virtiofsd:
        # Terminal 1: Start virtiofsd
        virtiofsd --socket-path=/tmp/virtiofsd.sock \\
                  --shared-dir=$HOME/shared \\
                  --sandbox none --inode-file-handles=never

        # Terminal 2: Start QEMU
        qemu-system-aarch64 \\
          -M virt,highmem=on -accel hvf -cpu host -m 4G -smp 4 \\
          -bios #{share}/qemu/edk2-aarch64-code.fd \\
          -drive if=virtio,file=disk.qcow2 \\
          -object memory-backend-file,id=mem,size=4G,mem-path=/tmp/qemu-mem,share=on \\
          -numa node,memdev=mem \\
          -chardev socket,id=vfs,path=/tmp/virtiofsd.sock \\
          -device vhost-user-fs-pci,chardev=vfs,tag=myfs \\
          -nographic

        # Inside guest VM:
        mount -t virtiofs myfs /mnt
    EOS
  end

  test do
    assert_match "vhost-user-fs", shell_output("#{bin}/qemu-system-aarch64 -device help 2>&1")

    virtiofsd_bin = which("virtiofsd")
    if virtiofsd_bin
      assert_match "virtiofsd", shell_output("#{virtiofsd_bin} --version 2>&1"),
        "virtiofsd is installed but not runnable."
    end
  end
end
