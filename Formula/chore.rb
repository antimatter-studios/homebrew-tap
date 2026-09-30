# typed: false
# frozen_string_literal: true

class Chore < Formula
  desc "Task runner that reads chores.yml and gives tasks real arguments"
  homepage "https://github.com/antimatter-studios/chore"
  version "0.15.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-arm64.tar.gz"
      sha256 "51ded907187daec72d9aa2a35561b03b9af83d54e6f8f98094d477003b7b26f5"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-x86_64.tar.gz"
      sha256 "06a4f89c39b2730a91074bb1857adefc51623493b895e3f3c37fa13b04186d9f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-arm64.tar.gz"
      sha256 "0c2aab019a5707adb2beb5926ae1b570d874bbdcc74a3fb1052ac76aa1469005"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-x86_64.tar.gz"
      sha256 "a5730a2176c0f5179046e4d417850984a1a4e573212dfa5bbd3edeeebf4276c8"
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
