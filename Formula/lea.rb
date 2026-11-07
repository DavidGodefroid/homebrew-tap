class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.12.0/lea_0.12.0_darwin_arm64.tar.gz"
      sha256 "9e7c012deda19546f8b745eedcfbd185082e65bba7e3143d162307c5aeff4012"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.12.0/lea_0.12.0_darwin_amd64.tar.gz"
      sha256 "dbc5b24c225c93c4c5d22550ce0b548fa68f9f5dede7a470f528e0ff9e8e5727"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.12.0/lea_0.12.0_linux_arm64.tar.gz"
      sha256 "3ea67b52ec7ac7e5d5db83653f74a32c0fd8d6f2e5b2730a0826527219a988bb"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.12.0/lea_0.12.0_linux_amd64.tar.gz"
      sha256 "e60da6adc5fc1182b120e2073b46353792a78b13805a4e7eeda0785586a47a89"
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
