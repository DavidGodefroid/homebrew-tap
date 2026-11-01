class Lockhttp < Formula
  desc "Human-approved HTTP(S) egress proxy for AI agents"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  version "0.6.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v#{version}/lockhttp_#{version}_darwin_arm64.tar.gz"
      sha256 "aa1e96b1e11e828c0439752d829740ac2eeba629c25c5d390a6246756a63d589"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v#{version}/lockhttp_#{version}_darwin_amd64.tar.gz"
      sha256 "387ea400e4906e94aaed8e5da1605d3f9faea7ddc48227498909dbc02d8827d1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v#{version}/lockhttp_#{version}_linux_arm64.tar.gz"
      sha256 "f53ba0142d54c5ee8fd431f722b8b5ca041d59400146daf3be230335ef574f83"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v#{version}/lockhttp_#{version}_linux_amd64.tar.gz"
      sha256 "deefea22cd93818804f1d5abc3b2d46ef822223180a12e5b685dbbb834ec340c"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:dfb204742b5fa9f8b166bf64866b909ee65292b6afa8ff5fd5496042e6f8fca6"
    inreplace "scripts/lockhttp" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
    end
    bin.install "scripts/lockhttp"
  end

  def caveats
    <<~EOS
      lockhttp runs in Docker: Docker Engine (Linux) or Docker Desktop (macOS)
      must be installed and running.
      Next step:
        lox init
      Upgrade with `brew upgrade lockhttp`, not `lockhttp update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's: the
    # second part needs Docker, which a test cannot count on.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockhttp launcher #{version} (image ghcr.io/davidgodefroid/lockhttp@sha256:",
                 shell_output("#{bin}/lockhttp version 2>&1", nil)
  end
end
