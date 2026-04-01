class QemuVirtiofs < Formula
  desc "QEMU with vhost-user-fs support for macOS virtiofs folder sharing"
  homepage "https://www.qemu.org/"
  license "GPL-2.0-only"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/qemu-virtiofs-v#{version}/qemu-virtiofs-#{version}-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
    on_intel do
      url "https://github.com/antimatter-studios/homebrew-tap/releases/download/qemu-virtiofs-v#{version}/qemu-virtiofs-#{version}-darwin-amd64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  version "10.2.2"

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
    share.install Dir["share/*"] if File.directory?("share")

    # Install real binaries with .real suffix, wrap with a notice script
    Dir["bin/qemu-system-*"].each do |qemu_bin|
      name = File.basename(qemu_bin)
      bin.install qemu_bin => "#{name}.real"

      # Wrapper that shows a one-time notice, then execs the real binary
      (bin/name).write <<~SH
        #!/bin/bash
        NOTICE_FILE="$HOME/.qemu-virtiofs-noticed"
        if [ ! -f "$NOTICE_FILE" ]; then
          echo "==> Note: This is qemu-virtiofs from antimatter-studios/tap" >&2
          echo "==> QEMU #{version} built with --enable-vhost-user for virtiofs support" >&2
          echo "==> This notice will only appear once" >&2
          echo "" >&2
          touch "$NOTICE_FILE"
        fi
        exec "#{bin}/#{name}.real" "$@"
      SH
    end

    # Install any other binaries directly
    Dir["bin/*"].each do |other_bin|
      name = File.basename(other_bin)
      next if name.start_with?("qemu-system-")
      bin.install other_bin
    end
  end

  def caveats
    <<~EOS
      This is QEMU patched with --enable-vhost-user for virtiofs support.
      It conflicts with the standard Homebrew QEMU formula.

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
  end
end
