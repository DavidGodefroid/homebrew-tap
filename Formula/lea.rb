class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.13.0/lea_0.13.0_darwin_arm64.tar.gz"
      sha256 "05db838c2fc2214a53242fd4669705449288dcb30f21337711ee9e7ce182946b"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.13.0/lea_0.13.0_darwin_amd64.tar.gz"
      sha256 "f286805afe2f08f2a57ece07402a33bd9f92ea33cd7ba2b7899e2b6dd4c59ceb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.13.0/lea_0.13.0_linux_arm64.tar.gz"
      sha256 "5eb6d4bb3a6854538b4d992a863bcf9f7a9c9ee16f7c2056d20bbc75410b712a"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.13.0/lea_0.13.0_linux_amd64.tar.gz"
      sha256 "2627781ea925a006cbdfc7711d5197c15438ec866f7e237251d33587e60dde96"
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
