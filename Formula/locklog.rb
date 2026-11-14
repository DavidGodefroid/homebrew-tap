class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.1/locklog_0.3.1_darwin_arm64.tar.gz"
      sha256 "8535a3c68ece8ebfa596a2d554a446cafae2293f13b666e1927582947863840e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.1/locklog_0.3.1_darwin_amd64.tar.gz"
      sha256 "91baa589c004347ee70cfd3bc02b4b6282cacdc3685517547f0915cee35c643e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.1/locklog_0.3.1_linux_arm64.tar.gz"
      sha256 "259158e2dba7a3180924806c4d6329b67414821d70915501b9eb5da0f1c71c43"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.1/locklog_0.3.1_linux_amd64.tar.gz"
      sha256 "cb6d3959337bfdf9c69ab018a6032b974aba4d8f770aece7e034a9a0d8d3e35a"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:c51fef8eb0893bb2b293908ac00ef04620b706f34c964fdce59c4d4c61306f4c"
    vault_image_digest = "sha256:d09881ff5911b78c68b7835a29470678d8b220eb8d84b9fb407c254433124f31"
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
