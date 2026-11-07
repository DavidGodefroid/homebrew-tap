class Lockmq < Formula
  desc "Harness security for AI agents on RabbitMQ, with masked queue reads"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.1/lockmq_0.8.1_darwin_arm64.tar.gz"
      sha256 "d5c255be346a8249863751fc275fd3cf7c1ea1930c65f5dde0cd2c0de7e70f56"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.1/lockmq_0.8.1_darwin_amd64.tar.gz"
      sha256 "8fe366cc4c4bef2a92eea47803df83d32f9d0424d3d010952cd562fdca5d1116"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.1/lockmq_0.8.1_linux_arm64.tar.gz"
      sha256 "b597f2509dc94b894680e63ea1a615431e5ac1d9449da07cc20eaab5592d78ad"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.1/lockmq_0.8.1_linux_amd64.tar.gz"
      sha256 "b8c355c8f9d9a369c502638e54999fccf3b4724fd7b3b40421b9607c6720a2cc"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:12035d2da0a97aec6edbac9b48937d4881c4d5709c56bab715d31818850899a2"
    vault_image_digest = "sha256:34db86434000b3113d4cd2ea8dc931faa06ee2d6b414d66b64105bbb800b21e6"
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
        lox add lockmq
      (with lea: run lea first; it starts the hub)
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
