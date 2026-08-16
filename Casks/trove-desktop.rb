cask "trove-desktop" do
  version "0.7.1"
  sha256 "82a3b0d9d87b8fc614e558127dbd05f12691f17cf74b4f19f74bf91d6d4aece3"

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
