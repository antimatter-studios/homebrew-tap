# typed: false
# frozen_string_literal: true

# Its shape is .github/driver-formula/template.rb.
class RustLzo1x < Formula
  desc "Pure-Rust LZO1X tools: .lzo files and raw LZO1X blocks"
  homepage "https://github.com/antimatter-studios/rust-lzo1x"
  version "0.3.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/rust-lzo1x/releases/download/v#{version}/am-lzo1x-#{version}-darwin-arm64.tar.gz"
      sha256 "d7ffa788d6d43b804a37695534150510d99628b7c2387d142213a575abe320dc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/antimatter-studios/rust-lzo1x/releases/download/v#{version}/am-lzo1x-#{version}-linux-x86_64.tar.gz"
      sha256 "239f6d510d1cff812911f4ff4e5f86715c5407abff64596ea509ea1b5614e43c"
    end
  end

  def install
    prefix.install Dir["*"]
  end

  def caveats
    notes = opt_prefix/"share/rust-lzo1x/CAVEATS"
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
    # A file goes to .lzo and comes back the same.
    (testpath/"notes.txt").write("the quick brown fox " * 1000)
    system bin/"lzo1x", "-k", testpath/"notes.txt"
    assert_path_exists testpath/"notes.txt.lzo"
    assert_equal (testpath/"notes.txt").read, shell_output("#{bin}/lzo1x -d -c #{testpath}/notes.txt.lzo")
  end
end
