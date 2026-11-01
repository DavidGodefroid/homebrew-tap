class Lockhttp < Formula
  desc "Human-approved HTTP(S) egress proxy for AI agents"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.1/lockhttp_0.7.1_darwin_arm64.tar.gz"
      sha256 "bbd6f6fa0f17ed0a2f9876313deb5104d345979d63f52cdb07d7e87c01d14833"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.1/lockhttp_0.7.1_darwin_amd64.tar.gz"
      sha256 "912467d3abf8f8f8b5a3b24423ff1f1d7777e3138564ea6ee0f3be69f763a58c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.1/lockhttp_0.7.1_linux_arm64.tar.gz"
      sha256 "ea7ab07c4b49f1722eb0be32ed012daa344493388941e57cdc929ea8956e2fe9"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.7.1/lockhttp_0.7.1_linux_amd64.tar.gz"
      sha256 "e0d2c618193c1949661ff9e80d69e51bc13682a88bd6571bc16b65bdfe1d31b3"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:e0f4b3ca35c8bc65dfe293d932ffadff4ec48464c33a0f5ad2927075257dad54"
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
