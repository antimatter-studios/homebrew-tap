class VagrantQemu < Formula
  desc "Vagrant provider for QEMU with virtiofs support"
  homepage "https://github.com/christhomas/vagrant-qemu"
  license "MIT"

  version "0.4.1.pre.christhomas"
  url "https://github.com/christhomas/vagrant-qemu/releases/download/v0.4.1-christhomas/vagrant-qemu-#{version}.gem"
  sha256 "3d938e79e1301dcbe3e2337fb9ac36a639d227bba1a0e4b179a8270135615a75"

  depends_on :macos
  depends_on "antimatter-studios/tap/qemu"
  depends_on "antimatter-studios/tap/virtiofsd"

  def install
    libexec.install "vagrant-qemu-#{version}.gem"
  end

  def post_install
    user = ENV["USER"] || ENV["LOGNAME"] || `stat -f '%Su' #{Dir.home}`.strip
    system "sudo", "-u", user, "vagrant", "plugin", "install", libexec/"vagrant-qemu-#{version}.gem"
  rescue => e
    opoo "Could not install Vagrant plugin automatically: #{e.message}"
    opoo "Install manually: vagrant plugin install #{opt_libexec}/vagrant-qemu-#{version}.gem"
  end

  def caveats
    <<~EOS
      This formula installs the vagrant-qemu plugin with virtiofs support.

      If the plugin was not installed automatically, run:
        vagrant plugin install #{opt_libexec}/vagrant-qemu-#{version}.gem

      Dependencies (installed automatically):
        - antimatter-studios/tap/qemu (QEMU with vhost-user-fs support)
        - antimatter-studios/tap/virtiofsd (virtiofs daemon)

      If the plugin was not installed automatically, run:
        vagrant plugin install #{libexec}/vagrant-qemu-#{version}.gem
    EOS
  end

  test do
    assert_match "vagrant-qemu",
      shell_output("vagrant plugin list 2>&1")
  end
end
