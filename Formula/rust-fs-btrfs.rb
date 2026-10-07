# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsBtrfs < Formula
  desc "Pure-Rust Btrfs filesystem tools"
  homepage "https://github.com/antimatter-studios/rust-fs-btrfs"
  version "0.10.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-fs-btrfs/releases/download/v#{version}/rust-fs-btrfs-#{version}-darwin-arm64.tar.gz"
      sha256 "23a167280deb250a10fef40c3d8319f6533e492bfd7971c6750f1048a71ae788"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-fs-btrfs/releases/download/v#{version}/rust-fs-btrfs-#{version}-linux-x86_64.tar.gz"
      sha256 "49c214ea50b89624ddf112548e31aec3966a49f5dc90946b7eb6961bec678b9a"
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
    notes = opt_prefix/"share/rust-fs-btrfs/CAVEATS"
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
    # The primary superblock is at 64 KiB, so the image must reach past it.
    image = testpath/"not.img"
    File.binwrite(image, "\0" * 131_072)
    # A file without the Btrfs superblock magic is refused, status 1.
    assert_match "not a Btrfs volume", shell_output("#{bin}/fs.btrfs #{image} get 2>&1", 1)
  end
end
