class Lockmq < Formula
  desc "Human-approved, PII-masking RabbitMQ gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.1/lockmq_0.6.1_darwin_arm64.tar.gz"
      sha256 "b238e5c2c3655516d88f4fcad3e864f5ad25cc177649465f2cb551a58ebc4d37"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.1/lockmq_0.6.1_darwin_amd64.tar.gz"
      sha256 "4132c6026785696ba34f9746cdc2af1f3beaecd41ba1f3f875804f05997a8146"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.1/lockmq_0.6.1_linux_arm64.tar.gz"
      sha256 "ef247bf54743b7b1db289e68a8442d174dfec0ed28080358017a22765a781e0c"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.6.1/lockmq_0.6.1_linux_amd64.tar.gz"
      sha256 "5f2a8e1358d210dfb38281dcb6f84e7d7e000efd93baef308397feee3b63b576"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:f89ee8ecc4419f62190b961fef19275120784c28916ed2bb72ea42e4a905d88e"
    vault_image_digest = "sha256:6432185d83baaf26cc61af4ab158a9c8ff500ebcbcc351261bc3d311f7076159"
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
