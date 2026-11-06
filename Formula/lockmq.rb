class Lockmq < Formula
  desc "Harness security for AI agents on RabbitMQ, with masked queue reads"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.0/lockmq_0.8.0_darwin_arm64.tar.gz"
      sha256 "ace1a4ee7aa90daac57aaf328b3c78e7e7769f183dcc24086716275d85ae50b4"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.0/lockmq_0.8.0_darwin_amd64.tar.gz"
      sha256 "9f460cb0f696e12bfd8bd37c2bcf3117fff8033c765236d3feaf92df0b56ff23"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.0/lockmq_0.8.0_linux_arm64.tar.gz"
      sha256 "bc9adcde3b3aefbcef06c530d109477b16cf5635a844d343781d981f7b20ea16"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.8.0/lockmq_0.8.0_linux_amd64.tar.gz"
      sha256 "679609c036c8859fcad5bda7c74d569b92b7ad14566c2c59588b13f7fb3b4242"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:9102d0de0980ee6967e283b2f73911f7ed699a20d4a1e415e8351d8c9d487a41"
    vault_image_digest = "sha256:1d7134365cb1f07e293b85dc38987d4eadc4eaf2c7833ab75ad6e6d7cfdf08be"
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
