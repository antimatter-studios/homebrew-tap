# typed: false
# frozen_string_literal: true

class RustFsNtfs < Formula
  desc "Pure-Rust NTFS filesystem tools, starting with mkfs.ntfs"
  homepage "https://github.com/christhomas/rust-fs-ntfs"
  version "0.0.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/christhomas/rust-fs-ntfs/releases/download/v#{version}/am-fs-ntfs-#{version}-darwin-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/christhomas/rust-fs-ntfs/releases/download/v#{version}/am-fs-ntfs-#{version}-linux-x86_64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  conflicts_with "ntfs-3g", because: "both install mkfs.ntfs"

  def install
    # Every executable at the tarball's top level rather than one named file,
    # so a release that adds a tool needs no change here; share/ (man pages,
    # completions) is installed as-is once a release carries one.
    bin.install Dir["*"].select { |f| File.file?(f) && File.executable?(f) }
    prefix.install "share" if File.directory?("share")
  end

  def caveats
    <<~EOS
      Installed by: brew install antimatter-studios/tap/rust-fs-ntfs
      The mkfs.ntfs on your PATH is this one: `mkfs.ntfs --version` says "mkfs.ntfs (am-fs-ntfs) #{version}".
    EOS
  end

  test do
    # Says which mkfs.ntfs this is, so it cannot be mistaken for ntfs-3g's.
    assert_equal "mkfs.ntfs (am-fs-ntfs) #{version}", shell_output("#{bin}/mkfs.ntfs --version").strip

    image = testpath/"ntfs.img"
    File.open(image, "wb") { |f| f.truncate(16 * 1024 * 1024) }
    system bin/"mkfs.ntfs", "-q", image

    # The boot sector's OEM ID, and its end-of-sector signature.
    assert_equal "NTFS    ", File.binread(image, 8, 3)
    assert_equal "\x55\xAA".b, File.binread(image, 2, 510)
  end
end
