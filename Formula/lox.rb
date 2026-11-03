class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.6.0/lox_0.6.0_darwin_arm64.tar.gz"
      sha256 "9b4e479167122a50ab9a95de612518ca46f4a9c5ad5fc31ece7c9ffcb97f674b"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.6.0/lox_0.6.0_darwin_amd64.tar.gz"
      sha256 "b6366afaa64e2d6ba3e8b3779a378d2802d5baa886cdeb11ab0bca952c33a437"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.6.0/lox_0.6.0_linux_arm64.tar.gz"
      sha256 "1e5e197b3aaa229b7bd58d60e229b09cf1489b5e08810d9da438546b2b211d67"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.6.0/lox_0.6.0_linux_amd64.tar.gz"
      sha256 "25a0347cd80a28364eaf8922b38a2160a6064ca57d3ab6e188f6dec887c8bdcb"
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
