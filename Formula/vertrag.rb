# typed: false
# frozen_string_literal: true

# Version and checksums are kept current by "Sync formulae from releases",
# which reads the published assets and opens a branch for review.
class Vertrag < Formula
  desc "Contract-test an HTTP API against its OpenAPI description"
  homepage "https://github.com/antimatter-studios/vertrag"
  version "0.15.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-arm64.tar.gz"
      sha256 "23dd434e95554edbef7e16c46554f992dedf497b7948230a295a80c542b2024a"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-x86_64.tar.gz"
      sha256 "4a4bbe6bfd2a963df657da6e09eddef17d412e9785175627c00c878164aa4c26"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-arm64.tar.gz"
      sha256 "c6001a06f6b8cef34303a39c1941b0cb185930248a2e1588bc793c4a33b6d447"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-x86_64.tar.gz"
      sha256 "9d7fd3ddf0495a6c2722adf5183b518ed89e8470e42a6622e2387de5542d3778"
    end
  end

  def install
    bin.install "vertrag"
  end

  def caveats
    <<~EOS
      vertrag reads an API description, derives the requests that description
      promises, sends them at a running server and checks the responses.

      A project already configured for Dredd needs no arguments — vertrag reads
      the same dredd.yml, and runs the same Node.js hook files unchanged:

        vertrag run

      Or point it at a description and an endpoint directly:

        vertrag run openapi.yml http://localhost:4000

      Node.js is needed only if you use hook files.

      Reads OpenAPI 3 (including 3.1) and OpenAPI 2 (Swagger).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vertrag --version")

    # A real description, compiled end to end: this proves the binary parses
    # OpenAPI, expands the URI and derives a concrete request — not merely that
    # it starts.
    (testpath/"openapi.yml").write <<~YAML
      openapi: "3.0.0"
      info:
        title: Machines
        version: "1.0.0"
      paths:
        /machines/{id}:
          get:
            summary: Read a machine
            parameters:
              - name: id
                in: path
                required: true
                example: "42"
            responses:
              "200":
                description: OK
                content:
                  application/json:
                    schema:
                      type: object
                      properties:
                        name:
                          type: string
    YAML

    output = shell_output("#{bin}/vertrag compile #{testpath}/openapi.yml")
    assert_match "\"uri\": \"/machines/42\"", output
    assert_match "\"method\": \"GET\"", output
    assert_match "Machines > /machines/{id} > Read a machine > 200 > application/json", output

    # A dry run reaches the point of sending without needing a server.
    dry = shell_output(
      "#{bin}/vertrag run --dry-run --no-color #{testpath}/openapi.yml http://127.0.0.1:1",
    )
    assert_match "1 transaction(s), none sent (dry run)", dry
  end
end
