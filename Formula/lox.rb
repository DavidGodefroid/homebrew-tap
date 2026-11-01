class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.5.0/lox_0.5.0_darwin_arm64.tar.gz"
      sha256 "610684aec074769a234e858fba95a70acc84d9eaa0ff698e366704a3e6330813"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.5.0/lox_0.5.0_darwin_amd64.tar.gz"
      sha256 "2709467c5ca9000a6b080d181bf83befe9064459ea9d7650bc3e068da23b5bcf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.5.0/lox_0.5.0_linux_arm64.tar.gz"
      sha256 "0e94ebcf343caec160dc4205bac30ffd43a3dd1352d47700bd8bb719ecf2e8f7"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.5.0/lox_0.5.0_linux_amd64.tar.gz"
      sha256 "c5366d5a0f0e07e46a380ff91dbff6d2b7c576b853069b16a097d44ef8221cd1"
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
