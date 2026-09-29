# typed: false
# frozen_string_literal: true

class Chore < Formula
  desc "Task runner that reads chores.yml and gives tasks real arguments"
  homepage "https://github.com/antimatter-studios/chore"
  version "0.14.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-arm64.tar.gz"
      sha256 "0d6ee38f111eff2f1fa8282b6d119d160350a5da03188da28980176e003a7112"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-x86_64.tar.gz"
      sha256 "e0cd7156d5116009dc64adf15b3b28f4b65764df2f9469b1b76bdc77e497d57e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-arm64.tar.gz"
      sha256 "e90a7191b4105fdcc309b445e1831069f37c00ff2c4701d573059bb5de0b7340"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-x86_64.tar.gz"
      sha256 "e1b5f224f7f24ec5966aeaf952a68d56ef2500a9ee54ef4d3d4eb11c1a7b53c4"
    end
  end

  def install
    bin.install "chore"
  end

  def caveats
    <<~EOS
      chore reads chores.yml from the current directory or any parent.

      Release notes: https://github.com/antimatter-studios/chore/blob/v#{version}/CHANGELOG.md

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
