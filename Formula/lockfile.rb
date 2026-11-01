class Lockfile < Formula
  desc "Lets AI agents ask yes/no questions about files they never read"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.6.0/lockfile_0.6.0_darwin_arm64.tar.gz"
      sha256 "a099e8354a4c6d97277ebeaf53d849ef2918e59c0f3a1330d54b1d16a7dedcb9"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.6.0/lockfile_0.6.0_darwin_amd64.tar.gz"
      sha256 "01ba925002020515dc247035e3cf6e68cbc8e9bca969b0507efaf6b38b89a470"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.6.0/lockfile_0.6.0_linux_arm64.tar.gz"
      sha256 "755d1f327d54a7b6733bf091dee4f337bd8018488db6f605185e3f1c7442fe4c"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.6.0/lockfile_0.6.0_linux_amd64.tar.gz"
      sha256 "911695a7a439fe84a20e8977b2d4e757bdea929c7508d8473d019d5d4bbd4a35"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:12ba284d25087a14f84c13d81a312822069fc5128b0511da7d320f20b4d2d48b"
    vault_image_digest = "sha256:04e3a0beeee5de9b94e79daf205202f0ab7f64214c7b6717b0e308a7c4cb598d"
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
