class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.1/lockhttp_0.8.1_darwin_arm64.tar.gz"
      sha256 "4a2c5f65e3dfa1b4f21b54cc737b252b7420e4ebf570c2de9b87d3b401b2fa84"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.1/lockhttp_0.8.1_darwin_amd64.tar.gz"
      sha256 "27dea381126138c63275ac4eb6672f096c097133e5f3a9e97ae4c0385e26bf93"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.1/lockhttp_0.8.1_linux_arm64.tar.gz"
      sha256 "ec36919efc2a16cdc99660b57d7f3877a912176c865e26cdb7fbe302a65ce918"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.1/lockhttp_0.8.1_linux_amd64.tar.gz"
      sha256 "1cbd3896100fb66f983dbdd0632508a2755ef8ec5ae0a7334f3889351e34e99f"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:f60da7464f61d564c6f5c7040f087845f5767e97f14670d28f2c05219d2ff270"
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
