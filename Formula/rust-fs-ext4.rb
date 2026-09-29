# typed: false
# frozen_string_literal: true

class RustFsExt4 < Formula
  desc "Pure-Rust ext4 filesystem tools, starting with mkfs.ext4"
  homepage "https://github.com/christhomas/rust-fs-ext4"
  version "0.5.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/christhomas/rust-fs-ext4/releases/download/v#{version}/am-fs-ext4-#{version}-darwin-arm64.tar.gz"
      sha256 "81bc8220741c5a3b46e8d13f36ec2c862673637339199dd15a8a9664f3a4751d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/christhomas/rust-fs-ext4/releases/download/v#{version}/am-fs-ext4-#{version}-linux-x86_64.tar.gz"
      sha256 "c79c105da26dc3a8923f96f4d11fa68ae6f29d490c27a68bda04b87f79d55c45"
    end
  end

  def install
    bin.install "mkfs.ext4"
  end

  def caveats
    <<~EOS
      Installed with:
        brew install antimatter-studios/tap/rust-fs-ext4

      mkfs.ext4 formats a block device or a pre-sized image file:
        truncate -s 64M disk.img
        mkfs.ext4 disk.img

      The mkfs.ext4 on your PATH is this one; `mkfs.ext4 --version` says
      "mkfs.ext4 (fs-ext4) #{version}". Homebrew's e2fsprogs is keg-only, so
      it never links its own mkfs.ext4 and both can be installed. The
      e2fsprogs one stays reachable at:
        $(brew --prefix e2fsprogs)/sbin/mkfs.ext4
    EOS
  end

  test do
    # Says which mkfs.ext4 this is, so it cannot be mistaken for e2fsprogs'.
    assert_equal "mkfs.ext4 (fs-ext4) #{version}", shell_output("#{bin}/mkfs.ext4 --version").strip

    image = testpath/"ext4.img"
    File.open(image, "wb") { |f| f.truncate(16 * 1024 * 1024) }
    system bin/"mkfs.ext4", "-q", image

    # The superblock starts 1024 bytes in, and s_magic is 56 bytes into it.
    assert_equal 0xEF53, File.binread(image, 2, 1080).unpack1("v")
  end
end
