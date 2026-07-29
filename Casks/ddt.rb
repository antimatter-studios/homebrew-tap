# Maintained by this tap, not by the project that ships ddt.
#
# It used to be written straight into this repository by ddt's release pipeline, which
# meant a push from another repository could change what `brew install ddt` fetches. The
# tap now pulls instead: "Sync formulae from releases" reads ddt's public releases,
# hashes the assets it downloaded, and pushes a branch. A person opens the pull request
# and merges it. Only the version and the four checksums are rewritten by that workflow
# — everything else here is edited by hand.
cask "ddt" do
  version "2.2.1"

  name "ddt"
  desc "Docker development tools CLI"
  homepage "https://github.com/antimatter-studios/docker-dev-tools"

  livecheck do
    skip "Updated by this tap's sync workflow, which a human triggers and reviews."
  end

  binary "ddt"

  on_macos do
    on_intel do
      sha256 "5efbfd61e095bd95bd0009182d2cab4263723ce885ed7fbec31ababa1a1e8b31"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
    end
    on_arm do
      sha256 "c6b869b0e3d02d8bafa2c03db907149fe2e880b19c10452fa284062eaa285887"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "f3319c103518431728f0eab7a33ea0fd8d4b78431c111d342990df0f8dd7392a"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
    end
    on_arm do
      sha256 "bf400fd686ab8163e13b2b3465adc0e301a6e70b9b74e8e7c3d14abe4b94741a"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
    end
  end

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/ddt"]
  end

  # No zap stanza required
end
