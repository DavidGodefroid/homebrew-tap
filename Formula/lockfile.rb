class Lockfile < Formula
  desc "Lets AI agents ask yes/no questions about files they never read"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.7.0/lockfile_0.7.0_darwin_arm64.tar.gz"
      sha256 "570227fe4de90ea7deca72eb2ed9f642c074a0d3f6789ef39fafbf7fd3a71425"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.7.0/lockfile_0.7.0_darwin_amd64.tar.gz"
      sha256 "3ede01853adcde032a6e0c3902882f01002b91a4e3868da5ae276aaefe25298a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.7.0/lockfile_0.7.0_linux_arm64.tar.gz"
      sha256 "9e75f029bb46769feea8635d1935abd6cb559843190c898a4d933cc93f5c4dc6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.7.0/lockfile_0.7.0_linux_amd64.tar.gz"
      sha256 "a53f6f79c4becda02dc64732c78d414c757253655d9e4685bf12709bfc06c2be"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:3dd40e9ce1638fc66bfd391e0a0424b635127595c05c94d68e34e8e699e3e513"
    vault_image_digest = "sha256:ae856de893f50187d11ceb3f9298b5230360fcc3c6b04f70f0e5e8f0fefe864b"
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
