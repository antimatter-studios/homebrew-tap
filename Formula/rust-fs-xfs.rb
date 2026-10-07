# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsXfs < Formula
  desc "Pure-Rust XFS filesystem tools"
  homepage "https://github.com/antimatter-studios/rust-fs-xfs"
  version "0.12.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-fs-xfs/releases/download/v#{version}/rust-fs-xfs-#{version}-darwin-arm64.tar.gz"
      sha256 "7c8f53af41a9a72f5a7d43d82a63acfcbbb911221a6a4aa058879559f27df705"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-fs-xfs/releases/download/v#{version}/rust-fs-xfs-#{version}-linux-x86_64.tar.gz"
      sha256 "2cbc13b3a98eafbafb4f71b7324db3148d0128261728a00169fea4ff9faed727"
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
    notes = opt_prefix/"share/rust-fs-xfs/CAVEATS"
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
    # A file without the XFS superblock magic is refused, status 1.
    assert_match "not an XFS volume", shell_output("#{bin}/fs.xfs #{image} get 2>&1", 1)
  end
end
