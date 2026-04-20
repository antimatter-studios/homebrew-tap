class Qemu < Formula
  desc "QEMU emulator with vhost-user-fs support for macOS"
  homepage "https://www.qemu.org/"
  license "GPL-2.0-only"

  version "10.2.2"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/qemu-v#{version}/qemu-#{version}-darwin-arm64.tar.gz"
      sha256 "94255a013702e972f43dff04b51e66f67e08953839a58e1ab56d3d6b36f6f068"
    end
    on_intel do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/qemu-v#{version}/qemu-#{version}-darwin-x86_64.tar.gz"
      sha256 "ee156046c78e10f20f19a83b5435911a5c305e9cc7a4eeb8afd4bc8ac3eebf25"
    end
  end

  depends_on :macos
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
    qemu_bin = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    machine_flags = Hardware::CPU.arm? ? "-M virt,highmem=on" : "-M q35"
    bios_line = Hardware::CPU.arm? ? "-bios #{share}/qemu/edk2-aarch64-code.fd \\\n          " : ""

    <<~EOS
      This is QEMU built with --enable-vhost-user for virtiofs support.
      It conflicts with the standard Homebrew QEMU formula.

      To verify you have the virtiofs-enabled build:
        #{qemu_bin} -device help 2>&1 | grep vhost-user-fs

      Usage with virtiofsd:
        # Terminal 1: Start virtiofsd
        virtiofsd --socket-path=/tmp/virtiofsd.sock \\
                  --shared-dir=$HOME/shared \\
                  --sandbox none --inode-file-handles=never

        # Terminal 2: Start QEMU
        #{qemu_bin} \\
          #{machine_flags} -accel hvf -cpu host -m 4G -smp 4 \\
          #{bios_line}-drive if=virtio,file=disk.qcow2 \\
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
    qemu_bin = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    assert_match "vhost-user-fs", shell_output("#{bin}/#{qemu_bin} -device help 2>&1")

    virtiofsd_bin = which("virtiofsd")
    if virtiofsd_bin
      assert_match "virtiofsd", shell_output("#{virtiofsd_bin} --version 2>&1"),
        "virtiofsd is installed but not runnable."
    end
  end
end
