# typed: false
# frozen_string_literal: true

# Version and checksums are kept current by "Sync formulae from releases",
# which reads the published assets and opens a branch for review.
class Vertrag < Formula
  desc "Contract-test an HTTP API against its OpenAPI description"
  homepage "https://github.com/antimatter-studios/vertrag"
  version "0.13.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-arm64.tar.gz"
      sha256 "1283d17389c568778146a875b3b2fa1764a9473af918a4333a4498e006fe3375"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-darwin-x86_64.tar.gz"
      sha256 "65d926fd71a92e157b78cd94410e63893b0aedf5b3c63efae803e0616ec2bc7b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-arm64.tar.gz"
      sha256 "24a32f2007f41ec7f4539893830f1963518f3abd995c5b9439f3520b110a9a9c"
    end
    on_intel do
      url "https://github.com/antimatter-studios/vertrag/releases/download/v#{version}/vertrag-#{version}-linux-x86_64.tar.gz"
      sha256 "0fd1bf1a1cfd01f672c19153e33b12dae6c29def0e56f947742f826dce521abf"
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
