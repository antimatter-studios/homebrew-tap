# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsExt4 < Formula
  desc "Pure-Rust ext4 filesystem tools"
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
    # A release made before the prefix layout ships its tools at the top
    # level; they belong in bin/.
    unless File.directory?("bin")
      mkdir "bin"
      mv Dir["*"].select { |f| File.file?(f) && File.executable?(f) }, "bin"
    end
    prefix.install Dir["*"]
  end

  def caveats
    notes = opt_prefix/"share/rust-fs-ext4/CAVEATS"
    notes.read if notes.exist?
  end

  test do
    # Every tool names itself, its package and this version, so none can be
    # mistaken for a same-named tool from another package.
    tools = bin.children
    refute_empty tools
    tools.each do |tool|
      name = Regexp.escape(tool.basename.to_s)
      assert_match(/\A#{name} \(\S+\) #{Regexp.escape(version.to_s)}\Z/,
                   shell_output("#{tool} --version").strip)
    end

    # Specific to this formula:
    image = testpath/"ext4.img"
    File.open(image, "wb") { |f| f.truncate(16 * 1024 * 1024) }
    system bin/"mkfs.ext4", "-q", image
    # The superblock starts 1024 bytes in, and s_magic is 56 bytes into it.
    assert_equal 0xEF53, File.binread(image, 2, 1080).unpack1("v")
  end
end
