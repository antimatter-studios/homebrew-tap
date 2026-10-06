# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgVhdx < Formula
  desc "Pure-Rust VHDX disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-vhdx"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-vhdx/releases/download/v#{version}/rust-img-vhdx-#{version}-darwin-arm64.tar.gz"
      sha256 "5b3cb44e96452a03dda1a9936caf91d1730e21a2b58943f468465272c1c4e6bf"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-vhdx/releases/download/v#{version}/rust-img-vhdx-#{version}-linux-x86_64.tar.gz"
      sha256 "880d91898fa4dd28608e07e385e65f7fac4fd09aa1c227d6ff98f9da9ea3a61f"
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
    notes = opt_prefix/"share/rust-img-vhdx/CAVEATS"
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
    image = testpath/"not.vhdx"
    File.binwrite(image, "\0" * 4096)
    # A file without the VHDX file identifier is refused, status 1.
    assert_match "not a VHDX image", shell_output("#{bin}/img.vhdx #{image} get 2>&1", 1)
  end
end
