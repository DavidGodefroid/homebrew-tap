class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.0/locksql_0.17.0_darwin_arm64.tar.gz"
      sha256 "b13a144af52ddbf9f55342fa4179d407149e98efffdda0f7adf37d50ff668d01"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.0/locksql_0.17.0_darwin_amd64.tar.gz"
      sha256 "413b73c4240636a35e5015100b5433ae4820ad9c21a72df3153596b348e95c34"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.0/locksql_0.17.0_linux_arm64.tar.gz"
      sha256 "f42c4d9e24483b3d3d28993767645252b2b06f19fbc16236a464c907360d0212"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.17.0/locksql_0.17.0_linux_amd64.tar.gz"
      sha256 "e6f132bc8b24f5b0aaae1e6b94c9cf907127341cd0a611738be5e00f845d48d5"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:4725a2a4ae22cef214904798fcbbc0b4d36832839d6cf027d921d0c6c571b785"
    vault_image_digest = "sha256:6284393ca9ae90fc8f27f164bed4cfb0cbb64393b25c50fdc1f3f5bbb08e40c6"
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
