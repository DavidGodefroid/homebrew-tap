class Lockmq < Formula
  desc "Harness security for AI agents on RabbitMQ, with masked queue reads"
  homepage "https://github.com/DavidGodefroid/lockmq"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.1/lockmq_0.9.1_darwin_arm64.tar.gz"
      sha256 "a6263b77406e515ae5294322e34a27a3b52eb7a5cee4a571b617a729d32a5910"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.1/lockmq_0.9.1_darwin_amd64.tar.gz"
      sha256 "f553401f2e3f7f11c223e4ca3519260fe096b9288a054bc620100bce3f7fd225"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.1/lockmq_0.9.1_linux_arm64.tar.gz"
      sha256 "0f8cd0b072aaaa524b09c31014e4a7722f79bd06ac143bdc6ed6b53b09d234d3"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockmq/releases/download/v0.9.1/lockmq_0.9.1_linux_amd64.tar.gz"
      sha256 "d04104bca08d66a11d4b31fcb903e75aae7dc77d9db7bb696846418f3cb6ce62"
    end
  end

  def install
    # lockmq runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:c02644a785779dd163d5abe50a4337835393856e50339de45c6bdad153054061"
    vault_image_digest = "sha256:150eb4a3e7b130bda5e43b83b1445cbf0f732fa124582061cb3a5f2f93bbc74c"
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
