# Maintained by this tap, not by the project that ships ddt.
#
# It used to be written straight into this repository by ddt's release pipeline, which
# meant a push from another repository could change what `brew install ddt` fetches. The
# tap now pulls instead: "Sync formulae from releases" reads ddt's public releases,
# hashes the assets it downloaded, and pushes a branch. A person opens the pull request
# and merges it. Only the version and the four checksums are rewritten by that workflow
# — everything else here is edited by hand.
cask "ddt" do
  version "2.2.0"

  name "ddt"
  desc "Docker development tools CLI"
  homepage "https://github.com/antimatter-studios/docker-dev-tools"

  livecheck do
    skip "Updated by this tap's sync workflow, which a human triggers and reviews."
  end

  binary "ddt"

  on_macos do
    on_intel do
      sha256 "24ad536c9a6e3ab0e00677dfcb04cc43ea7f4014ccef9f5dd10d386a4f383f2d"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
    end
    on_arm do
      sha256 "72c8e9460194df7d0eae4abfe5c2e77ec8b8679f09c8114693ba9f79c54b0970"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "35c7edd85633aa1570d783f4edefa66928e596e2fe2adf43ae6cb5f020d3ff0a"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
    end
    on_arm do
      sha256 "0c7947217bae33821946f150f1f3e8fa687bf0ef4068399eac113b79786b6fc2"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
    end
  end

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/ddt"]
  end

  # No zap stanza required
end
