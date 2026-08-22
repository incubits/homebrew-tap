cask "deter" do
  arch arm: "arm64", intel: "x86_64"

  # version + sha256 are rewritten by .github/workflows/release.yml on each tag.
  version "0.1.5"
  sha256 arm:   "d8c9933317ab3434228db5d27c835fa3dd5f3ddc26e96e2676cb88b7b538561a",
         intel: "f2b104d73d495f54b033a6080e6691249b848550d8371db4f50b1dba7ff42e33"

  # Source stays private (github.com/incubits/deter); only the built tarball is
  # published to the PUBLIC mirror below, so `brew install` needs no token.
  url "https://github.com/incubits/deter-dist/releases/download/v#{version}/deter-#{version}-darwin-#{arch}.tar.gz",
      verified: "github.com/incubits/deter-dist/"

  name "deter"
  desc "Run AI coding agents in an adversarially-isolated Docker sandbox"
  homepage "https://github.com/incubits/deter"

  # The tarball is laid out flat: the `deter` binary sits next to the asset tree
  # (image/, brokers/, broker/, shims/) it discovers at runtime by walking
  # up from its own path. Symlinking the binary is all that's needed.
  binary "deter"

  postflight do
    # Internal, unsigned build: strip the Gatekeeper quarantine xattr so the CLI
    # runs from the shell without being blocked. Proper fix is Developer ID
    # notarization in CI (see RELEASING.md) — remove this once that lands.
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", staged_path],
                   must_succeed: false
  end

  caveats <<~EOS
    deter sandboxes whatever repo you're in; it needs, on the HOST:
      • Docker Desktop or Podman  (auto-detected; override with DETER_DOCKER)

    Get started:
      cd ~/code/my-project
      deter init          # writes ./deter.yaml
      deter doctor        # checks docker/podman
      deter run claude    # first run builds images, then drops you into the agent
  EOS

  zap trash: [
    "~/.deter",
  ]
end
