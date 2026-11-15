class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.2/lea_0.17.2_darwin_arm64.tar.gz"
      sha256 "e40ea4f045caac5621e82bd42ef42a3f38ef7c2d152c49fe8a63de748d439031"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.2/lea_0.17.2_darwin_amd64.tar.gz"
      sha256 "24ffef7654854490663b3b7d65e6c022e8061244448e94f23cc369c1f0557e62"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.2/lea_0.17.2_linux_arm64.tar.gz"
      sha256 "c49109776a3127a916006166db8e034337275b79633fa8fbd837801c4da1dcb3"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.2/lea_0.17.2_linux_amd64.tar.gz"
      sha256 "419c7e83509e5909f27884eef6073339f51d9b291b245c414df402aa4e43a003"
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
