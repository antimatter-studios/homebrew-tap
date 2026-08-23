# typed: false
# frozen_string_literal: true

class Chore < Formula
  desc "Task runner that reads chores.yml and gives tasks real arguments"
  homepage "https://github.com/antimatter-studios/chore"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-arm64.tar.gz"
      sha256 "af1e4ace446f6f3febead9f54f76506a0782f2ae45334681ba6f26e922f47dd1"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-darwin-x86_64.tar.gz"
      sha256 "d4cf44fbad933c8316d8db5b4905da19885e6bc52e7b9ba0df3f1dba934001f4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-arm64.tar.gz"
      sha256 "4f5fbd2ae2232d329f911c8d9446bd80d68b3a67ccb1a574ef7d1620bb2d9b83"
    end
    on_intel do
      url "https://github.com/antimatter-studios/chore/releases/download/v#{version}/chore-#{version}-linux-x86_64.tar.gz"
      sha256 "433a337acd6d7d467a3d0b1eb04f1b0e17b4605ec52d6376da592947cee69c4b"
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
