class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.0/lea_0.8.0_darwin_arm64.tar.gz"
      sha256 "722b359794bbe3022ce25d4a61623ce4213a4355a2535c5ba8fc4327168c9827"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.0/lea_0.8.0_darwin_amd64.tar.gz"
      sha256 "99e2b9fbd6ad3b5c535c64fa487a21f3c48248aaf6681b65a678f5791bb98a36"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.0/lea_0.8.0_linux_arm64.tar.gz"
      sha256 "8c44d1f06cd748684cbbb0658b59326ab2120c4b85c50d8f9a5a27589fc4b827"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.8.0/lea_0.8.0_linux_amd64.tar.gz"
      sha256 "0c09109a296a76635cf1c97897e6aa011f9ddea4ecec4e743ec8d3a2c2c72aa4"
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
