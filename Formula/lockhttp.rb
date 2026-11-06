class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.0/lockhttp_0.8.0_darwin_arm64.tar.gz"
      sha256 "a5d5ec0a4a667939bbbb78565dc2172a7af1cc508d9b9e48992949e1b7e6cdf3"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.0/lockhttp_0.8.0_darwin_amd64.tar.gz"
      sha256 "1e8ac2d452b5f8474ea97cc98b582f4fc7e378040c2d05af7e80cfc7c0775f07"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.0/lockhttp_0.8.0_linux_arm64.tar.gz"
      sha256 "f7daf9b7e2887ad8c85a4a4ae32b275b35afbef35b32c9f8fdfca014a452382e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.8.0/lockhttp_0.8.0_linux_amd64.tar.gz"
      sha256 "3f976bdd086edc4e26671522bda6d1360678ff464e234db23ad6c4eaa8fcdc1e"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:e1b0cbe3dd51b119c9aa04e02725749cda67f054d808c265fbc310ed3aed9708"
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
