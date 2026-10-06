# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgQcow2 < Formula
  desc "Pure-Rust QCOW2 disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-qcow2"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-qcow2/releases/download/v#{version}/rust-img-qcow2-#{version}-darwin-arm64.tar.gz"
      sha256 "3d5d0da88bb888d4c6f3f9f124c4b5344e197c91f2b1a4d06f47846787aced52"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-qcow2/releases/download/v#{version}/rust-img-qcow2-#{version}-linux-x86_64.tar.gz"
      sha256 "7343e552f95a4c07418db4b523115e25bb703d052a70b9cffb64718f75868b84"
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
