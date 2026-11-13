class Lox < Formula
  desc "Harness security for AI agents: lockhub's CLI, where approvals live"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.11.0/lox_0.11.0_darwin_arm64.tar.gz"
      sha256 "0b290d4ef2453bfe69a526533cb9a14fca7440904c6ce358fa22e58fa22ed231"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.11.0/lox_0.11.0_darwin_amd64.tar.gz"
      sha256 "6c0c558a8a0a85d134cf8db8bfac9eba34f8579692b399ef4ec703287f7442aa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.11.0/lox_0.11.0_linux_arm64.tar.gz"
      sha256 "fbd68d5e7ec9f641f0b761f9d67ead0618ec5216327df1af31bf2790a4ff3115"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.11.0/lox_0.11.0_linux_amd64.tar.gz"
      sha256 "eadafed3c2444af0ef6f4ad906f36a4dca15930c712b016f0456f434626ab431"
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
