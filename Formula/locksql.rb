class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.3/locksql_0.18.3_darwin_arm64.tar.gz"
      sha256 "0ab51ea9aac29a5e09c50ec81307ce3bfceef2edc2d18bd8f765374ae1e63cde"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.3/locksql_0.18.3_darwin_amd64.tar.gz"
      sha256 "637df86f7a38c70207d8a8bbd5027729f98ffc8d567636f021c64b05532efb51"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.3/locksql_0.18.3_linux_arm64.tar.gz"
      sha256 "10dfd88c722cbbc1fa63a11fd28c2be282d1058466890c19ee2b74ae30be6ec1"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.3/locksql_0.18.3_linux_amd64.tar.gz"
      sha256 "da39dc5591e2886d463309eb64ca6c766be5ef8b90c75eed9d52b2ef90100cad"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:2b3c85a9bba542ca19b4f4cef3ee90b53ef354168e9a72609ce0ffb492f6c67a"
    vault_image_digest = "sha256:19d44ff4905ef58939b090ee3b78629eccb4cd874679244d5e03ed977b147d42"
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
