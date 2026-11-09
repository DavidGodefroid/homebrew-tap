class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.1/lea_0.15.1_darwin_arm64.tar.gz"
      sha256 "0eca6f02a8c6a0324a765eae15ba08f4625b1127f86b8774961b2edf14390a21"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.1/lea_0.15.1_darwin_amd64.tar.gz"
      sha256 "649c8e249c3be40e7f6aa264bb3468ea6f50f8fb6d7a1716736d0b5aa1f8fad7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.1/lea_0.15.1_linux_arm64.tar.gz"
      sha256 "77b90578c8a6296be7ae2b7a735687730ce756fff7f5ba3548ec36d5caa48228"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.1/lea_0.15.1_linux_amd64.tar.gz"
      sha256 "9a14b9ca321d739c813eb4c7acb92ae1086793ad1ddb4efc170285992eefbf41"
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
