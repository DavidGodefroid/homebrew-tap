class Lockmq < Formula
  desc "Harness security for AI agents on RabbitMQ, with masked queue reads"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.0/lockmq_0.9.0_darwin_arm64.tar.gz"
      sha256 "1290fd1a03a8c12a44fd79912c8b14c52ae3650e1272e922c2cbe822fd7047ed"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.0/lockmq_0.9.0_darwin_amd64.tar.gz"
      sha256 "cd7d3a3919c6fd8020b98bf2f27d32b9f11f576f4920d41ce1a8b7836471867d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.0/lockmq_0.9.0_linux_arm64.tar.gz"
      sha256 "8f85b1d4163c8073c320555be08596f075fdbff4c4c217817f8f1a28c97dccbc"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.0/lockmq_0.9.0_linux_amd64.tar.gz"
      sha256 "06759dc5909a118eb303c61e932570ea645a26fa8b02f8eef62f2dff82afac4c"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:2757a2481c8102fb885485d8ee10c124c4f04e1da1ac41a71f2f2ab06526bb7d"
    vault_image_digest = "sha256:09a4737de06b61010ab9fa92caf4a8fcf49730b1aa38b71ae0d6b66592290438"
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
