class Locksql < Formula
  desc "Human-approved, PII-masking database gateway for AI agents"
  homepage "https://github.com/DavidGodefroid/locksql"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.14.0/locksql_0.14.0_darwin_arm64.tar.gz"
      sha256 "780f5b3699d237570ecfc64dc38d4ab3098b2dd36ded44ba6d80962004d1a378"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.14.0/locksql_0.14.0_darwin_amd64.tar.gz"
      sha256 "82552c56aebda934a3e53c28c91c8e3c59c671e1ec0f9a8fc884ef9021b15278"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.14.0/locksql_0.14.0_linux_arm64.tar.gz"
      sha256 "824719af8322d368e2a1e3adfb8501ded56174712f8c3a42acfabda89aeb1c71"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locksql/releases/download/v0.14.0/locksql_0.14.0_linux_amd64.tar.gz"
      sha256 "953647a320477f577f7fec197a41377494f98bcc648bde9437a436a512526481"
    end
  end

  def install
    # locksql runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:812016c06b9178c07b6bd413a2bc462ec10f6fb1e6c8799c9818a56f59d922c9"
    vault_image_digest = "sha256:a224865dfa5f59e7a7ecfa7352010a1e1ea7eba2b87c077de8211bf7e1df5908"
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
