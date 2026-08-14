# Snapshotter — local restore points without a backup drive.
#
# version and sha256 are owned by tap-sync, which reads projects.json, downloads the
# declared asset from the release and computes the digest itself. Do not edit them by
# hand. The shape of everything else is maintained upstream in
# packaging/homebrew/snapshotter.rb.
#
# Three choices here are deliberate, and are explained up here rather than beside the
# stanzas because brew style requires stanzas in a group to be contiguous:
#
#   * There is deliberately NO `binary` stanza, even though the same binary serves
#     both the window and the command line. This tap ships command-line tools as
#     formulae, and a cask that symlinks one onto PATH is refused by its own CI. The
#     CLI still exists inside the bundle, and putting it on PATH properly means a
#     companion formula fed by its own release asset — the trove-cli / trove-desktop
#     split.
#
#   * `uninstall launchctl:` stops both agents first. Without it launchd keeps
#     starting a binary that is no longer there, failing on every interval and
#     leaving the plists behind.
#
#   * `caveats` covers Full Disk Access, which mounting a snapshot cannot work
#     without and which no installer can grant on the user's behalf.
cask "snapshotter" do
  version "0.1.1"
  sha256 "e597e662da5d594b1c2a9e485ce6c09123902b6fa0a8cb6cc378ab383ad4c9de"

  url "https://github.com/antimatter-studios/snapshotter/releases/download/v#{version}/Snapshotter_#{version}_universal.dmg"
  name "Snapshotter"
  desc "Local restore points without a backup drive"
  homepage "https://github.com/antimatter-studios/snapshotter"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "Snapshotter.app"

  uninstall launchctl: [
              "com.christhomas.snapshotter",
              "com.christhomas.snapshotter.tripwire",
            ],
            quit:      "com.christhomas.snapshotter"

  zap trash: [
    "~/Library/Application Support/Snapshotter",
    "~/Library/LaunchAgents/com.christhomas.snapshotter.plist",
    "~/Library/LaunchAgents/com.christhomas.snapshotter.tripwire.plist",
    "~/Library/Logs/snapshotter-tripwire.log",
    "~/Library/Logs/snapshotter.log",
  ]

  caveats <<~EOS
    Snapshotter needs Full Disk Access before it can open a snapshot:

      System Settings -> Privacy & Security -> Full Disk Access -> add Snapshotter

    Mounting a snapshot also needs an administrator password, once per batch. Root
    alone is not enough: macOS checks Full Disk Access against the application making
    the call, so without the grant every attempt is refused with "Operation not
    permitted".

    The same binary also works as a command-line tool, though this cask does not put
    it on PATH:

      /Applications/Snapshotter.app/Contents/MacOS/snapshotter status

    Snapshots are not a backup. They live on the same disk as your data and protect
    against deletion, not against the disk failing.
  EOS
end
