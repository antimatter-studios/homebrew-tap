# typed: false
# frozen_string_literal: true

class Chore < Formula
  desc "Task runner that reads chores.yml and gives tasks real arguments"
  homepage "https://github.com/antimatter-studios/chore"
  version "0.13.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-arm64.tar.gz"
      sha256 "3c732ed61606174a82799871344562468848693547b8b37fffd50a3dc848b485"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-x86_64.tar.gz"
      sha256 "7a972ff7789a48172bd2e18fb92793c25df3dd4ec81ecdf442090e84dcf9fe3a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-arm64.tar.gz"
      sha256 "33d25ceaa0cec17d86b1be615a87b63c4f937bbb34526dd80b7fafa04e1c9f13"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-x86_64.tar.gz"
      sha256 "c7e005c53f3e1c79c92ba8e13891f13e77cba536b8c6d0f504665c4e7c24e5bf"
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
