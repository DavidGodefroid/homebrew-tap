class Lockmq < Formula
  desc "Human-approved, PII-masking RabbitMQ gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.0/lockmq_0.6.0_darwin_arm64.tar.gz"
      sha256 "decfeea1dd19f2c06a4f44826335cb9f43276ffb789345117c371615b40b5de1"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.0/lockmq_0.6.0_darwin_amd64.tar.gz"
      sha256 "5b5d65af3b4a90a9536912130efe0f8e0c8703ab59d419eb48eaf0e100686eba"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.0/lockmq_0.6.0_linux_arm64.tar.gz"
      sha256 "6f5bc3a451f8a595584fe43f323e9df41b460c66461df9576fad5839892e6af0"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.0/lockmq_0.6.0_linux_amd64.tar.gz"
      sha256 "e02bb32043a2b62500912396dee01ea5c9cdd7e357e0002f94f984cb85f51332"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:60d190a4e45a605cfc63d3418c26f7b5592eca248a49560df39bf1adf287fcb5"
    vault_image_digest = "sha256:493f3a9ee90cc65b80f0dd9791bb96746e4d226733b3e4814d6731a17e26fb3c"
    inreplace "scripts/lockmq" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/lockmq"
  end

  def caveats
    <<~EOS
      lockmq runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox init
      Upgrade with `brew upgrade lockmq`, not `lockmq update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockmq launcher #{version} (image ghcr.io/davidgodefroid/lockmq@sha256:",
                 shell_output("#{bin}/lockmq version 2>&1", 1)
  end
end
