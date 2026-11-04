class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.7.0/lox_0.7.0_darwin_arm64.tar.gz"
      sha256 "b99c04f923a5072ae86070a895ef62d3dfdf78f751047292a7805fab398cc02d"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.7.0/lox_0.7.0_darwin_amd64.tar.gz"
      sha256 "a2ef799aaadf3bad048e88a9435573ae39d767f653eb85e54605e3af80599670"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.7.0/lox_0.7.0_linux_arm64.tar.gz"
      sha256 "e533807ab5924225e9f61331c6bbdc2ed37c075c3e2595aaef3ad75b6e84ef84"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.7.0/lox_0.7.0_linux_amd64.tar.gz"
      sha256 "c3ed3a541305a16025673778302fc6f5b28306dc06f984d1c83d53da3221131a"
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
