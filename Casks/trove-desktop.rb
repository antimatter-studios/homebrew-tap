cask "trove-desktop" do
  version "0.15.0"
  sha256 "c237d7eb5cdde98a3d137cc91082a7b66f00388d6117d57204c460ccd1325f95"

  url "https://github.com/antimatter-studios/trove/releases/download/v#{version}/Trove_#{version}_universal.dmg"
  # The cask is called trove-desktop so it installs separately from the
  # trove-cli formula. The APP is just Trove — that is what its bundle is
  # named and what a person sees in the Dock.
  name "Trove"
  desc "Desktop vault manager — GUI companion to the trove CLI"
  homepage "https://github.com/antimatter-studios/trove"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Installing the GUI pulls in the trove/troved runtime it drives.
  depends_on formula: "antimatter-studios/tap/trove-cli"
  depends_on macos: :catalina

  app "Trove.app"

  zap trash: [
    "~/Library/Application Support/com.trove.desktop",
    "~/Library/Preferences/com.trove.desktop.plist",
    "~/Library/Saved Application State/com.trove.desktop.savedState",
  ]
end
