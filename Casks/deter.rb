cask "deter" do
  arch arm: "arm64", intel: "x86_64"

  # version + sha256 are rewritten by .github/workflows/release.yml on each tag.
  version "0.1.15"
  sha256 arm:   "3f93c21723730d46b1e8408658e2fc0aaff2f9ca9fa67186fe3b65b6e3cf58bc",
         intel: "1c16548aef940680743bc5989c1a6208f4b25fec48acc38d570ab8b1ff467299"

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
