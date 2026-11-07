class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.0/locklog_0.2.0_darwin_arm64.tar.gz"
      sha256 "adb59c8aa19d0eb47045b23d532b76931be9c7cc4262efd945a3525a355134f3"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.0/locklog_0.2.0_darwin_amd64.tar.gz"
      sha256 "d3aa7963302d9fc94e7f4e89c1763e7e8a4fd7ff170f1ab44bc32237277a29ab"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.0/locklog_0.2.0_linux_arm64.tar.gz"
      sha256 "d9a37c132c480937a9e2d967ae7b99d1884feb4055f1da8525878747d9ff6841"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.0/locklog_0.2.0_linux_amd64.tar.gz"
      sha256 "e463bd57616a788d94b5844fb635032dec140a83ae494974300384f4dc285ce9"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:8b9730e2b4584604862c697214e4cd51350c2c07ac8d71d1b3d6851d32a771c2"
    vault_image_digest = "sha256:20fd9a38eefd29a6e0b9e2b8fd36657367f76440509c28c053bd1ce71011dc95"
    inreplace "scripts/locklog" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/locklog"
  end

  def caveats
    <<~EOS
      locklog runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      macOS reads remote log sources (Loki, Elasticsearch/OpenSearch); local
      log sources are Linux only.
      Next step:
        lox add locklog
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade locklog`, not `locklog update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "locklog launcher #{version} (image ghcr.io/davidgodefroid/locklog@sha256:",
                 shell_output("#{bin}/locklog version 2>&1", 1)
  end
end
