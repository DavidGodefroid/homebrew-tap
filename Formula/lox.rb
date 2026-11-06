class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.9.0/lox_0.9.0_darwin_arm64.tar.gz"
      sha256 "763639cf9a6e366542c73f6afca0816fe1bf8be74ad146da6efd9203ae19936f"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.9.0/lox_0.9.0_darwin_amd64.tar.gz"
      sha256 "c2b717806611bdc5370f7d435a28e36c7bce61e6476c40f4a1d0ebd93d038ef0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.9.0/lox_0.9.0_linux_arm64.tar.gz"
      sha256 "bb35e44f02a83bbffe8928d7126eef43261088ba5c560cf130f16d1390a774a5"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.9.0/lox_0.9.0_linux_amd64.tar.gz"
      sha256 "288525275965f90561f6c4a53332a41763083f1e0b83237b992d68abdf6dac7f"
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
