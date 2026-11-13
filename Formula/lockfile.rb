class Lockfile < Formula
  desc "Harness security for AI agents: yes/no questions about unread files"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.1/lockfile_0.9.1_darwin_arm64.tar.gz"
      sha256 "68574ab86621f696261b52f2652952571c5f578de6e0683906a0c3e11ab74309"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.1/lockfile_0.9.1_darwin_amd64.tar.gz"
      sha256 "a4d065610042134525e9042469432b792d26fb9465064ac1708cc91740809b33"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.1/lockfile_0.9.1_linux_arm64.tar.gz"
      sha256 "39aba354e537e571197665e02beb2061e797b20a2b1cc6bc4f14e2ca0a39dddd"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.9.1/lockfile_0.9.1_linux_amd64.tar.gz"
      sha256 "ee5eabca7329e905cfe30e479129f0d16f1db9af22c3862025423a7f155cf57f"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:75f301f6d25c54b2e2079a3328225bc1c5196976ceaad0e82970d0122c16f281"
    vault_image_digest = "sha256:e6728353cf28d0ff37954dca10ee3139575b40d73639c4d7fd52e9a7ca857b86"
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
