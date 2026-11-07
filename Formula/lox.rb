class Lox < Formula
  desc "Harness security for AI agents: lockhub's CLI, where approvals live"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.1/lox_0.10.1_darwin_arm64.tar.gz"
      sha256 "3860a026f67ceb6ce78aa8b60fa705adf7e279858d139c439845808b2d04e040"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.1/lox_0.10.1_darwin_amd64.tar.gz"
      sha256 "1fe701c8f77fd5da523ab6e0d51237bb4f56a7425159060f782d77e7ef10bb26"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.1/lox_0.10.1_linux_arm64.tar.gz"
      sha256 "56dd1361d36c687ee5810f1020122f3342e67567040eda0741902f52a4b3d0dc"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.1/lox_0.10.1_linux_amd64.tar.gz"
      sha256 "0b85ca3095bea09fb6fe85bd352e3d956b52857ae8bd0f7f321791f54c3a1484"
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
