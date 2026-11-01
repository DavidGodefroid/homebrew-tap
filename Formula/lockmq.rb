class Lockmq < Formula
  desc "Human-approved, PII-masking RabbitMQ gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.5.0/lockmq_0.5.0_darwin_arm64.tar.gz"
      sha256 "3c270515996b231df1e0cc5015c83818f8abe2bc26a42d3efef12f0e7e055001"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.5.0/lockmq_0.5.0_darwin_amd64.tar.gz"
      sha256 "609a872506edf69259cabd6fff4b798f4a7ffd3c537bb6e930787d5ab92e1b71"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.5.0/lockmq_0.5.0_linux_arm64.tar.gz"
      sha256 "98a9f65a0c672cdb418dc426b8c4b7caf29ccd98fdad39355744038c74c64389"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.5.0/lockmq_0.5.0_linux_amd64.tar.gz"
      sha256 "fe602fb5c23cd2bc08bb5205f4059173f256377887630a658a390f87e70abf02"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:fb60fc527aa49b2d7b326056aae8f232dd88fdb7137d709f670d47c6e0ab369d"
    vault_image_digest = "sha256:a2213db88b60be61d4f9c003ce28afb2be549f202921ecbe374d0a321bfeaf02"
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
