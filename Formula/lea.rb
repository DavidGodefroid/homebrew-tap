class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.0/lea_0.14.0_darwin_arm64.tar.gz"
      sha256 "4dc4bbaf468e78477f406007b14ebc9d5d6e13d7adad966f35629068f0255f3e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.0/lea_0.14.0_darwin_amd64.tar.gz"
      sha256 "d76429df73bc78814edcd40cd0caad650e3bf160bc99964d49bc4eb508a6bb7e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.0/lea_0.14.0_linux_arm64.tar.gz"
      sha256 "4cf02079c5c44f951b375d2548520da96cd3e0088ee06c85d7fa10a0bbb70f74"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.14.0/lea_0.14.0_linux_amd64.tar.gz"
      sha256 "3acf01056cdeb54f0b5c6ec9b1b00b1541c8f645c88f79cf98335458f64b03d0"
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
