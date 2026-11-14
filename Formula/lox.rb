class Lox < Formula
  desc "Harness security for AI agents: lockhub's CLI, where approvals live"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.0/lox_0.12.0_darwin_arm64.tar.gz"
      sha256 "7431113228de4bd6b3c6f63d6d793d14dd715195b38839c1bd5dba90927343e7"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.0/lox_0.12.0_darwin_amd64.tar.gz"
      sha256 "2570bbd6001aba90a511793ea75e36664217c982d3edb3ee8187a14834d0cbe5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.0/lox_0.12.0_linux_arm64.tar.gz"
      sha256 "488f4f4183327b74326691b9c5d5c2b1ed19583e1a9954ef744fc80a961c7410"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.0/lox_0.12.0_linux_amd64.tar.gz"
      sha256 "ad9480ee4a9d2f30ffc2ed33192458148a03215ef211625779591c86e0c57bf5"
    end
  end

  def install
    bin.install "lox"
  end

  def caveats
    <<~EOS
      The Lock Family runs in Docker: Docker Engine (Linux) or Docker Desktop
      (macOS) must be installed and running.
      Next step:
        lea
        lox add locksql
      One `lox add` per source: locksql, lockmq, lockfile or lockhttp. A lock
      added while lea runs needs `lea stop`, then `lea`.
      Without lea: `lox init`, then `lox add <lock>`, then `claude` +
      `lox approve`.
    EOS
  end

  test do
    assert_equal "lox #{version}", shell_output("#{bin}/lox version").strip
  end
end
