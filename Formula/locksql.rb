class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.2/locksql_0.16.2_darwin_arm64.tar.gz"
      sha256 "1a8631c9156caa044c7b221751b226aed5e770b62ad40127867c382b62fdd2b6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.2/locksql_0.16.2_darwin_amd64.tar.gz"
      sha256 "5eeed0234f036162f136186bcb8ba50b40b09a4fe796c846bc763bb096e59770"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.2/locksql_0.16.2_linux_arm64.tar.gz"
      sha256 "d2fa311f0d83c39d5ef886c495a1ca0b5c02aeefa5d6ab2de0846d9b85828cba"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.2/locksql_0.16.2_linux_amd64.tar.gz"
      sha256 "18be48c72d4fd50762064b0775bee2688359cbc4a14871e806ed5e521fbfa8b7"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:7f1c304d828db776ab14844529871480d916e51580c2c7320b5bf435500b1410"
    vault_image_digest = "sha256:4e261e5bbbfc8eb7c6941c19a9a430a1048fdbd60c79e113226b5b9c51d8990a"
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
