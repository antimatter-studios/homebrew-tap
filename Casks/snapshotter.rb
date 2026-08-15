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
#   * `binary` symlinks the bundle's own executable onto PATH rather than installing
#     a second copy. It is the same file, so the two can never report different
#     versions — and, more importantly, it runs as the bundle. macOS attributes Full
#     Disk Access to the executable making the call, so a separately installed copy
#     would need its own grant before `snapshotter browse` could mount anything. This
#     way the grant the user gives the application covers the command line too.
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
  binary "#{appdir}/Snapshotter.app/Contents/MacOS/snapshotter"

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

    The same binary is on PATH as `snapshotter`. It is symlinked into the bundle
    rather than copied, so it runs with the application's identity and the Full Disk
    Access granted above covers the command line too:

      snapshotter status

    Snapshots are not a backup. They live on the same disk as your data and protect
    against deletion, not against the disk failing.
  EOS
end
