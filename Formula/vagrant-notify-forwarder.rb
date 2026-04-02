class VagrantNotifyForwarder < Formula
  desc "Vagrant plugin for forwarding file system notifications to guest VMs"
  homepage "https://github.com/christhomas/vagrant-notify-forwarder"
  license "MIT"

  version "0.6.3"
  url "https://github.com/christhomas/vagrant-notify-forwarder/releases/download/v#{version}/vagrant-notify-forwarder2-#{version}.gem"
  sha256 "9558cee06402f8a30346101dec9d9722adad4a422dce3a98965c26363ffe2de4"

  depends_on :macos

  def install
    libexec.install "vagrant-notify-forwarder2-#{version}.gem"
  end

  def post_install
    system "vagrant", "plugin", "install", libexec/"vagrant-notify-forwarder2-#{version}.gem"
  rescue => e
    opoo "Could not install Vagrant plugin automatically: #{e.message}"
    opoo "Install manually: vagrant plugin install #{libexec}/vagrant-notify-forwarder2-#{version}.gem"
  end

  def caveats
    <<~EOS
      This formula installs the vagrant-notify-forwarder2 plugin.
      It requires Vagrant to be installed first.

      If the plugin was not installed automatically, run:
        vagrant plugin install #{libexec}/vagrant-notify-forwarder2-#{version}.gem
    EOS
  end

  test do
    assert_match "vagrant-notify-forwarder2",
      shell_output("vagrant plugin list 2>&1")
  end
end
