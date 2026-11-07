class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.1/locklog_0.2.1_darwin_arm64.tar.gz"
      sha256 "665fb1c00d08ceb725bb3a2bdbe941a59d72fe959e6688ec682f537d59c7f4de"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.1/locklog_0.2.1_darwin_amd64.tar.gz"
      sha256 "95de1fb23525e272dabacb730cbbb9f3962d769ac2284d32879726c4dba89157"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.1/locklog_0.2.1_linux_arm64.tar.gz"
      sha256 "7af680bcbfc77c3b474086a6888c9c3ad7a8e342528c4cf60c5d51ccf97d6795"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.2.1/locklog_0.2.1_linux_amd64.tar.gz"
      sha256 "8d5f921ea93e64e76e63966c5ea7ebf8a1fa11ff0ce4ad9f9e20cb92bb2c2faf"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:e7388fce3a032638a2388ff061df96922560c42a107848fc4e72afe38dbb6752"
    vault_image_digest = "sha256:8869068a2ffe240ac402cfeef3636a91945f5c889a9748e10f4d8958c9380185"
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
