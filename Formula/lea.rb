class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.1/lea_0.6.1_darwin_arm64.tar.gz"
      sha256 "4d78f899c48fddc6e37f066368cb57c6300acaaed54625096a9261e92b0618fe"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.1/lea_0.6.1_darwin_amd64.tar.gz"
      sha256 "45aba33a835a417c762a40075af0d1cd630b2ef03602bffbb214a882fd53b8e8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.1/lea_0.6.1_linux_arm64.tar.gz"
      sha256 "89b334904c61a253bd63e74ac47dbe38098245fbd8a8233c7307889ae27a56ec"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.6.1/lea_0.6.1_linux_amd64.tar.gz"
      sha256 "afa004308991efff1269ed2f1ea5f9e17d205c22caf7dba87899f993ee89040c"
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
