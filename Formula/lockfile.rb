class Lockfile < Formula
  desc "Harness security for AI agents: yes/no questions about unread files"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.10.0/lockfile_0.10.0_darwin_arm64.tar.gz"
      sha256 "62fd57360e888256fc55e07af9a96bf1b32f551aaf546e32645a6cb8c0241b01"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.10.0/lockfile_0.10.0_darwin_amd64.tar.gz"
      sha256 "5224c12a4fe94b88e7974617a53befabe3c234e87398431159ebc2a573413ac1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.10.0/lockfile_0.10.0_linux_arm64.tar.gz"
      sha256 "543a98f2a9c162bc5edcc356845098765dac524e492f1230023b8ebb705cb2ee"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.10.0/lockfile_0.10.0_linux_amd64.tar.gz"
      sha256 "29ddb89bebb7e79d551b2356958c1dcd55745e8c89eb8b0432cb350f268393b4"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:1ac32807118060678f927eb2beaac6286f15e29ce06edb25971270b5610f7da7"
    vault_image_digest = "sha256:0986219b34178c279f57244c08e8106ce94c41b8bc03af7e2a993890479dfcc7"
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
      `lox add` and `lox run` need lox and cosign 2.5 or later:
        brew install davidgodefroid/tap/lox cosign
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
