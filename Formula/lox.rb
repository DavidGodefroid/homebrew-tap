class Lox < Formula
  desc "Harness security for AI agents: lockhub's CLI, where approvals live"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.1/lox_0.12.1_darwin_arm64.tar.gz"
      sha256 "1a14d7b5e5e45a32564ef92a3efac50a4f5537e03fcc665d5978ee52b03f7c60"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.1/lox_0.12.1_darwin_amd64.tar.gz"
      sha256 "831700c007dee7e8ac96818e984c04e93919e199e8a2024e2a64a406640cadc6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.1/lox_0.12.1_linux_arm64.tar.gz"
      sha256 "5577ba2c55a2eeb264bc9a3faa00b5efc5a83234dc2ce8f8b9bb84ebbd208fe6"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.12.1/lox_0.12.1_linux_amd64.tar.gz"
      sha256 "3f4bbb11fc99743a80a6b541e7684b1e5ee9b475a60a8b8880a4bb68534175a0"
    end
  end

  def install
    bin.install "lox"
  end

  def caveats
    <<~EOS
      The Lock Family runs in Docker: Docker Engine (Linux) or Docker Desktop
      (macOS) must be installed and running. `lox add` and `lox run` need
      cosign 2.5 or later:
        brew install cosign
      Next step:
        lea
        lox add locksql
      One `lox add` per source: locksql, lockmq, lockfile, lockhttp, locklog
      or lockssh. A lock added while lea runs needs `lea stop`, then `lea`.
      Without lea: `lox init`, then `lox add <lock>`, then `claude` +
      `lox approve`.
    EOS
  end

  test do
    assert_equal "lox #{version}", shell_output("#{bin}/lox version").strip
  end
end
