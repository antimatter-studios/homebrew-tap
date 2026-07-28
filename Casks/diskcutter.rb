cask "diskcutter" do
  version "2026.7.28"
  sha256 "e0f8a4aebe4adf4ddb8e9bd299ca64e7037ba216f0de21fcf0ec5b74ecd2ff70"

  # CalVer tags carry no `v` prefix, so the tag is the version verbatim. The
  # release workflow does stamp a `-0` stable-release suffix onto the bundle
  # version, so the asset filename carries it even though the tag does not.
  url "https://github.com/antimatter-studios/diskcutter/releases/download/#{version}/Disk.Cutter_#{version}-0_universal.dmg"
  name "Disk Cutter"
  desc "Disk-image writer with a parallel job queue and per-sector verification"
  homepage "https://github.com/antimatter-studios/diskcutter"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app itself runs on 10.13+, but :high_sierra has been removed from the
  # cask DSL; :catalina is the oldest symbol still accepted, and is already
  # older than any macOS Homebrew supports.
  depends_on macos: :catalina

  app "Disk Cutter.app"

  # Burning needs raw access to /dev/rdiskN, which macOS gates behind Full Disk
  # Access — granted per-app in System Settings on first burn, not by the cask.

  zap trash: [
    "~/Library/Application Support/com.diskcutter.app",
    "~/Library/Caches/com.diskcutter.app",
    "~/Library/Preferences/com.diskcutter.app.plist",
    "~/Library/Saved Application State/com.diskcutter.app.savedState",
    "~/Library/WebKit/com.diskcutter.app",
  ]
end
