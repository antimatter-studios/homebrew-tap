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
    # Every executable at the tarball's top level rather than one named file,
    # so a release that adds a tool needs no change here; share/ (man pages,
    # completions) is installed as-is once a release carries one.
    bin.install Dir["*"].select { |f| File.file?(f) && File.executable?(f) }
    prefix.install "share" if File.directory?("share")
  end

  def caveats
    <<~EOS
      Installed by: brew install antimatter-studios/tap/rust-fs-ext4
      The mkfs.ext4 on your PATH is this one: `mkfs.ext4 --version` says "mkfs.ext4 (fs-ext4) #{version}".
      e2fsprogs is keg-only, so its mkfs.ext4 stays at:
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
