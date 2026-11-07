class Lox < Formula
  desc "Harness security for AI agents: lockhub's CLI, where approvals live"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.0/lox_0.10.0_darwin_arm64.tar.gz"
      sha256 "addc0892399b71c6373e5089eec959e53167440b325abbdf51114b96980afc98"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.0/lox_0.10.0_darwin_amd64.tar.gz"
      sha256 "629f085dbbbffcfccc47cd812a62bca0b70ac50232adb4cfac32132e116d4148"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.0/lox_0.10.0_linux_arm64.tar.gz"
      sha256 "f454efda5cb6b64600a17952316e777dc971d998a65c4e35fc2a7412c5d16945"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.10.0/lox_0.10.0_linux_amd64.tar.gz"
      sha256 "5f3088b103b6e0950d030227948275b387a77959799f3daabb8ffc6d706e7b08"
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
