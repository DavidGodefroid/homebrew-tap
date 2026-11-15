class Locklog < Formula
  desc "Harness security for AI agents on log sources, with masked log reads"
  homepage "https://github.com/DavidGodefroid/locklog"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.0/locklog_0.4.0_darwin_arm64.tar.gz"
      sha256 "5bded13ba1b2fc0c8b1349fc08e5300b7482da9a0555571d3c3ab86920b88130"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.0/locklog_0.4.0_darwin_amd64.tar.gz"
      sha256 "b02fc325039018bc32ac86fde8eb2b870f9a5b09751d476e9fcd75113e33e9d2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.0/locklog_0.4.0_linux_arm64.tar.gz"
      sha256 "0d66b3f0e7c90c85b91fb44495ab59fed665a71f78e5d06792bf0d517fd5d0cf"
    end
    on_intel do
      url "https://github.com/DavidGodefroid/locklog/releases/download/v0.4.0/locklog_0.4.0_linux_amd64.tar.gz"
      sha256 "32534a436c2c8eb2dceea7844ff9f9a47b9f139b4ee633a1b2ae3d1ee2b3ac07"
    end
  end

  def install
    # locklog runs in Docker: the host command is the launcher, as
    # scripts/install.sh installs it. It runs the release images by the
    # digests below, verified with cosign when the formula was bumped
    # (scripts/bump). The binary of the archive is the one of the image.
    image_digest = "sha256:1ab96d06ade5e2ba953855b827ab63dd13f46e67dad0e7eb17cf041716f66094"
    vault_image_digest = "sha256:685f831cd5ec266b0a000914bd641cebe901f7b97c04e22ef1aa32de46ed351c"
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
