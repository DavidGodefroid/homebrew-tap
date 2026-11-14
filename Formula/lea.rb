class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.16.0/lea_0.16.0_darwin_arm64.tar.gz"
      sha256 "83a04b53c67f45e158f791ca03e4c5973a5e9efa954d45ae945ea4197cf4fd7a"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.16.0/lea_0.16.0_darwin_amd64.tar.gz"
      sha256 "3f042d2f431ef323deef8d8e32425075e9470c2c17420ac07077e856e0a59afa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.16.0/lea_0.16.0_linux_arm64.tar.gz"
      sha256 "6e56e66cf65edb90986b18809d2d85bf998cd66cc63f69a1c63a2b85af5f7c41"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.16.0/lea_0.16.0_linux_amd64.tar.gz"
      sha256 "4e53748bb9c0c488649d36bc0bfaba2dd1e29c76f689185a2515a91a22b05801"
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
