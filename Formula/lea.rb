class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.0/lea_0.15.0_darwin_arm64.tar.gz"
      sha256 "05b8d95d077e0e5481b29546e11411ddbb6c245c7c93251e62a8fdcd77cb6a2d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.0/lea_0.15.0_darwin_amd64.tar.gz"
      sha256 "1a57734892e0c178fb835c22c3258b8bbd553c1e9d18558f5259754bfeac8d5f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.0/lea_0.15.0_linux_arm64.tar.gz"
      sha256 "54789175b5365eb8c6b37c2bbb6a3ead2f248e1b82b848129a299f415e2982be"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.15.0/lea_0.15.0_linux_amd64.tar.gz"
      sha256 "b82ae9dcb3d3fd264b093178bf209ae30467d15150ebaf8cbbb5c39b6de476c5"
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
