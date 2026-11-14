class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.10.0/lockhttp_0.10.0_darwin_arm64.tar.gz"
      sha256 "0fc0c4dfa8b2a37ac6cb989c540686150803c6063d9da8735a44ec1952ea7017"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.10.0/lockhttp_0.10.0_darwin_amd64.tar.gz"
      sha256 "716c386696b45be9a687019f5751710cc0d0336f93a85e30cbdf53e179d305dc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.10.0/lockhttp_0.10.0_linux_arm64.tar.gz"
      sha256 "c798b66d38554f6a4f4f5852f127fbe47ec6f22b8ce3e1940d0a28ebd3819533"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.10.0/lockhttp_0.10.0_linux_amd64.tar.gz"
      sha256 "488bc08d63ff7d988ff99d6c1a54a5257c11cde78e639cdf491b54c28897b354"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:90d350bc04a9107b93627bd37b99620668eaaeac4cd3497b599581279b2f702b"
    inreplace "scripts/lockhttp" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
    end
    bin.install "scripts/lockhttp"
  end

  def caveats
    <<~EOS
      lockhttp runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox add lockhttp
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade lockhttp`, not `lockhttp update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockhttp launcher #{version} (image ghcr.io/davidgodefroid/lockhttp@sha256:",
                 shell_output("#{bin}/lockhttp version 2>&1", 1)
  end
end
