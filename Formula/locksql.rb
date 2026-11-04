class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.1/locksql_0.16.1_darwin_arm64.tar.gz"
      sha256 "0c81a9aa32c01c67154e4afbcf31e3884678f011eb96a24b5f52314b4be1c87d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.1/locksql_0.16.1_darwin_amd64.tar.gz"
      sha256 "27bf0f14343e34b0b780b086cff5f62cbce8feccdef5add29e875a2382556664"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.1/locksql_0.16.1_linux_arm64.tar.gz"
      sha256 "2219f49859929e59e4ddf0dcb008e686bea35c1a3ed8616b07a93ed56ce89eb4"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.1/locksql_0.16.1_linux_amd64.tar.gz"
      sha256 "05011af7e14f08af3562e39552a7148993c8adc12d011d94e4e7ce66bfd87794"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:ae9d0a3857d17518beaf26df7608594a48ed93ba982058aaca922d5b1211d5bd"
    vault_image_digest = "sha256:1eb740766fce72d88bed43eaf0419cdbb014767a01029b918a1eb6eeaccf4a0b"
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
