class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.12.0/lockhttp_0.12.0_darwin_arm64.tar.gz"
      sha256 "a7743a1c0521620c7983d6e91834243002d2201c3c3762474eb3406309bf6483"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.12.0/lockhttp_0.12.0_darwin_amd64.tar.gz"
      sha256 "e321ef62c8643677e638a9c4bdf1c02bb14c47364bd6536f7d8740deed4dcf47"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.12.0/lockhttp_0.12.0_linux_arm64.tar.gz"
      sha256 "4cd59a1e0326648be1182bd6ddf155785f9eeba182f3030b8b7505cb199d5b50"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.12.0/lockhttp_0.12.0_linux_amd64.tar.gz"
      sha256 "319a61646fa4f9a8ae791b4fcbe3bde4e0404a7e3afa1f130a3c6f6283c80830"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as the
    # Lock Family's installer (https://lockfamily.dev/install.sh) installs it
    # without Homebrew. It runs the release image by the digest below,
    # verified with cosign when the formula was bumped (scripts/bump). The
    # binary of the archive is the one of the image.
    image_digest = "sha256:63621282ba743a581ed1e95303f50b82b8adeab4fd34afed36b675d7274ecc83"
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
