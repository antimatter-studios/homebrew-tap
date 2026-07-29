# Maintained by this tap, not by the project that ships ddt.
#
# It used to be written straight into this repository by ddt's release pipeline, which
# meant a push from another repository could change what `brew install ddt` fetches. The
# tap now pulls instead: "Sync formulae from releases" reads ddt's public releases,
# hashes the assets it downloaded, and pushes a branch. A person opens the pull request
# and merges it. Only the version and the four checksums are rewritten by that workflow
# — everything else here is edited by hand.
cask "ddt" do
  version "2.2.2"

  name "ddt"
  desc "Docker development tools CLI"
  homepage "https://github.com/antimatter-studios/docker-dev-tools"

  livecheck do
    skip "Updated by this tap's sync workflow, which a human triggers and reviews."
  end

  binary "ddt"

  on_macos do
    on_intel do
      sha256 "f03aac25acdce5f9818052a279a5df76cda18391382dcbfdd428d60e0f80f82e"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
    end
    on_arm do
      sha256 "16c46922982dc08223d27fe2fe8b2f7680f24e0f7c1aed0f90a1350ee1795c4a"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "836d0726c8b69ba073a8d43738a0cdffd750baa2b4b1d28751f161c06c6e227b"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
    end
    on_arm do
      sha256 "37a6f849ddd61f25e9609190d03f17c29011aacecb68459bb809b4ab5c86232e"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
    end
  end

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/ddt"]
  end

  # No zap stanza required
end
