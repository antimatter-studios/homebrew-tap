# typed: false
# frozen_string_literal: true

class Restmail < Formula
  desc "Claim and run a rest-mail server over its public API"
  homepage "https://github.com/rest-mail/rest-mail-server"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/rest-mail/rest-mail-server/releases/download/v#{version}/restmail_#{version}_darwin_arm64.tar.gz"
      sha256 "4c357a9334ee1bc8c4041d717df930812bbd2ceb0e9c7111c54a3ed29e2da28b"
    end
    on_intel do
      url "https://github.com/rest-mail/rest-mail-server/releases/download/v#{version}/restmail_#{version}_darwin_amd64.tar.gz"
      sha256 "f5d690bf9f7e8c7bd273592df25419a55c09e2561f0ae08e07f5aea8cfe92f04"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rest-mail/rest-mail-server/releases/download/v#{version}/restmail_#{version}_linux_arm64.tar.gz"
      sha256 "8f89168f194546bd4e27d1a27a9ed98bdd6de5bbf9fb4ad7c9d08e3008c596b8"
    end
    on_intel do
      url "https://github.com/rest-mail/rest-mail-server/releases/download/v#{version}/restmail_#{version}_linux_amd64.tar.gz"
      sha256 "b9d23d0f2bb331043b9a2032d1c45d234648a3a016d6d89479028f5acfda5e15"
    end
  end

  def install
    bin.install "restmail"
  end

  def caveats
    <<~EOS
      restmail talks to a server over its public API and nothing else: it is
      told a server by its address, and knows nothing about how that server was
      installed.

        restmail status --server https://mail.example.com

      says whether anyone has claimed it yet, and if not, how to. A server
      nobody has claimed prints a setup code at every start, with a QR code of
      a link that claims it, so you can also scan it with a phone.

      Release notes: https://github.com/rest-mail/rest-mail-server/releases/tag/v#{version}
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/restmail version")

    # The link a setup code becomes, built without reaching any server: proves
    # the binary parses its flags and produces what the app opens, rather than
    # merely starting.
    link = shell_output("#{bin}/restmail setup --server https://mail.example.com " \
                        "--code ABCD-EFGH-JKMN-PQRS-TVWX-YZ01 --json --show-secret")
    assert_match "rest-mail.com/setup#", link
    assert_match "ABCD-EFGH-JKMN-PQRS-TVWX-YZ01", link

    # A secret is withheld unless it is asked for.
    quiet = shell_output("#{bin}/restmail setup --server https://mail.example.com " \
                         "--code ABCD-EFGH-JKMN-PQRS-TVWX-YZ01 --json")
    refute_match "ABCD-EFGH-JKMN-PQRS-TVWX-YZ01", quiet

    # An unknown command is refused by name, rather than opening the console.
    assert_match "there is no \"nope\" command", shell_output("#{bin}/restmail nope 2>&1", 2)
  end
end
