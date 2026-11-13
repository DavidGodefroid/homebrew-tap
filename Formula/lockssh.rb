class Lockssh < Formula
  desc "Harness security for AI agents: approved SSH commands, masked output"
  homepage "https://github.com/DavidGodefroid/lockssh"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.0/lockssh_0.2.0_darwin_arm64.tar.gz"
      sha256 "430b4c89bc6550c30779f89d330642c7d0bc8201d638158b22e699916d8fe98b"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.0/lockssh_0.2.0_darwin_amd64.tar.gz"
      sha256 "87c855a814abd2dc24ba2f6ba6c0ffbfa1614093517c1561e162206a64405f38"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.0/lockssh_0.2.0_linux_arm64.tar.gz"
      sha256 "a42bc343c5682bed7aa087c3f95ced68fe1d99f8b5d266fe71344f4e7940afbe"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.0/lockssh_0.2.0_linux_amd64.tar.gz"
      sha256 "f8845839b73204838335fc341c3d5e04cd6579deb780c2292b663b8724411cc2"
    end
  end

  def install
    # lockssh runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:6c97add789606ed1daaacecd7689644504d730ca9d14d83a9186312ad3f9f45c"
    vault_image_digest = "sha256:86429dd537ea407033d964dcfd3dd0bd3ab6d7f940e69aaa0ba535649920c1e0"
    inreplace "scripts/lockssh" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/lockssh"
  end

  def caveats
    <<~EOS
      lockssh runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox add lockssh
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade lockssh`, not `lockssh update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockssh launcher #{version} (image ghcr.io/davidgodefroid/lockssh@sha256:",
                 shell_output("#{bin}/lockssh version 2>&1", 1)
  end
end
