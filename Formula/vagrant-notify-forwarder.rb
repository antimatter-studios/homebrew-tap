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

    # Create a wrapper script the user can run to complete the install
    (bin/"vagrant-notify-forwarder-install").write <<~SH
      #!/bin/bash
      vagrant plugin install "#{opt_libexec}/vagrant-notify-forwarder2-#{version}.gem"
    SH
  end

  def post_install
    system "vagrant", "plugin", "install", libexec/"vagrant-notify-forwarder2-#{version}.gem"
  rescue => e
    opoo "Automatic plugin install failed (sandbox restriction)."
    opoo "Run: vagrant-notify-forwarder-install"
  end

  def caveats
    <<~EOS
      If the plugin was not installed automatically, run:
        vagrant-notify-forwarder-install
    EOS
  end

  test do
    assert_match "vagrant-notify-forwarder2",
      shell_output("vagrant plugin list 2>&1")
  end
end
