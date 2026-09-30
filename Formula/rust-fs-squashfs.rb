# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsSquashfs < Formula
  desc "Pure-Rust SquashFS filesystem tools"
  homepage "https://github.com/antimatter-studios/rust-fs-squashfs"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-fs-squashfs/releases/download/v#{version}/am-fs-squashfs-#{version}-darwin-arm64.tar.gz"
      sha256 "75064f3b71ee5f906138ccf236b62561a553619fec043bbd66f7f82f6620d7f3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-fs-squashfs/releases/download/v#{version}/am-fs-squashfs-#{version}-linux-x86_64.tar.gz"
      sha256 "be9bcfc060bdc05b25d2c557bbb7f7b397bf537a9b255fe97ef22387a421d048"
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
