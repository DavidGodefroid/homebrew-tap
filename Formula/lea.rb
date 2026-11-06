class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.9.0/lea_0.9.0_darwin_arm64.tar.gz"
      sha256 "170d24f20b2af5528c6f79bfcc599f275cd756b9729da67ad2cad1742f86bb91"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.9.0/lea_0.9.0_darwin_amd64.tar.gz"
      sha256 "093811a89d9468b5f992243842147c2c9d3392c37e97e0040a3a5a3eb90e3d77"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.9.0/lea_0.9.0_linux_arm64.tar.gz"
      sha256 "f91f17cc4b7de7a1584384ea0aae4e4dd4fe59a68db2b9e0610e716d9ffa8236"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.9.0/lea_0.9.0_linux_amd64.tar.gz"
      sha256 "cd5863f1e2eb22d449dd16eba351819c2cd2d2cbbc528a1442cb0a6efc6e3eea"
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
