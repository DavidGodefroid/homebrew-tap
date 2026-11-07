class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.11.0/lea_0.11.0_darwin_arm64.tar.gz"
      sha256 "0e407219113ad769a476459c09f4587c68135462c26a88ca6024e5d336ed9da4"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.11.0/lea_0.11.0_darwin_amd64.tar.gz"
      sha256 "35864feab763b74680ca347cab1bea645fc77dc9a81c088e0bb389a69db0a306"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.11.0/lea_0.11.0_linux_arm64.tar.gz"
      sha256 "2af9fd7228d5a48aa821d8342812a96c29037f86e23277baecde51c281533c14"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.11.0/lea_0.11.0_linux_amd64.tar.gz"
      sha256 "b16273bd64de7fd057646e664695c729391ccf75f2e5bc8f6ed5032e153b5b91"
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
