class Lockssh < Formula
  desc "Harness security for AI agents: approved SSH commands, masked output"
  homepage "https://github.com/DavidGodefroid/lockssh"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.1/lockssh_0.2.1_darwin_arm64.tar.gz"
      sha256 "f6edc29ab0eaabf6de7e7ba851b9761a14f2ec809d13eded836d79b2de9d8d10"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.1/lockssh_0.2.1_darwin_amd64.tar.gz"
      sha256 "baec38da42583971760a20b5c32898bbe158d743e24d2c6c8aa58bf6d368e9fd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.1/lockssh_0.2.1_linux_arm64.tar.gz"
      sha256 "263997715063444750ab57812c945bf600384dc2b57f1687940a381593b9ed29"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockssh/releases/download/v0.2.1/lockssh_0.2.1_linux_amd64.tar.gz"
      sha256 "facd18fcb5e1924fdc25dc9b779cd5a4981a6831f4be9e6165194efd47e6fb35"
    end
  end

  def install
    # lockssh runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:836a42f001eb279880a63458f61d7bb92b692c63c96ae09328e9c29077cca35e"
    vault_image_digest = "sha256:a48fc7fd9870dbac01e50c3443cd3cc2ebc05b2d97fddda770c33412d69ad36f"
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
