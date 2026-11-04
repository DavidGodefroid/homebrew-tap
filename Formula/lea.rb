class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.1/lea_0.8.1_darwin_arm64.tar.gz"
      sha256 "93fed68d1bc9a726302c7cf5d2cc3320b8f9453ae1efb9a50c75f00d9051ee35"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.1/lea_0.8.1_darwin_amd64.tar.gz"
      sha256 "a7c58606be9c7d425c33d9e7a5154623ba67b99c6ffd51dff87f9a72d8d8167a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.1/lea_0.8.1_linux_arm64.tar.gz"
      sha256 "8dfc72f3b9505e2891b5563e12f3ec1ab18827b2906dd522116a9022a171683d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.1/lea_0.8.1_linux_amd64.tar.gz"
      sha256 "f7dbe24f8c8fcbf696aaa13c30691c1939cc5234fcd31c2e80ff0fc5029410a0"
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
