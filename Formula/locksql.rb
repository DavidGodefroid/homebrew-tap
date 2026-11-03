class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.0/locksql_0.16.0_darwin_arm64.tar.gz"
      sha256 "68ca68a522fdb957744a9686c0664f12e0995f8debb415db9de312a91ac1ce71"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.0/locksql_0.16.0_darwin_amd64.tar.gz"
      sha256 "09ff9c66a7a54b8d77d2be01736a89e52a7bacfd7bdc3ee45afa9731a4257e1c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.0/locksql_0.16.0_linux_arm64.tar.gz"
      sha256 "53e2e6ee05d240a260e4980b8c0c30a5ba04b2b234aacadc6b0aeb26dd3db8d7"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.16.0/locksql_0.16.0_linux_amd64.tar.gz"
      sha256 "b30b4f4a49b3ec755e5289d8f4a9664666e0b51dde11dab66902fea1351690cd"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:9aa8981fa8ee37f2f6150ed683b43c5a2a723ea0f72f726a23613cfb88b4fa49"
    vault_image_digest = "sha256:252fd2027fbcb1a745eddb2c882850ad45f52cd0224b2023f4650d99e6a46596"
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
