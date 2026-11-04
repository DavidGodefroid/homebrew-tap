class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.1/lea_0.7.1_darwin_arm64.tar.gz"
      sha256 "397e3b4a4948f82792d33998de16fd1147d9a67570576c758919d736ab3ebadc"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.1/lea_0.7.1_darwin_amd64.tar.gz"
      sha256 "9a19568c3e3e8695fdd39c4302b0b203309310824eb8df4b903f9a79f4694743"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.1/lea_0.7.1_linux_arm64.tar.gz"
      sha256 "7085eb0c7b254a9c575e27b879f85129276b3d4b14ad90d99a3d41d7f904f9c9"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.1/lea_0.7.1_linux_amd64.tar.gz"
      sha256 "addbac5d64c1decf28dee134fa266bd3f530ca6159046b119c06c66ad87a2407"
    end
  end

  def install
    # Homebrew owns upgrades: the daily background self-update (which installs
    # into ~/.local/share/lea-install and relinks ~/.local/bin/lea) is off by
    # default. A user configuration can still turn it back on.
    inreplace "config/lea.conf", /^LEA_AUTOUPDATE=1$/, "LEA_AUTOUPDATE=0"
    # bin/lea resolves its own links and runs build/lea of the same tree.
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/lea"
  end

  def caveats
    <<~EOS
      lea runs its agents in Docker: Docker Engine (Linux) or Docker Desktop
      (macOS) must be installed and running.
      Next step:
        lea
      Add a source with `lox add locksql` (or lockmq, lockfile, lockhttp); a
      lock added while lea runs needs `lea stop`, then `lea`.
      Upgrade lea with `brew upgrade lea`: its background self-update is off
      in this installation.
    EOS
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/lea version").strip
  end
end
