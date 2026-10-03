# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsNtfs < Formula
  desc "Pure-Rust NTFS filesystem tools"
  homepage "https://github.com/christhomas/rust-fs-ntfs"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/christhomas/rust-fs-ntfs/releases/download/v#{version}/am-fs-ntfs-#{version}-darwin-arm64.tar.gz"
      sha256 "5e2bfb1d910a4bc34b8f64b416637e9bfb24fd2963321c8511a39ea45e198285"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/christhomas/rust-fs-ntfs/releases/download/v#{version}/am-fs-ntfs-#{version}-linux-x86_64.tar.gz"
      sha256 "5cd8d8253b682fb66769529a32344745a96fd9dc67c99aec63a4e771c1c7205f"
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
    image = testpath/"disk.img"
    system bin/"mkfs.ntfs", "--size", "16M", "--label", "BREW", image
    # The boot sector's OEM ID, at offset 3.
    assert_equal "NTFS    ", File.binread(image, 8, 3)
    # A file written through the tool reads back, and the volume checks clean.
    pipe_output("#{bin}/fs.ntfs #{image} write /greeting", "hello", 0)
    assert_equal "hello", shell_output("#{bin}/fs.ntfs #{image} read /greeting")
    system bin/"fsck.ntfs", image
  end
end
