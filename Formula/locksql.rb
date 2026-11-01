class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.0/locksql_0.13.0_darwin_arm64.tar.gz"
      sha256 "bd4e90f802f1ed8316f42a40b960eed4ad51b8501dfa5790b33eb2b37f505372"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.0/locksql_0.13.0_darwin_amd64.tar.gz"
      sha256 "051bda7b630a74a0d18105320e0bb4f6f73463caab1232065014e7fc29014d8f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.0/locksql_0.13.0_linux_arm64.tar.gz"
      sha256 "5717fd94770e8e548859fd9e310e9b4e99514df941552c0dc8b9521ba9b24238"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.0/locksql_0.13.0_linux_amd64.tar.gz"
      sha256 "08f49155e4f703a14518d0bb6d57959b095e72335187b2fbbeb1da7b8c707cd9"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:d4e53412ef04d87d309aabb0fb98e33eb29f151cab3e1b8e420332e9aa2e2781"
    vault_image_digest = "sha256:667ca84e7d03d3f210504e87ede7bf4ceef0f992f5f6b549f243bc0db1b1a0ac"
    inreplace "scripts/locksql" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/locksql"
  end

  def caveats
    <<~EOS
      locksql runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox init
      Upgrade with `brew upgrade locksql`, not `locksql update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "locksql launcher #{version} (image ghcr.io/davidgodefroid/locksql@sha256:",
                 shell_output("#{bin}/locksql version 2>&1", 1)
  end
end
