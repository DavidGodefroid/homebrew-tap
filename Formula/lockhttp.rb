class Lockhttp < Formula
  desc "Human-approved HTTP(S) egress proxy for AI agents"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.0/lockhttp_0.7.0_darwin_arm64.tar.gz"
      sha256 "3beb9698309bffad052999daba24637d92a5bc692ee9b34d51dab3c565d32f10"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.0/lockhttp_0.7.0_darwin_amd64.tar.gz"
      sha256 "51be7d0d7e3774b1d1583b5232517b1f27e643e51f81dc93424735706c4239f4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.0/lockhttp_0.7.0_linux_arm64.tar.gz"
      sha256 "ce2d0c8fc0a97dce6afe3052404fb5fa9e21b8a76a8a9f5cce523c72f10acce8"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.0/lockhttp_0.7.0_linux_amd64.tar.gz"
      sha256 "2900d1f505d4734b0f4a6ee0da7c198b26ba23a9e21230fb0c44d3d167252ace"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:212bbe866766896eb201e5da43763810feaa5384b32e809097f73025b1f886c6"
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
        lox init
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
