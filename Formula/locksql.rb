class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.15.0/locksql_0.15.0_darwin_arm64.tar.gz"
      sha256 "3fbbe3907cd0e6406daae2352305b018e2204854a23d8c75d59e520f906e18e8"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.15.0/locksql_0.15.0_darwin_amd64.tar.gz"
      sha256 "73ec9f60e24c79f3670fff28b4870058a4a1944b15d905b2c9ece242eb4c0fe1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.15.0/locksql_0.15.0_linux_arm64.tar.gz"
      sha256 "cb7aced87c36806330b658b8981776ebbfebb13e654035a934c2a5fbb2a3c39f"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.15.0/locksql_0.15.0_linux_amd64.tar.gz"
      sha256 "87a472de52efc13c394357bc603deea7f7a4f253dcc322d5e44f9730be173236"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:b1f0e35bdc9189bbc000fd65f8bcd9769d1595fe6d5f89becb184c1f801f736b"
    vault_image_digest = "sha256:843ba4f0e2f0e29df812d836ed4049076ac09071af0c4dc21bea022683b221fa"
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
        lox add locksql
      (with lea: run lea first; it starts the hub)
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
