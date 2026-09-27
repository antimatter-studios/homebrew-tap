# pullbar — your GitHub pull request inbox in the menu bar.
#
# version and sha256 are owned by tap-sync, which reads projects.json, downloads the
# declared asset from the release and computes the digest itself. Do not edit them by
# hand.
#
# Built from christhomas/Pullbar (a fork of lucaspal/Pullbar) and signed with the
# christhomas Developer ID. Its release pipeline signs and notarizes every release
# and publishes it only after a verify job has checked that the downloaded app is
# notarized. Apple Silicon only.
cask "pullbar" do
  version "0.4.3"
  sha256 "7b4c939d301541eecbda3330937ec173e9c4b374ce7d85213b240dde41c49ab7"

  url "https://github.com/christhomas/Pullbar/releases/download/v#{version}/pullbar-#{version}-darwin-arm64.zip"
  name "pullbar"
  desc "Menu bar app showing your GitHub pull request inbox"
  homepage "https://github.com/christhomas/Pullbar"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "pullbar.app"

  uninstall quit: "dev.pullbar.menubar"

  zap trash: "~/Library/Preferences/dev.pullbar.menubar.plist"
end
