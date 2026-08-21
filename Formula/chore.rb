# typed: false
# frozen_string_literal: true

class Chore < Formula
  desc "Task runner that reads chores.yml and gives tasks real arguments"
  homepage "https://github.com/antimatter-studios/chore"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-arm64.tar.gz"
      sha256 "4993bfb264337c95bfaf2b4bee0719aead76ec52fff02755c5325cb03d7b23e0"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-x86_64.tar.gz"
      sha256 "b1a09b0da810ba4988951e26c926b6d4af555d590b1da51e6f1a4095d6d011c2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-arm64.tar.gz"
      sha256 "1750795e1f8000e694c913f3343cd6ed22b0655cac7f68f4df7639c896d3d8ab"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-x86_64.tar.gz"
      sha256 "239bd8699bb6cc86e35df131f30cd8ae062c29600e5fb70fc19c44bf2e309a4b"
    end
  end

  def install
    bin.install "chore"
  end

  def caveats
    <<~EOS
      chore reads chores.yml from the current directory or any parent.

      It reads go-task's file format, so an existing Taskfile.yml works after a
      rename — with a notice if you leave the old name in place, because the two
      runners disagree about arguments.

        chore --list
        chore build
        chore instance:up mail4.test
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chore --version")

    # A real task, run end to end: proves the binary parses chores.yml, resolves
    # a variable and executes a command, not merely that it starts.
    (testpath/"chores.yml").write <<~YAML
      version: "3"
      tasks:
        greet:
          desc: Say hello
          args: [name]
          vars:
            name: world
          cmds:
            - 'echo "hello {{.NAME}}"'
    YAML

    assert_equal "hello world", shell_output("#{bin}/chore greet").strip
    assert_equal "hello brew", shell_output("#{bin}/chore greet brew").strip
    assert_equal "hello flag", shell_output("#{bin}/chore greet --name flag").strip
    assert_match "greet", shell_output("#{bin}/chore --list")
  end
end
