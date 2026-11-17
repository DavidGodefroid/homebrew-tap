class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.4/lea_0.17.4_darwin_arm64.tar.gz"
      sha256 "990d5aae077a4c3a554368d94197083bbc6178fb9b1f18074db45ca9e7ee60c6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.4/lea_0.17.4_darwin_amd64.tar.gz"
      sha256 "ad66b2a86c7cc7868b9c2fa9373ad33ae325f3bd9960c751999b8d7deedac821"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.4/lea_0.17.4_linux_arm64.tar.gz"
      sha256 "fe56b831b914dd9d2d577172b2f61987c85425541ef2f90781e58ae1ec74b6ce"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.4/lea_0.17.4_linux_amd64.tar.gz"
      sha256 "77c817568f951524e601ba1493a5b9843b4ec8caed38b814348ae90f6ea7c3f4"
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
