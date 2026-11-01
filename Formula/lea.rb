class Lea < Formula
  desc "Run many Claude Code agents in containers, away from your machine"
  homepage "https://github.com/DavidGodefroid/lea"
  license "Apache-2.0"

  # The Linux archives ship their own tmux (build/tmux); the macOS ones do not.
  on_macos do
    depends_on "tmux"

    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.4.0/lea_0.4.0_darwin_arm64.tar.gz"
      sha256 "6f66a7f2cda9e282298b51d3a16e7b7e44783d4a8f113b6b44b58fcc3ec5adb6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.4.0/lea_0.4.0_darwin_amd64.tar.gz"
      sha256 "cbbaa1198f9cdc46675a27088f71a8c4d5eeba36748193d4e6091d3ee5f6e2f2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.4.0/lea_0.4.0_linux_arm64.tar.gz"
      sha256 "fb5b625e3edab2228b9412dfef0f7246e1b14feefdc79b254687309882c21f87"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lea/releases/download/v0.4.0/lea_0.4.0_linux_amd64.tar.gz"
      sha256 "54b66a71b8b5e277b5d5100b50acaa4ef8cd258034704d1e3a37a592302f29f6"
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
