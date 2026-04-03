class VagrantNotifyForwarder < Formula
  desc "Vagrant plugin for forwarding file system notifications to guest VMs"
  homepage "https://github.com/christhomas/vagrant-notify-forwarder"
  license "MIT"

  version "0.7.0"
  url "https://github.com/christhomas/vagrant-notify-forwarder/releases/download/v#{version}/vagrant-notify-forwarder2-#{version}.gem"
  sha256 "d91af3b1e0a6c2adc84cb329eea3caceb609a60a4695371669573ca4d06d2b52"

  depends_on :macos

  def install
    libexec.install "vagrant-notify-forwarder2-#{version}.gem"
  end

  def install
    libexec.install "vagrant-notify-forwarder2-#{version}.gem"
  end

  def post_install
    ENV["PATH"] = "/opt/vagrant/bin:/opt/homebrew/bin:/usr/local/bin:#{ENV["PATH"]}"
    system "vagrant", "plugin", "install", libexec/"vagrant-notify-forwarder2-#{version}.gem"
  end

  def caveats
    <<~EOS
      vagrant-notify-forwarder2 has been installed as a Vagrant plugin.
      Verify with: vagrant plugin list
    EOS
  end

  test do
    assert_match "vagrant-notify-forwarder2",
      shell_output("vagrant plugin list 2>&1")
  end
end
