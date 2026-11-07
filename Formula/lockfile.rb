class Lockfile < Formula
  desc "Harness security for AI agents: yes/no questions about unread files"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.1/lockfile_0.8.1_darwin_arm64.tar.gz"
      sha256 "a8b7d369d3ff4c564725143f0cc41b2b81ef47d973df438aba6254a5b2ae174d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.1/lockfile_0.8.1_darwin_amd64.tar.gz"
      sha256 "1bcf584b5ef47676a5167b3fa1c25f537efb2df2c11f8881f1e3a5ee5e22cbd0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.1/lockfile_0.8.1_linux_arm64.tar.gz"
      sha256 "7c909c390cfb248a5949f047d3f655745ffb4aa5e51ded60a3bf5919aef20223"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.1/lockfile_0.8.1_linux_amd64.tar.gz"
      sha256 "8489752e6a80eb88a8aaedf9b0e7c9e08c363dcccaee9604458c537e722c0479"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:7c7efa5a10ddce1ebccca08ad3af9404337554bfb510e12f08957bef4aee3a13"
    vault_image_digest = "sha256:c65508652955c811bd5b85db75cff96fb0f2331c9c8f2629c9dcb26e5c24395a"
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
