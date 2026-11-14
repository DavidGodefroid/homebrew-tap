class Lockssh < Formula
  desc "Harness security for AI agents: approved SSH commands, masked output"
  homepage "https://github.com/DavidGodefroid/lockssh"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.3.0/lockssh_0.3.0_darwin_arm64.tar.gz"
      sha256 "51e0578468f6bbfe16e99f0def788c677b6879624160601713faacfc4da6b761"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.3.0/lockssh_0.3.0_darwin_amd64.tar.gz"
      sha256 "64f0eb0900aeb727a0b930bd7324bea63a29c5668dd67637c31efa94d408d14c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.3.0/lockssh_0.3.0_linux_arm64.tar.gz"
      sha256 "36818cce7940b4207f3836d60d6e2ed8f3c8ac87c9fae51ef5e567ba5b0a3987"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.3.0/lockssh_0.3.0_linux_amd64.tar.gz"
      sha256 "7d20fdda269a2d6e2760a772a0de749bee0e002abc85ac2846b21380ce7348aa"
    end
  end

  def install
    # lockssh runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:f0ea17672943a7bdf8ba6765f0ec8c83c4adbf26a41752abc572344145940312"
    vault_image_digest = "sha256:63cac65fdfbd97d02bfe1c2472112cc90db4837dd715a527645e5e226d9dd3c9"
    inreplace "scripts/lockssh" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/lockssh"
  end

  def caveats
    <<~EOS
      lockssh runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox add lockssh
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade lockssh`, not `lockssh update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockssh launcher #{version} (image ghcr.io/davidgodefroid/lockssh@sha256:",
                 shell_output("#{bin}/lockssh version 2>&1", 1)
  end
end
