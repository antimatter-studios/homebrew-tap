# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgQcow2 < Formula
  desc "Pure-Rust QCOW2 disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-qcow2"
  version "0.5.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-qcow2/releases/download/v#{version}/am-img-qcow2-#{version}-darwin-arm64.tar.gz"
      sha256 "6f0296eecd65abc09ec80e7577b0da211dfa9ced48b0493e0fd17d4b987dbf55"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-qcow2/releases/download/v#{version}/am-img-qcow2-#{version}-linux-x86_64.tar.gz"
      sha256 "ef4872c37905551434cb93929f4babd95a95dbd384b43adc00ce82c5f5501d35"
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
    notes = opt_prefix/"share/rust-img-qcow2/CAVEATS"
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
    image = testpath/"not.qcow2"
    File.binwrite(image, "\0" * 4096)
    # A file without the QCOW2 magic is refused, status 1.
    assert_match "not a QCOW2 image", shell_output("#{bin}/img.qcow2 #{image} get 2>&1", 1)
    # The library has no image creator: create answers not implemented, status 3,
    # and makes no file.
    new = testpath/"new.qcow2"
    assert_match "not implemented", shell_output("#{bin}/img.qcow2 #{new} create 1M 2>&1", 3)
    refute_path_exists new
  end
end
