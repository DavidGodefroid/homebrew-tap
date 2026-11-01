class Lockmq < Formula
  desc "Human-approved, PII-masking RabbitMQ gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.7.0/lockmq_0.7.0_darwin_arm64.tar.gz"
      sha256 "299122237daab82be0cc61712ddea1606ae205c992d25b09285030bff0520e95"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.7.0/lockmq_0.7.0_darwin_amd64.tar.gz"
      sha256 "4de34be2b68ac26082d73d0ef3d2a4ac4f5cd2eb820c97bcbfe562016aeaa963"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.7.0/lockmq_0.7.0_linux_arm64.tar.gz"
      sha256 "91c0c27cc29330b585b84697d10c5dbcdcfecef6c39c07ae6ddbe529725d1c52"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.7.0/lockmq_0.7.0_linux_amd64.tar.gz"
      sha256 "115ae4834997d9735c972fb617509526c14dc177628a6a988e7f24e371f3b272"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:10a23d3f26e55b28d05ec71df6da465bd15cccaefe0d2dc75c0ee6ba171003cd"
    vault_image_digest = "sha256:a4f3bbd40b836ebe7007fdf44fa58723614554bb791f1a7ef984d61464c9424a"
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
