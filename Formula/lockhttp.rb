class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.0/lockhttp_0.9.0_darwin_arm64.tar.gz"
      sha256 "76f77e6dd38d60a42f4fac374f50e1042ae8a7ad01692c6a3950093bb39d4e53"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.0/lockhttp_0.9.0_darwin_amd64.tar.gz"
      sha256 "dcc70c3f4e6f937d81de3ed88cac0cc797aeff6f435b702aecdab622655ff577"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.0/lockhttp_0.9.0_linux_arm64.tar.gz"
      sha256 "b3ef11faaa4c1e656bd64bbea8af4892c7f114b39501741630b64b93576b4912"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.0/lockhttp_0.9.0_linux_amd64.tar.gz"
      sha256 "f043ac5a7eb9967d720a20f87e308d5cd9d4cde67e3db6f9beed7d284b2982fc"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:3f4081e6d2b902b23ad8e6599140534071369bc5d87db060d54162da95a30f96"
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
