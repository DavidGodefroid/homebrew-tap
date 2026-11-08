class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.2/locksql_0.17.2_darwin_arm64.tar.gz"
      sha256 "5a2e8c1e922ba0d281be75b96f7f91452c3b99f3576effd1b8018597009524a6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.2/locksql_0.17.2_darwin_amd64.tar.gz"
      sha256 "a08234db9b76f9b0a4ba8e49c50094c262fca9fdae37812185094e271d04df6f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.2/locksql_0.17.2_linux_arm64.tar.gz"
      sha256 "753d1b804fff38a949320dcc0ae61b232e7be5491726e29140dd7bf844763620"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.2/locksql_0.17.2_linux_amd64.tar.gz"
      sha256 "e57d884c65e9f7a4baeae8ef9593ae18d7d5ff1185ff63f288b8e4f69eb9e633"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:b5d1464fe02538ca9bbaacdb9c64290d8471ab758ac0c047d21fb90b98f3d0ea"
    vault_image_digest = "sha256:b9680135d8daa88b32b2332bf5f0059143319c5d1102defce178d9909324e566"
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
