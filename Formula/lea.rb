class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.0/lea_0.7.0_darwin_arm64.tar.gz"
      sha256 "ee9312d543f4dba9f41abc936d19884eb50be34cea6f5ce6deb70667372da741"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.0/lea_0.7.0_darwin_amd64.tar.gz"
      sha256 "5ecb3f26d614dad0cac65439c8175916636eea42f93546d320600bc82753a7c8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.0/lea_0.7.0_linux_arm64.tar.gz"
      sha256 "ab080e0ea653fe0ede30e76c02ad97a959af92f7eb7c94f419ef10fa21dca5e4"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.7.0/lea_0.7.0_linux_amd64.tar.gz"
      sha256 "6eb852ad976a08fd9cb6012b391265271179e9b6263e34b3cf2dc07154525c9f"
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
