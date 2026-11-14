class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.20.0/locksql_0.20.0_darwin_arm64.tar.gz"
      sha256 "7bc35c8117c9dda98e651515467357c56c3f3c49083666e85c6b440a6fee93d5"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.20.0/locksql_0.20.0_darwin_amd64.tar.gz"
      sha256 "1464d5f19f045a8a96646c2a7a99883a452107d8e51b62b29c5cc0911e6db9ed"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.20.0/locksql_0.20.0_linux_arm64.tar.gz"
      sha256 "c8981bf20fb0355e40d1b51a3bdf3d98ddc49370199ddec7edf6855ba9423ebb"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.20.0/locksql_0.20.0_linux_amd64.tar.gz"
      sha256 "c5e44f2bb398a0bb9b3860e3ab563483ff5e7b87b6bd199e1aa8cc290fb4df2b"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:cdc33538eb7d12d52cf86e0a4019c4c35b6f1c585a5fc86c6e3cbb7a81fe4e45"
    vault_image_digest = "sha256:656dbe0b4ce86e952169d9612b8e42d3f9a956210f1d6c500ed326cd7165bba4"
    inreplace "scripts/locksql" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/locksql"
  end

  def caveats
    <<~EOS
      locksql runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox add locksql
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade locksql`, not `locksql update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "locksql launcher #{version} (image ghcr.io/davidgodefroid/locksql@sha256:",
                 shell_output("#{bin}/locksql version 2>&1", 1)
  end
end
