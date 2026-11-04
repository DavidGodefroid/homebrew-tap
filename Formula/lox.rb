class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.8.0/lox_0.8.0_darwin_arm64.tar.gz"
      sha256 "cde8ef885a603eb288097d83f3a5691743f7ae4296d9970a8c1816a7681e7b9f"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.8.0/lox_0.8.0_darwin_amd64.tar.gz"
      sha256 "16ab32f4356f566de100504c573561914b46512107cb808177a4aeba97f73e6a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.8.0/lox_0.8.0_linux_arm64.tar.gz"
      sha256 "89c5b655326dd42d5856b544a8df32112c4c51147a5563b429a60b3ee8821ca2"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.8.0/lox_0.8.0_linux_amd64.tar.gz"
      sha256 "24a08a3b498eb09587041c88af4fad3341a74e26a0bcba69de164a3e8dd28897"
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
