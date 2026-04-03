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
    vagrant_home = File.expand_path("~/.vagrant.d")
    gem_name = "vagrant-notify-forwarder2"

    # Detect vagrant's ruby version
    ruby_ver = Dir.glob("#{vagrant_home}/gems/*").map { |d| File.basename(d) }.sort.last
    return opoo("No Vagrant gem directory found") unless ruby_ver

    gem_dir = "#{vagrant_home}/gems/#{ruby_ver}"

    # Install gem into Vagrant's gem directory
    system "/opt/vagrant/embedded/bin/gem", "install",
      libexec/"#{gem_name}-#{version}.gem",
      "--install-dir", gem_dir,
      "--no-document"

    # Update plugins.json
    require "json"
    plugins_file = "#{vagrant_home}/plugins.json"
    plugins = File.exist?(plugins_file) ? JSON.parse(File.read(plugins_file)) : { "version" => "1", "installed" => {} }
    plugins["installed"][gem_name] = {
      "ruby_version" => ruby_ver,
      "vagrant_version" => "2.4.9",
      "gem_version" => version.to_s,
      "require" => "",
      "sources" => [],
      "installed_gem_version" => version.to_s,
      "env_local" => false,
    }
    File.write(plugins_file, JSON.pretty_generate(plugins))
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
