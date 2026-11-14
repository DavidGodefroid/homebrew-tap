class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.0/lea_0.17.0_darwin_arm64.tar.gz"
      sha256 "b3f0e4ea758133d597e991c9d2f0829c5eaf190218f4f87f38c1d0f5754460de"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.0/lea_0.17.0_darwin_amd64.tar.gz"
      sha256 "5f553b88ed2d2b393a3c75b4eddab397e5614e160c75a0fd8e6c0a0f7e1c83d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.0/lea_0.17.0_linux_arm64.tar.gz"
      sha256 "b2f456f18b7d6ac1eb92d94eeeb253e847026b221f44dd584a3f3bbc9e8926a4"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.0/lea_0.17.0_linux_amd64.tar.gz"
      sha256 "66622743843f26e112afc4c0f8df48858d0bb62735776b6fe829232cbfa1ce0d"
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
