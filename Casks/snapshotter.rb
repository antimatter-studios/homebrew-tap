# Snapshotter — local restore points for macOS without a backup drive.
#
# version and sha256 are owned by tap-sync, which reads projects.json, downloads
# the declared asset from the release and computes the digest itself. Do not edit
# them by hand. The shape of everything else is maintained upstream in
# packaging/homebrew/snapshotter.rb.
cask "snapshotter" do
  version "0.1.1"
  sha256 "e597e662da5d594b1c2a9e485ce6c09123902b6fa0a8cb6cc378ab383ad4c9de"

  url "https://github.com/antimatter-studios/snapshotter/releases/download/v#{version}/Snapshotter_#{version}_universal.dmg"
  name "Snapshotter"
  desc "Local restore points for macOS without a backup drive"
  homepage "https://github.com/antimatter-studios/snapshotter"

  livecheck do
    url :url
    strategy :github_latest
  end

  # LSMinimumSystemVersion in the bundle says 12.0.
  depends_on macos: ">= :monterey"

  app "Snapshotter.app"

  # The same binary serves the window and the command line, so linking it puts
  # `snapshotter list` / `status` / `take` / `run` on PATH without a second
  # download. It must point inside the installed bundle rather than at a copy:
  # Full Disk Access is granted to the bundle, and a separate copy of the binary
  # would be a different identity with no grant.
  binary "#{appdir}/Snapshotter.app/Contents/MacOS/snapshotter"

  # Uninstalling has to stop the two agents first. Without this, launchd keeps
  # running a binary that is no longer there, which fails every interval forever
  # and leaves the plists behind.
  uninstall launchctl: [
              "com.christhomas.snapshotter",
              "com.christhomas.snapshotter.tripwire",
            ],
            quit:      "com.christhomas.snapshotter"

  zap trash: [
    "~/Library/Application Support/Snapshotter",
    "~/Library/LaunchAgents/com.christhomas.snapshotter.plist",
    "~/Library/LaunchAgents/com.christhomas.snapshotter.tripwire.plist",
    "~/Library/Logs/snapshotter.log",
    "~/Library/Logs/snapshotter-tripwire.log",
  ]

  caveats <<~EOS
    Snapshotter needs Full Disk Access before it can open a snapshot:

      System Settings -> Privacy & Security -> Full Disk Access -> add Snapshotter

    Mounting a snapshot needs an administrator password as well, once per batch.
    Root alone is not enough — macOS checks Full Disk Access against the
    application making the call, so without the grant every open is refused with
    "Operation not permitted".

    Snapshots are not a backup. They live on the same disk as your data and
    protect against deletion, not against the disk failing.
  EOS
end
