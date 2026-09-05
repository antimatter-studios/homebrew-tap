cask "trove-desktop" do
  version "0.8.0"
  sha256 "362615bb9a088d2f2a222e3471d7cb5e762667cfd6542c570e71314e8aff8fda"

  url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/TroveDesktop_#{version}_universal.dmg"
  name "Trove Desktop"
  desc "Desktop vault manager — GUI companion to the trove CLI"
  homepage "https://github.com/antimatter-studios/trove"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Installing the GUI pulls in the trove/troved runtime it drives.
  depends_on formula: "antimatter-studios/tap/trove-cli"
  depends_on macos: :catalina

  app "TroveDesktop.app"

  zap trash: [
    "~/Library/Application Support/com.trove.desktop",
    "~/Library/Preferences/com.trove.desktop.plist",
    "~/Library/Saved Application State/com.trove.desktop.savedState",
  ]
end
