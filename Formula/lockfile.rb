class Lockfile < Formula
  desc "Lets AI agents ask yes/no questions about files they never read"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.5.3/lockfile_0.5.3_darwin_arm64.tar.gz"
      sha256 "223cc61ed1266730b6ccfba56aa5a723cb28c481c2809d87fdb136ebc51c2801"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.5.3/lockfile_0.5.3_darwin_amd64.tar.gz"
      sha256 "9632dfcad84e6ecbc04fe4fc00ac42b29860d412fa6492ebf9568123e3fa5cd3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.5.3/lockfile_0.5.3_linux_arm64.tar.gz"
      sha256 "0c4c252eabb1b460f28e92e6cdf6fc08c793ddfd965b67367fb5e792ecfac127"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.5.3/lockfile_0.5.3_linux_amd64.tar.gz"
      sha256 "335b480cccb5efc2b49318222d925547076679befdf064e9794c941323cf6da8"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:96012e77503ea5ccb483031746c5a18b7123b3ad544d8645d9ade601237aafb7"
    vault_image_digest = "sha256:ea8b014dc7c1e73980115a07a3787b067ab964717b60cc47c41436c57d30df87"
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
        lox init
      Upgrade with `brew upgrade lockfile`, not `lockfile update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's: the
    # second part needs Docker, which a test cannot count on.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "lockfile launcher #{version} (image ghcr.io/davidgodefroid/lockfile@sha256:",
                 shell_output("#{bin}/lockfile version 2>&1", nil)
    assert_path_exists pkgshare/"seccomp.json"
  end
end
