# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgVmdk < Formula
  desc "Pure-Rust VMDK disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-vmdk"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-vmdk/releases/download/v#{version}/rust-img-vmdk-#{version}-darwin-arm64.tar.gz"
      sha256 "77daa2e8420ed300e400b1f58b4c5d116a09cff5e91450b0bca6783c2aea9479"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-vmdk/releases/download/v#{version}/rust-img-vmdk-#{version}-linux-x86_64.tar.gz"
      sha256 "3062a89a12e0952f485d0cabc372a5bad0d6782bcdaba1432cca1a1a8890170c"
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
    notes = opt_prefix/"share/rust-img-vmdk/CAVEATS"
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
    # The library has no image creator: create answers not implemented, status 3,
    # and makes no file.
    new = testpath/"new.vmdk"
    assert_match "not implemented", shell_output("#{bin}/img.vmdk #{new} create 8M 2>&1", 3)
    refute_path_exists new
  end
end
