class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.0/lea_0.6.0_darwin_arm64.tar.gz"
      sha256 "d8630815cb1ddedd5871ba4683ec826505512cf1d75a5d521fd1de74ac318dab"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.0/lea_0.6.0_darwin_amd64.tar.gz"
      sha256 "5ca309daba5726aebdecf7176186321e0b3a209f48b87629a0ff72aa134351a8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.0/lea_0.6.0_linux_arm64.tar.gz"
      sha256 "369bcd6c1dfed69d56e64dcf535761b651a2235eaaebb07847dde043f579ff03"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.0/lea_0.6.0_linux_amd64.tar.gz"
      sha256 "f46d63eba33ed03dd474be1f524a3164928884b09adc729f0b2d26eba34f18c2"
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
