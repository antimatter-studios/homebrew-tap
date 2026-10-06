# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb; CI checks it still is.
class RustImgVhd < Formula
  desc "Pure-Rust VHD disk image tools"
  homepage "https://github.com/antimatter-studios/rust-img-vhd"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-img-vhd/releases/download/v#{version}/rust-img-vhd-#{version}-darwin-arm64.tar.gz"
      sha256 "2e750739673cfc539d3eb69d3058772fb93f874d08846c519cdf0b076d366a14"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-img-vhd/releases/download/v#{version}/rust-img-vhd-#{version}-linux-x86_64.tar.gz"
      sha256 "b092e974a55cfef8130b7a7dbecf3ed2dce89957796d5d4bd44d6d860f4ffd90"
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
    notes = opt_prefix/"share/rust-img-vhd/CAVEATS"
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
    image = testpath/"disk.vhd"
    system bin/"img.vhd", image, "create", "8M", "--type", "dynamic"
    # 8 MiB is not a whole CHS geometry, so the footer records it rounded up,
    # as qemu-img rounds it.
    assert_equal "8390656", shell_output("#{bin}/img.vhd #{image} get virtual_size --text").strip
    assert_equal "dynamic", shell_output("#{bin}/img.vhd #{image} get vhd.disk_type --text").strip
    # Bytes written at a guest offset read back from the same offset.
    pipe_output("#{bin}/img.vhd #{image} write --offset 512", "hello", 0)
    assert_equal "hello", shell_output("#{bin}/img.vhd #{image} read --offset 512 --length 5")
    # A file without a VHD footer is refused, status 1.
    zeros = testpath/"not.vhd"
    File.binwrite(zeros, "\0" * 4096)
    assert_match "not a VHD image", shell_output("#{bin}/img.vhd #{zeros} get 2>&1", 1)
  end
end
