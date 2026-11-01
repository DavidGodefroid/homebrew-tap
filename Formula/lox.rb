class Lox < Formula
  desc "Host CLI of lockhub, the approval hub of the Lock Family"
  homepage "https://github.com/DavidGodefroid/lockhub"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.3.0/lox_0.3.0_darwin_arm64.tar.gz"
      sha256 "99ccbd0351613cff9ebbfa220c2b8f06cdf3f4c9d452542ba82771ec65d3d11f"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.3.0/lox_0.3.0_darwin_amd64.tar.gz"
      sha256 "4d25f671d341bb8d99bf90574a3a2cf106a2f1955b9b685c4ad3ccb065794ce7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.3.0/lox_0.3.0_linux_arm64.tar.gz"
      sha256 "c35e07e6e771105de9219cb93d545be715141d78bdb359f6cbab50e3c7ca91fb"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/lockhub/releases/download/v0.3.0/lox_0.3.0_linux_amd64.tar.gz"
      sha256 "113311612fe4b455b1c495fbaa3d751a4886a6f5cceb17452fe1b7d734832855"
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
        lox init
    EOS
  end

  test do
    assert_equal "lox #{version}", shell_output("#{bin}/lox version").strip
  end
end
