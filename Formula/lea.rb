class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.1/lea_0.14.1_darwin_arm64.tar.gz"
      sha256 "f44b76e55d81b07128cedb8e5a4ee387eeccac9b1a80ad9a98f68531a0d37143"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.1/lea_0.14.1_darwin_amd64.tar.gz"
      sha256 "c03d6a47b4f369a9e10c731e666ff9099eafae417a898b7b887453e2be033c6f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.1/lea_0.14.1_linux_arm64.tar.gz"
      sha256 "0420630a3da2834b1e9d57ad931d73c03b0d14b42b8e42ac46670a5314d5f49e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.1/lea_0.14.1_linux_amd64.tar.gz"
      sha256 "b32efbff8027ce5deeb12d5295b95df5abf6c619d61bde8a0557eba82e52b14d"
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
