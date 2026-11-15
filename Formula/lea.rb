class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.1/lea_0.17.1_darwin_arm64.tar.gz"
      sha256 "273bdd427acac695f15ad302f411856493b2ca012f71664eef9ae880215b2d71"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.1/lea_0.17.1_darwin_amd64.tar.gz"
      sha256 "97588e18860d30fa861569b3f3b6fd5ab4e897fcf17473f88ad034d21769d9d5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.1/lea_0.17.1_linux_arm64.tar.gz"
      sha256 "13e22388ccab9de86ca88737ede8b88c2c19a45d4504c39cccf6bac44c8503be"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.1/lea_0.17.1_linux_amd64.tar.gz"
      sha256 "22112553e7c739d8f73106aa84c9915909e4f52732a453fa19b121b06692755e"
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
