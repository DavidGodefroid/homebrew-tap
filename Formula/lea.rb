class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  version "0.3.5"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v#{version}/lea_#{version}_darwin_arm64.tar.gz"
      sha256 "acb9a236c8cedf79dab5481939419007043e0fe8e0431e43887ed79fb0c5232f"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v#{version}/lea_#{version}_darwin_amd64.tar.gz"
      sha256 "7d032ed89a7642c85d697a3730b08b290b48d0b03218b921f497d9c7a0a9051f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v#{version}/lea_#{version}_linux_arm64.tar.gz"
      sha256 "c9ff97fa3c928114bb6130af7a29d9bf7903107b5dea284c7c72612b078596fa"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v#{version}/lea_#{version}_linux_amd64.tar.gz"
      sha256 "69e812d3510eecd49a5e1b83e10b7b23c93f7746bb0e838fda365110f03b628d"
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
        lox init
      Upgrade lea with `brew upgrade lea`: its background self-update is off
      in this installation.
    EOS
  end

  test do
    assert_equal "v#{version}", shell_output("#{bin}/lea version").strip
  end
end
