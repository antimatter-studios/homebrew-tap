# typed: false
# frozen_string_literal: true

# Maintained by this tap. Only the version and the two checksums are rewritten by
# "Sync formulae from releases" — everything else here is edited by hand.
#
# That is true now, but it was not true when this file was first written, and the
# header it originally carried said so accurately: christhomas/virtiofsd used to
# render this formula and push it here, which is exactly what the run that
# published v1.13.8 did.
#
# The reason that looked false is worth recording, because it is a trap. That
# pipeline lived on a branch, not on the default branch, so asking GitHub for the
# repository's `.github` directory returned nothing and suggested no pipeline
# existed at all. It did. The project has since removed the push and made the
# branch carrying the pipeline its default, so the tap is now the only writer.
#
# One residue: re-releasing the v1.13.8 tag would still run the older pipeline and
# overwrite this file, because that tree predates the push being removed. Cutting
# releases from the current default branch avoids it.
#
# No `@...@` template tokens remain in this file, whatever the original header
# said about substituting them at release time.
class Virtiofsd < Formula
  desc "Virtio-fs vhost-user device daemon (macOS port)"
  homepage "https://github.com/christhomas/virtiofsd"
  version "1.13.8"
  # Upstream's Cargo.toml says "Apache-2.0 AND BSD-3-Clause" — both apply at
  # once. This said any_of, which is Homebrew's spelling of OR and claimed a
  # choice between them that upstream does not offer. all_of is AND.
  license all_of: ["Apache-2.0", "BSD-3-Clause"]

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/christhomas/virtiofsd/releases/download/v#{version}/virtiofsd-#{version}-darwin-arm64.tar.gz"
      sha256 "182ebf8838b230a5f3c72b612950510380b681e746643b9919a90f75341ee55a"
    end
    on_intel do
      url "https://github.com/christhomas/virtiofsd/releases/download/v#{version}/virtiofsd-#{version}-darwin-x86_64.tar.gz"
      sha256 "3ea290f7e36d2bdf4a616cef3af8ea907b7541aa9ddbbaad69362ce5542556a0"
    end
  end

  def install
    bin.install "virtiofsd"
  end

  def caveats
    msg = ""

    qemu_name = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    qemu_bin = which(qemu_name)
    if qemu_bin.nil?
      msg += <<~EOS
        WARNING: QEMU is not installed. virtiofsd requires QEMU built with
        vhost-user-fs support. The standard Homebrew QEMU does not include this.

        Install the compatible QEMU from this tap:
          brew install antimatter-studios/tap/qemu

      EOS
    elsif `#{qemu_bin} -device help 2>&1`.exclude?("vhost-user-fs")
      msg += <<~EOS
        WARNING: Your installed QEMU lacks vhost-user-fs support.
        virtiofsd will not work with it.

        Install the compatible QEMU from this tap:
          brew install antimatter-studios/tap/qemu

      EOS
    end

    msg += <<~EOS
      Usage:
        virtiofsd --socket-path=/tmp/virtiofsd.sock \\
                  --shared-dir=/path/to/share \\
                  --sandbox none \\
                  --inode-file-handles=never
    EOS

    msg
  end

  test do
    assert_match "virtiofsd", shell_output("#{bin}/virtiofsd --help 2>&1")

    qemu_name = Hardware::CPU.arm? ? "qemu-system-aarch64" : "qemu-system-x86_64"
    qemu_bin = which(qemu_name)
    if qemu_bin
      devices = shell_output("#{qemu_bin} -device help 2>&1")
      assert_match "vhost-user-fs", devices,
                   "QEMU is installed but lacks vhost-user-fs support. " \
                   "Install a compatible QEMU: brew install antimatter-studios/tap/qemu"
    end
  end
end
