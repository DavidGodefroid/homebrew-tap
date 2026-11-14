class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.11.0/lockhttp_0.11.0_darwin_arm64.tar.gz"
      sha256 "ce7ed50fa5d04f9386f58cabb355817fca626c15cc08c1bd421b736a96fab078"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.11.0/lockhttp_0.11.0_darwin_amd64.tar.gz"
      sha256 "308c3cff0eb2a6b71ed541f31ace11a478695cd1b153277f4d4d8b15f0d9bfa4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.11.0/lockhttp_0.11.0_linux_arm64.tar.gz"
      sha256 "686010fb32cbb500af52a801605f82efd4b52dd07d4047e8a16747ffe0d6597d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.11.0/lockhttp_0.11.0_linux_amd64.tar.gz"
      sha256 "fad76769a912b5fb582695006401d619566726f64ae579b30bbb85eebc8957a3"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:e2685b31eac092a79f2e27a365c1ced60f980043f5352bf8076f02e113dea62e"
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
