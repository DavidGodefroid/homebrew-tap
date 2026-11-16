class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.3/lea_0.17.3_darwin_arm64.tar.gz"
      sha256 "e8a40e733b1bd258e644cbd52cac12e50082687a59d80704e07e9250dafa17b0"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.3/lea_0.17.3_darwin_amd64.tar.gz"
      sha256 "0ee0dd97ce369c5e171503925722fe1012a1470f866e3f0c0b5a9264751cfdd2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.3/lea_0.17.3_linux_arm64.tar.gz"
      sha256 "e0f4a779b99b35d002c4f9786d6433730502715a2962c305dfa95162df5114f0"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.17.3/lea_0.17.3_linux_amd64.tar.gz"
      sha256 "22dcf533f98788ff3706f0e5fdfa330df181b51ab49eebacc22688a963ac4f52"
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
