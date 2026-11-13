class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.0/locklog_0.3.0_darwin_arm64.tar.gz"
      sha256 "2ffe8e811e16551512f3f5109b676304a7087cc716cea397246971828a76c840"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.0/locklog_0.3.0_darwin_amd64.tar.gz"
      sha256 "b3b64cd7eb018293c9d5ea053b535c65f8db8e6ea001e077f0e037bc6f028e99"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.0/locklog_0.3.0_linux_arm64.tar.gz"
      sha256 "4cae2886eaedd92df1b8199691384fcc7f8cb5fd5a93824ba16e03cee854cb62"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.3.0/locklog_0.3.0_linux_amd64.tar.gz"
      sha256 "595c8ee21fbb38398aa292cb8204ed3ce1a4bf58236b988885b6e67187c6d849"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:200ea6a2883d87ec16f37e479c791a40b30dbd2f53b4f684a4274d87cf47c08c"
    vault_image_digest = "sha256:90b17df475507f27eb77fd01cbc3b51fe4b3970cf6396297be8865e0d77e75d7"
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
