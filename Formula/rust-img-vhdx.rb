# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgVhdx < Formula
  desc "Pure-Rust VHDX disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-vhdx"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-vhdx/releases/download/v#{version}/am-img-vhdx-#{version}-darwin-arm64.tar.gz"
      sha256 "8844fc42880cf73cad5942676be78244339ae1e0bbf72fe874438227e0ff9dc9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-vhdx/releases/download/v#{version}/am-img-vhdx-#{version}-linux-x86_64.tar.gz"
      sha256 "8d568c0acabd37d2a4f64ff9d9e4691132efaf24140dd48a5a600a5a5ced8689"
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
