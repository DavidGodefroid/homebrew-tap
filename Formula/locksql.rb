class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.12.0/locksql_0.12.0_darwin_arm64.tar.gz"
      sha256 "bf2386d033c917722a774573f07faf55b35a135f0677de434bc2cdb1abf09272"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.12.0/locksql_0.12.0_darwin_amd64.tar.gz"
      sha256 "2428199e05912959c339115c9ba8ba922d952bf888435159608ad06cac1169d4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.12.0/locksql_0.12.0_linux_arm64.tar.gz"
      sha256 "6dd93071a0e244e2240d24a79ea6a9216106b806de01d50d36af1e74518c6a85"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.12.0/locksql_0.12.0_linux_amd64.tar.gz"
      sha256 "90508455b9565f5afacded9f12e24aaf10c77c784791d4292d448c5e0ca8db21"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:fe034b3f550dafd2da99af15f4bc0920d2eb1c111d3c2fa84818411925fea6c7"
    vault_image_digest = "sha256:78d963a864c7354c02a83f6584aa1b1e5ce2401556699b45979478a078296f2c"
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
        lox init
      Upgrade with `brew upgrade locksql`, not `locksql update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's: the
    # second part needs Docker, which a test cannot count on.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "locksql launcher #{version} (image ghcr.io/davidgodefroid/locksql@sha256:",
                 shell_output("#{bin}/locksql version 2>&1", nil)
  end
end
