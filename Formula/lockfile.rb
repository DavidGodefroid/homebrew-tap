class Lockfile < Formula
  desc "Harness security for AI agents: yes/no questions about unread files"
  homepage "https://github.com/DavidGodefroid/lockfile"
  license "Apache-2.0"

  depends_on :linux

  # Linux only (depends_on :linux); the macOS archives are named so that the
  # formula still loads on macOS, as Homebrew requires.
  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.0/lockfile_0.8.0_darwin_arm64.tar.gz"
      sha256 "82a1edc8ed99933d30fce3c66a748b7eac969b6ce6212fa883a29fd7cec3a971"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.0/lockfile_0.8.0_darwin_amd64.tar.gz"
      sha256 "2b60adb0ec43137997b2abad81eafe8722bacd0445b3bd2700d4ba4527ecd7d6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.0/lockfile_0.8.0_linux_arm64.tar.gz"
      sha256 "1e799bec88d60fcbad72f6132392f557d50f5988bafee821864f57da1511ff81"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockfile/releases/download/v0.8.0/lockfile_0.8.0_linux_amd64.tar.gz"
      sha256 "9f90886d3663a56a903330c1de0fb4289553504d6cf025b92d117a4050190f64"
    end
  end

  def install
    # lockfile runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it, with the seccomp profile of its
    # console's container. It runs the release images by the digests below,
    # verified with cosign when the formula was bumped (scripts/bump).
    # The binary of the archive is the one of the image.
    image_digest = "sha256:1cda92af7746bbf76b16f09f35a746a797f95c70faa1961ba094d52cd57ff36b"
    vault_image_digest = "sha256:27f29a0d4f4aa7234949da8888c7f76843a054f2a5e8e610535c551b6ac1a5c2"
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
