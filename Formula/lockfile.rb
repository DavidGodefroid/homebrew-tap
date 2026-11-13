class Lockfile < Formula
  desc "Harness security for AI agents: yes/no questions about unread files"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.0/lockfile_0.9.0_darwin_arm64.tar.gz"
      sha256 "31c17076211331fc36cc9c03636626a42839d2fd0ed2df7abbbc67dfe858ed0a"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.0/lockfile_0.9.0_darwin_amd64.tar.gz"
      sha256 "f44d107e50c8c180690f22ed0b3df1ae35217b6d3d42332db0ae3c5612e1bff5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.0/lockfile_0.9.0_linux_arm64.tar.gz"
      sha256 "d8e5a0adf96789a8eff5bc7ef53777eddcd0e00e3c5183366476a1170a7e0e33"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.0/lockfile_0.9.0_linux_amd64.tar.gz"
      sha256 "e57d773933477c3c9b5fd36886abb5dd0713dcc522d70d82c41f7dfccee7a0c9"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:efdf346c57b5cccb4e041d741f3eb3aa471339333966398e98f877b3209bd046"
    vault_image_digest = "sha256:3b96cd94d0d79afaae6d57af98f0283f1a0931f094df343270334e924df0ed86"
    inreplace "scripts/lockfile" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
      s.gsub!(/^seccomp_profile=$/, "seccomp_profile=#{opt_pkgshare}/seccomp.json")
    end
    pkgshare.install "seccomp.json"
    bin.install "scripts/lockfile"
  end

  def caveats
    <<~EOS
      lockfile runs in Docker: Docker Engine must be installed and running.
      Next step:
        lox add lockfile
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade lockfile`, not `lockfile update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockfile launcher #{version} (image ghcr.io/davidgodefroid/lockfile@sha256:",
                 shell_output("#{bin}/lockfile version 2>&1", 1)
    assert_path_exists pkgshare/"seccomp.json"
  end
end
