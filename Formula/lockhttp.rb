class Lockhttp < Formula
  desc "Harness security for AI agents: approved HTTP(S) egress proxy"
  homepage "https://github.com/DavidGodefroid/lockhttp"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.1/lockhttp_0.9.1_darwin_arm64.tar.gz"
      sha256 "cc9a7276c1ba37fc3966782d522013471a52a45dac5e5740f639f4d724c7d109"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.1/lockhttp_0.9.1_darwin_amd64.tar.gz"
      sha256 "64bdbca0b4c7747105f05b2753e8e52096fdfd1e0ee2b6f46340c5233ded1eb0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.1/lockhttp_0.9.1_linux_arm64.tar.gz"
      sha256 "53780ab3b3abcd1586c9d7c336efe73bbc9bfa8b2b6401c4017a09bd906e0895"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhttp/releases/download/v0.9.1/lockhttp_0.9.1_linux_amd64.tar.gz"
      sha256 "c53f14945b4ec417cb826e209ded6116770a2719274a62981cec38ca974b7305"
    end
  end

  def install
    # lockhttp runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release image by the
    # digest below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:29a48e7a659bd1dc21bec36426e12933926f32b44a2b16a58fe509e510f7fd5a"
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
        lox add lockhttp
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade lockhttp`, not `lockhttp update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockhttp launcher #{version} (image ghcr.io/davidgodefroid/lockhttp@sha256:",
                 shell_output("#{bin}/lockhttp version 2>&1", 1)
  end
end
