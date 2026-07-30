# typed: false
# frozen_string_literal: true

# Maintained by this tap, not by the project that ships instantmailcheck.
#
# It used to be written straight into this repository by that project's release
# pipeline, which meant a push from another repository could change what
# `brew install instantmailcheck` fetches. The tap now pulls instead: "Sync
# formulae from releases" reads the public releases, hashes the assets it
# downloaded, and pushes a branch. A person opens the pull request and merges it.
# Only the version and the four checksums are rewritten by that workflow —
# everything else here is edited by hand.
#
# A formula rather than a cask, the same as chore and trove-cli: this ships a
# bare binary, and Homebrew does not quarantine what a formula installs. A cask
# does quarantine it, which for an unsigned binary means Gatekeeper kills the
# first run unless the cask also clears the attribute — a workaround a formula
# has no need of.
class Instantmailcheck < Formula
  # `brew audit` rejects a description over 80 characters. The wording the
  # generated file carried was 89.
  desc "Mail server diagnostics — DNS, SMTP, IMAP, POP3, TLS, DKIM/SPF/DMARC, MTA-STS"
  homepage "https://github.com/rest-mail/instantmailcheck"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/rest-mail/instantmailcheck/releases/download/v#{version}/instantmailcheck_#{version}_darwin_arm64.tar.gz"
      sha256 "5d65ae99b16e7ee448862afb395bdddad9cf26185e3d8b6b5ac68bc39be63e18"
    end
    on_intel do
      url "https://github.com/rest-mail/instantmailcheck/releases/download/v#{version}/instantmailcheck_#{version}_darwin_amd64.tar.gz"
      sha256 "751100c53eccae4c028ef1a8df3d5a2e8001e453540d69f6115b16bf7a03ac31"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rest-mail/instantmailcheck/releases/download/v#{version}/instantmailcheck_#{version}_linux_arm64.tar.gz"
      sha256 "c9dac8a02dd6c97df5289f2be163d8b2c6647e0b4fb006d5f6599fadb25fac29"
    end
    on_intel do
      url "https://github.com/rest-mail/instantmailcheck/releases/download/v#{version}/instantmailcheck_#{version}_linux_amd64.tar.gz"
      sha256 "f12d2ebb49b6de31ae2fda88afd027e8fda13a1ef1d4aa31d64f503967b2259c"
    end
  end

  def install
    bin.install "instantmailcheck"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/instantmailcheck --version")

    # Deliberately offline. Every real check this tool performs needs DNS or a
    # live mail server, and an audit of a domain chosen for not resolving exits
    # non-zero and reads differently depending on whose resolver answers — not
    # something to assert in a formula test. `--help` proves the binary runs and
    # parses its own flag set.
    help = shell_output("#{bin}/instantmailcheck --help")
    assert_match "instantmailcheck [flags] <domain>", help
    # Single dash: Go's flag package accepts either form on input but prints the
    # usage list with one.
    assert_match "-security-audit", help
  end
end
