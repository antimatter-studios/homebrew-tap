# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsSquashfs < Formula
  desc "Pure-Rust SquashFS filesystem tools"
  homepage "https://github.com/antimatter-studios/rust-fs-squashfs"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-fs-squashfs/releases/download/v#{version}/rust-fs-squashfs-#{version}-darwin-arm64.tar.gz"
      sha256 "086cd289fcb80f2261b4392a202f3c6b15c4e5beea88bee1143950e8a35038cb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-fs-squashfs/releases/download/v#{version}/rust-fs-squashfs-#{version}-linux-x86_64.tar.gz"
      sha256 "8b550dc5717f54b65b313c92f628b61eed2847c9ee1c39fa4ceea71a99793986"
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
    notes = opt_prefix/"share/rust-fs-squashfs/CAVEATS"
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
    image = testpath/"not.img"
    File.binwrite(image, "\0" * 4096)
    # A file without the SquashFS magic is refused, status 1.
    assert_match "not a SquashFS image", shell_output("#{bin}/fs.squashfs #{image} get 2>&1", 1)
    # SquashFS is read-only: a write verb is refused, status 3.
    assert_match "read-only", shell_output("#{bin}/fs.squashfs #{image} mkdir /a 2>&1", 3)
  end
end
