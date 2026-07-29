cask "diskcutter" do
  version "2026.7.29-1"
  sha256 "1f6cdfa2aa51925af6ce02680538051180bbb42d366bb76bf2abac138e7a6510"

  # CalVer tags carry no `v` prefix, so the tag is the version verbatim, and the
  # asset now carries that same version. Previously the release workflow forced
  # a `-0` suffix onto the bundle regardless of the tag, so this url had to
  # append one; it stopped doing that, which is what makes a same-day hotfix
  # release such as this `-1` possible at all.
  url "https://github.com/antimatter-studios/diskcutter/releases/download/#{version}/Disk.Cutter_#{version}_universal.dmg"
  name "Disk Cutter"
  desc "Disk-image writer with a parallel job queue and per-sector verification"
  homepage "https://github.com/antimatter-studios/diskcutter"

  livecheck do
    url :url
    # github_latest's default regex is /v?(\d+(?:\.\d+)+)/i — digits and dots
    # only — so it truncates a hotfix tag like 2026.7.29-1 to 2026.7.29 and
    # audit then reports the cask as disagreeing with itself. Match the release
    # counter too.
    regex(/^v?(\d+(?:\.\d+)+(?:-\d+)?)$/i)
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
