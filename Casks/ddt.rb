# Maintained by this tap, not by the project that ships ddt.
#
# It used to be written straight into this repository by ddt's release pipeline, which
# meant a push from another repository could change what `brew install ddt` fetches. The
# tap now pulls instead: "Sync formulae from releases" reads ddt's public releases,
# hashes the assets it downloaded, and pushes a branch. A person opens the pull request
# and merges it. Only the version and the four checksums are rewritten by that workflow
# — everything else here is edited by hand.
cask "ddt" do
  version "2.1.0"

  name "ddt"
  desc "Docker development tools CLI"
  homepage "https://github.com/antimatter-studios/docker-dev-tools"

  livecheck do
    skip "Updated by this tap's sync workflow, which a human triggers and reviews."
  end

  binary "ddt"

  on_macos do
    on_intel do
      sha256 "14944afa022b30882891cf81286d06c22ceb65951ce637ee3fa4bdf0fe7fe139"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_amd64.tar.gz"
    end
    on_arm do
      sha256 "43a0efc924f5454cf8313cc8ae73e7b7623f15d0d3ad18190399ae20c7470fab"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_darwin_arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "8e37e2ee14f9a78fd17d020ad37697b3bea45bb2da99f423ca82150e20c8b65f"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_amd64.tar.gz"
    end
    on_arm do
      sha256 "20f55f41e93f106c11a5a5f2cd007ee3027fc9f9f06ea743b7b69d6642ce6c4f"
      url "https://github.com/antimatter-studios/docker-dev-tools/releases/download/v#{version}/ddt_#{version}_linux_arm64.tar.gz"
    end
  end

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/ddt"]
  end

  # No zap stanza required
end
