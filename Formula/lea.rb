class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.5.0/lea_0.5.0_darwin_arm64.tar.gz"
      sha256 "1d2681d526544660440852fc662b1ab5962a7401ca7e703f39f0f11669fcea09"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.5.0/lea_0.5.0_darwin_amd64.tar.gz"
      sha256 "0fabfdc4726e15cd0127f7ddc35347efdb9512de77d3c2949950fafc7f6d64e9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.5.0/lea_0.5.0_linux_arm64.tar.gz"
      sha256 "994a9aeaf6d15826ba1c420c6ffe41690be3ed6fb5b346e3fc587fd52b98ef55"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.5.0/lea_0.5.0_linux_amd64.tar.gz"
      sha256 "048ef0277372433e4ece037541d91be76564e580db5320514ba1c0b21a3a5128"
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
