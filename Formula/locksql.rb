class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.0/locksql_0.18.0_darwin_arm64.tar.gz"
      sha256 "a74599bab6e1158c5d7c3f663f6c11fe53eb4a8f9d8cefbd5d90cf7b7bbf1609"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.0/locksql_0.18.0_darwin_amd64.tar.gz"
      sha256 "b848e4bd6e9b39145a4729881d7e5b5317fe9787ea54f96e192fee06f64f2c78"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.0/locksql_0.18.0_linux_arm64.tar.gz"
      sha256 "5992b34b972bf27e0ed3f302070177b1c2afc1c042dbd647a3a5ce073abb2964"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.0/locksql_0.18.0_linux_amd64.tar.gz"
      sha256 "1a2d090596544d159c2483d1bbfd7b06c454da016319b7b3676bea917301eda5"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:6279a17c00065decd9c8ee939a21f683b32dea52aece541b8509ca7647bf3cd9"
    vault_image_digest = "sha256:11930f0c699c872e1b7b6af2ca315ee65040ae5120b8d685148db231c4645d9f"
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
