class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.1/locklog_0.4.1_darwin_arm64.tar.gz"
      sha256 "024ad698872416b8369189c936c934be5d7a629dfa527340281b290aae4ddf64"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.1/locklog_0.4.1_darwin_amd64.tar.gz"
      sha256 "a5045365618aae0b80c9ffcde9d83eae799588a087826ea7b06293fff385d89e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.1/locklog_0.4.1_linux_arm64.tar.gz"
      sha256 "a7c396187cf6f832df6525107f1286169dba15ffecae343508b80da8edb1713e"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.1/locklog_0.4.1_linux_amd64.tar.gz"
      sha256 "d49a45952e0d48ca29683d15a61590c7b22ebf753e87db49c81e8aa37e9e1b77"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:01a7b7aa0e58bc6da31e8e05b46581679a96c04566584f689e0753fe7291fa58"
    vault_image_digest = "sha256:051203095b98351b3fdffd8bae296cc56ebbb3401afa05f644bffbfbef0af4fc"
    inreplace "scripts/locklog" do |s|
      s.gsub!(/^launcher_version=dev$/, "launcher_version=#{version}")
      s.gsub!(/^image_digest=$/, "image_digest=#{image_digest}")
      s.gsub!(/^vault_image_digest=$/, "vault_image_digest=#{vault_image_digest}")
    end
    bin.install "scripts/locklog"
  end

  def caveats
    <<~EOS
      locklog runs on a Linux host with the logs, in Docker 19.03 or later:
      Docker Engine must be installed and running.
      `lox add` and `lox run` need lox and cosign 2.5 or later:
        brew install davidgodefroid/tap/lox cosign
      Next step:
        lox add locklog
      (with lea: run lea first; it starts the hub)
      Upgrade with `brew upgrade locklog`, not `locklog update`.
    EOS
  end

  test do
    # Prints the launcher's version, then asks Docker for the image's. Docker
    # points nowhere here, so that part fails (exit 1) and pulls nothing.
    ENV["DOCKER_HOST"] = "unix://#{testpath}/no-docker.sock"
    assert_match "locklog launcher #{version} (image ghcr.io/davidgodefroid/locklog@sha256:",
                 shell_output("#{bin}/locklog version 2>&1", 1)
  end
end
