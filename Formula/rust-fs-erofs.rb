# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustFsErofs < Formula
  desc "Pure-Rust EROFS filesystem tools"
  homepage "https://github.com/antimatter-studios/rust-fs-erofs"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-fs-erofs/releases/download/v#{version}/am-fs-erofs-#{version}-darwin-arm64.tar.gz"
      sha256 "90c955dd0c62356052983aea1d75e12ac5b819c2ba345823c8e76dfc4b55e8c5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-fs-erofs/releases/download/v#{version}/am-fs-erofs-#{version}-linux-x86_64.tar.gz"
      sha256 "c3e8405a5786c09f9efc29d1017f87da3a9804eea5e143e163db3784e6970add"
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
    notes = opt_prefix/"share/rust-fs-erofs/CAVEATS"
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
    (testpath/"src").mkpath
    (testpath/"src/greeting").write "hello"
    image = testpath/"erofs.img"
    system bin/"mkfs.erofs", image, testpath/"src"
    # The superblock's magic, 0xE0F5E1E2 little-endian, at offset 1024.
    assert_equal "\xE2\xE1\xF5\xE0".b, File.binread(image, 4, 1024)
    assert_equal "hello", shell_output("#{bin}/fs.erofs #{image} read /greeting")
  end
end
