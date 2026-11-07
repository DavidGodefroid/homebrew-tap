class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.1/locksql_0.17.1_darwin_arm64.tar.gz"
      sha256 "fae56cd9d8dbf3ebdcc0c76c82979633a183d09e6612a5ae9b96c63fba4fbd02"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.1/locksql_0.17.1_darwin_amd64.tar.gz"
      sha256 "46270a3c2be4fbde64ddde9fcbea5d7dcd91f507d8423c88d9f2a60d5e3131fc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.1/locksql_0.17.1_linux_arm64.tar.gz"
      sha256 "5e6aa5a92f6a02ef1ffae1a5bf3e6a35bea71a108340de8f0d5aed3f59b2c773"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.1/locksql_0.17.1_linux_amd64.tar.gz"
      sha256 "16b218a0de0b1f4c3a096c02642304dcecd0350c717fa7ecd5ef42e7c6cc2572"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:10c180c186a3d9dd3e3c67773480085e72688825787af05a9290f730d4096dc2"
    vault_image_digest = "sha256:8f6c187a75ba731668eae8aa6c02bab4b375f689eb93078bf3dab24e41380e2e"
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
