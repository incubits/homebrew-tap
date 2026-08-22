cask "deter" do
  arch arm: "arm64", intel: "x86_64"

  # version + sha256 are rewritten by .github/workflows/release.yml on each tag.
  version "0.1.2"
  sha256 arm:   "f96f062df195e96e20b1d3487cdc7ab420ec4c3306e20580bb5e6e7fd84ac7de",
         intel: "66a7b6063911c48854cc05c302bc25ed1f8fa08e478f0a257b380b0a17e9ab7a"

  # Source stays private (github.com/incubits/deter); only the built tarball is
  # published to the PUBLIC mirror below, so `brew install` needs no token.
  url "https://github.com/incubits/deter-dist/releases/download/v#{version}/deter-#{version}-darwin-#{arch}.tar.gz",
      verified: "github.com/incubits/deter-dist/"

  name "deter"
  desc "Run AI coding agents in an adversarially-isolated Docker sandbox"
  homepage "https://github.com/incubits/deter"

  # The tarball is laid out flat: the `deter` binary sits next to the asset tree
  # (image/, brokers/, broker/, bin/, shims/) it discovers at runtime by walking
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
      • python3  (macOS Command Line Tools) — used by the host clipboard watcher

    Get started:
      cd ~/code/my-project
      deter init          # writes ./deter.yaml
      deter doctor        # checks docker/podman + python3
      deter run claude    # first run builds images, then drops you into the agent
  EOS

  zap trash: [
    "~/.deter",
  ]
end
