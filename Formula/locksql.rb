class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.19.0/locksql_0.19.0_darwin_arm64.tar.gz"
      sha256 "1b4c22faac80ab59253fa8cba7d498c8b5523a7597f694e749e75287317fa0c2"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.19.0/locksql_0.19.0_darwin_amd64.tar.gz"
      sha256 "03d0d3b3cb6a69cae6373ab7106a6546017a154c5e76ef099edc90e567536735"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.19.0/locksql_0.19.0_linux_arm64.tar.gz"
      sha256 "ee764700805eeba2b656e28eb7bca4afd5031a0e839a834b17a5b10053c3283e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.19.0/locksql_0.19.0_linux_amd64.tar.gz"
      sha256 "efcdbb8d881c0dd1773060809a87e1da563d626036ecb77c4042e40e5b278059"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:47742db222055fc4509b93d55e7f2aa448f1aee3c504d45149ae1fe36473f07d"
    vault_image_digest = "sha256:64ce89b1c1f1d6d6000d6ff6cb5bacd501f0660ee6859347f28c779ba5ec6211"
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
