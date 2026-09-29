# typed: false
# frozen_string_literal: true

# THE SHAPE EVERY FILESYSTEM-DRIVER FORMULA HAS (rust-fs-*, rust-img-*).
#
# The release tarball is the contract, and it is laid out as an install
# prefix: bin/<tools>, share/<repo>/CAVEATS, share/man, completions, licence.
# So a driver's formula names no tool and carries no caveat text: it copies
# the tarball into its prefix and shows the CAVEATS the release shipped.
# Tools, man pages and notes change in the driver's repository and reach
# users with its next release, with no edit here.
#
# A driver formula is this file with its own class name, desc, homepage,
# license, version, urls and checksums, and its own lines after the marker in
# the test block. .github/scripts/check-driver-formulae.py fails CI on any
# other difference.
class DriverName < Formula
  desc "Filesystem driver tools"
  homepage "https://github.com/OWNER/REPO"
  version "0.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/OWNER/REPO/releases/download/v#{version}/CRATE-#{version}-darwin-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/OWNER/REPO/releases/download/v#{version}/CRATE-#{version}-linux-x86_64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
    notes = opt_prefix/"share/REPO/CAVEATS"
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
  end
end
