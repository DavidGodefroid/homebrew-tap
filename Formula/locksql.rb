class Locksql < Formula
  desc "Harness security for AI agents on SQL databases, with PII masking"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.1/locksql_0.18.1_darwin_arm64.tar.gz"
      sha256 "d1b11fc1bee55435d1227480c10b13f3b69c27c3758aa57546b15cb677e6eb71"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.1/locksql_0.18.1_darwin_amd64.tar.gz"
      sha256 "0b4cf879b994344b401efb4ba479b4aeea17e3782b14cd896293a7120aee4d4b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.1/locksql_0.18.1_linux_arm64.tar.gz"
      sha256 "9c50a4e64776c26650a291957a1167092d8395815d5f5b06659e7f9379c32059"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.18.1/locksql_0.18.1_linux_amd64.tar.gz"
      sha256 "368080ee4c2c2f453b0958f9dfedf4c55aa514037b2e8711cb91ff22866c3021"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:e38cf3e73858e25ca66c232c691a2bc118c1d51ad4256c75978709ab29420144"
    vault_image_digest = "sha256:70169e306b752ea8e31ae95f8ddb3c546942c5afbe9eba85f0c791dff8940ad0"
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
