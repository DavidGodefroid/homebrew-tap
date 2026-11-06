class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.10.0/lea_0.10.0_darwin_arm64.tar.gz"
      sha256 "d092fa2c89000bb5b40f5de7180fb3b0f047edd94b54dbbcac4baa18e10dee87"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.10.0/lea_0.10.0_darwin_amd64.tar.gz"
      sha256 "c0fc1bc2043dd06ffd60ca85e9436c21b09f023e192cbff6281a636d1f17add9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.10.0/lea_0.10.0_linux_arm64.tar.gz"
      sha256 "46d18d6663f0c77bf9e189a75efb26a47c9fdb72646b60e9256095d457c6aff7"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.10.0/lea_0.10.0_linux_amd64.tar.gz"
      sha256 "b08e07bf461efdbb0c9b85e5b1f105f5837537684c66c26d9eb56159e5aa15c2"
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
