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
    ohai "Debugging post_install environment..."
    ohai "USER=#{ENV["USER"]}"
    ohai "HOME=#{ENV["HOME"]}"
    ohai "PATH=#{ENV["PATH"]}"
    ohai "Vagrant exists: #{File.exist?("/opt/vagrant/bin/vagrant")}"
    ohai "Vagrant exists (usr): #{File.exist?("/usr/local/bin/vagrant")}"
    ohai "~/.vagrant.d exists: #{File.directory?(File.expand_path("~/.vagrant.d"))}"
    ohai "~/.vagrant.d writable: #{File.writable?(File.expand_path("~/.vagrant.d"))}"

    # Try to write a test file
    test_file = File.expand_path("~/.vagrant.d/brew_post_install_test")
    begin
      File.write(test_file, "test")
      File.delete(test_file)
      ohai "Can write to ~/.vagrant.d: YES"
    rescue => e
      ohai "Can write to ~/.vagrant.d: NO (#{e.message})"
    end

    # Try vagrant with full PATH
    ENV["PATH"] = "/opt/vagrant/bin:/opt/homebrew/bin:/usr/local/bin:#{ENV["PATH"]}"
    ohai "Updated PATH=#{ENV["PATH"]}"

    vagrant_bin = ["/opt/vagrant/bin/vagrant", "/usr/local/bin/vagrant"].find { |p| File.executable?(p) }
    ohai "Using vagrant: #{vagrant_bin || 'NOT FOUND'}"

    if vagrant_bin
      system vagrant_bin, "plugin", "install", libexec/"vagrant-notify-forwarder2-#{version}.gem"
    else
      opoo "Vagrant not found. Install manually: vagrant plugin install #{opt_libexec}/vagrant-notify-forwarder2-#{version}.gem"
    end
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
