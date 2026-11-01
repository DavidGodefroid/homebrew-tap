class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.4.0/lox_0.4.0_darwin_arm64.tar.gz"
      sha256 "b06c404f17c59721b0f5d309ae1867bd4759df847e1120970c2688ef5e346377"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.4.0/lox_0.4.0_darwin_amd64.tar.gz"
      sha256 "781ba01c08eb6d72460f343942bc03bd223fccfe7949184230fe675ab1d6c1b7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.4.0/lox_0.4.0_linux_arm64.tar.gz"
      sha256 "51a7e8f59166e512081beec8df9b671c33d98e8469c610b27245181d87956675"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.4.0/lox_0.4.0_linux_amd64.tar.gz"
      sha256 "231ca2afbe042aebfcbfbd38180bf0c225d7562798235ecc3c70bb80b4293441"
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
