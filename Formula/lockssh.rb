class Lockssh < Formula
  desc "Harness security for AI agents: approved SSH commands, masked output"
  homepage "https://github.com/DavidGodefroid/lockssh"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.1.0/lockssh_0.1.0_darwin_arm64.tar.gz"
      sha256 "c0307957109d7b23466ef26bc101add89abb1253cc8a625d55f325263759c3a2"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.1.0/lockssh_0.1.0_darwin_amd64.tar.gz"
      sha256 "4affc669367e16248bec9d5d0cd0483d3472a81f20eb4c6fa0bb9c794850fbab"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.1.0/lockssh_0.1.0_linux_arm64.tar.gz"
      sha256 "92fdbd197ba5da6a882712020d997bf000d4f4b3533f57319598c79170b66f41"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.1.0/lockssh_0.1.0_linux_amd64.tar.gz"
      sha256 "4dad6bed134c68268b82e96260520c97e3fcdc301d62d27c44f28b671f8bae2c"
    end
  end

  def install
    # lockssh runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:5db9e6aef9280a9e81eaa2d32dcb7e2596ba35df4db483a82ce1ae6731d393eb"
    vault_image_digest = "sha256:edddb61473d3d5975caa5c7a5c381971ab944f4571ef8a9a9272671489ad0dd5"
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
