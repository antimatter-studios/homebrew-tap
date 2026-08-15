# typed: false
# frozen_string_literal: true

# Version and checksums are kept current by "Sync formulae from releases",
# which reads the published assets and opens a branch for review.
class Vertrag < Formula
  desc "Contract-test an HTTP API against its OpenAPI description"
  homepage "https://github.com/antimatter-studios/vertrag"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-arm64.tar.gz"
      sha256 "cb7c8bad5da32ba6c45263a0284cbec1bb47cea69dbfe0c9453c5ec1ca32b6cb"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-x86_64.tar.gz"
      sha256 "4e025c524d45ace0af7af390ecf67e8c5d50c74a2cb9e31b1d7f4f1e349e3e13"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-arm64.tar.gz"
      sha256 "66d4cb505fd69c4369ec1360eb92ec7f7e1ecf3cf5ea0348c6e58491c3041ace"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-x86_64.tar.gz"
      sha256 "2d8eac938966f1b7cb07a72062fa2e39ab18cf2dc9c801c9f72e0f4ff47c7302"
    end
  end

  def install
    bin.install "vertrag"
  end

  def caveats
    <<~EOS
      vertrag is a Go implementation of Dredd. It reads an API description,
      derives the requests that description promises, and checks a running
      server's responses against them.

      It is early: the transaction compiler is complete and verified against
      Dredd, but the format parsers and the test runner are still being written.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vertrag --version")

    # A real compile, run end to end: this proves the binary parses API
    # Elements, walks the resource tree and derives a concrete request — not
    # merely that it starts.
    (testpath/"api.json").write <<~JSON
      {
        "element": "parseResult",
        "content": [
          {
            "element": "category",
            "meta": { "classes": { "element": "array",
              "content": [{ "element": "string", "content": "api" }] } },
            "content": [
              {
                "element": "resource",
                "attributes": { "href": { "element": "string", "content": "/machines" } },
                "content": [
                  {
                    "element": "transition",
                    "content": [
                      {
                        "element": "httpTransaction",
                        "content": [
                          { "element": "httpRequest",
                            "attributes": { "method": { "element": "string", "content": "GET" } } },
                          { "element": "httpResponse",
                            "attributes": { "statusCode": { "element": "string", "content": "200" } } }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    JSON

    output = shell_output("#{bin}/vertrag compile --media-type application/vnd.oai.openapi #{testpath}/api.json")
    assert_match "/machines", output
    assert_match "\"method\": \"GET\"", output
    assert_match "/machines > GET > 200", output
  end
end
