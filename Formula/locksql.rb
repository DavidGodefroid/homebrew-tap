class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.1/locksql_0.13.1_darwin_arm64.tar.gz"
      sha256 "b063dc1990ffaa3d54a0337465f6c41a197f42e1caea5c32bbb7d88c77ffa1f2"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.1/locksql_0.13.1_darwin_amd64.tar.gz"
      sha256 "5ecc1427f9e873f4c06e76729c0e49a010a37133b99a6f2c4da0257521216ae7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.1/locksql_0.13.1_linux_arm64.tar.gz"
      sha256 "0c0151cf8769d3592ffe09d9fbb3c4cc4cca7fdfa22c30fae38b0af36897663e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.13.1/locksql_0.13.1_linux_amd64.tar.gz"
      sha256 "ec9c9aed502a0b89bf6b89db0203b9c2acc32115c7f2e6d0fd1100f24d4493b5"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:5b18545fa4fb9d5bed1008a127628b59deae8194b74d92e226ae436f144bb90f"
    vault_image_digest = "sha256:77131a34b4272440a6247ffa7b4bdb2282a8913fd641ca43a6fa437d88de7573"
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
