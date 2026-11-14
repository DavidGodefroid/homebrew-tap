class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.2/locksql_0.18.2_darwin_arm64.tar.gz"
      sha256 "33e6018c8466d2112d8e09178bba9715af38c976f5a559a55fe754c02821a19b"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.2/locksql_0.18.2_darwin_amd64.tar.gz"
      sha256 "8942a900a85157915dae6d91ab7adc807427f6f8c42c14bfd336cad8f02a5f9b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.2/locksql_0.18.2_linux_arm64.tar.gz"
      sha256 "ceb143d24040616502f2d92262a06d31c2de186db9a4073711ebe5dea902844c"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.2/locksql_0.18.2_linux_amd64.tar.gz"
      sha256 "138f95d7d0fba369e249507f5548b680dd8a3edfd371ac69196ed015aaac7df3"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:431998f6004542b8af8b8da39b871b33dcf22214d165bb4b4970b471163ece29"
    vault_image_digest = "sha256:179d27ac1feb1ee03f85880a939a36cb34138f2f49b3128681db39dd12e149ff"
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
