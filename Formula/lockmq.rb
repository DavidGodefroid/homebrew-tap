class Lockmq < Formula
  desc "Harness security for AI agents on RabbitMQ, with masked queue reads"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.10.0/lockmq_0.10.0_darwin_arm64.tar.gz"
      sha256 "db7273c8b4bd9ab6ed688606d4813718dfe6cbec1aeffd789a1c00adfc9a85d7"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.10.0/lockmq_0.10.0_darwin_amd64.tar.gz"
      sha256 "28d86ef247ee75e2218c5d680786a078eacbac3e7a5e99481ebd4f1ce5b40ed1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.10.0/lockmq_0.10.0_linux_arm64.tar.gz"
      sha256 "cf546c313a801da031ca4b63413622934a4e5e6922169dd7caac66836f097be6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.10.0/lockmq_0.10.0_linux_amd64.tar.gz"
      sha256 "2b9d96149f84565dc22d348b6cec5b196525ab353f02dc982de926a8dfe4c0f6"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:08a8cf46d6ac5d8f4d77557c1dad21a94935084d091371061f7866321c66584c"
    vault_image_digest = "sha256:8514484bf0b08ebbaef5a16a5c9482d5694cbd74ff3c1fc7ed1ba83eaeb8fce4"
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
