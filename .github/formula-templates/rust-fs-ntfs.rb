# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsNtfs < Formula
  desc "Pure-Rust NTFS filesystem tools"
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
    notes = opt_prefix/"share/rust-fs-ntfs/CAVEATS"
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
    image = testpath/"ntfs.img"
    File.open(image, "wb") { |f| f.truncate(16 * 1024 * 1024) }
    system bin/"mkfs.ntfs", "-q", image
    # The boot sector's OEM ID, and its end-of-sector signature.
    assert_equal "NTFS    ", File.binread(image, 8, 3)
    assert_equal "\x55\xAA".b, File.binread(image, 2, 510)
  end
end
