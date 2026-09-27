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
  version "0.4.1"
  sha256 "15489b281ed971d935f74d04410fe5fd68ad658d7901ed0b28164fe58b162d7c"

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
