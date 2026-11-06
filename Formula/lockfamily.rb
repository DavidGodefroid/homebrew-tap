class Lockfamily < Formula
  desc "Harness security for AI agents: the whole Lock Family toolset"
  homepage "https://github.com/DavidGodefroid/lockfamily"
  # Nothing to build: the formula only pulls in its dependencies. The archive
  # is a fixed commit of the lockfamily repository, which has no release.
  url "https://github.com/DavidGodefroid/lockfamily/archive/b8e0a73c86da82fc4527a4bd05c90f2b4e35193e.tar.gz"
  version "0.1.0"
  sha256 "a2d3717a06e00276ad26aefb902783a72aaac827929f4353311f54e8105c6f87"
  license "Apache-2.0"

  depends_on "cosign"
  depends_on "davidgodefroid/tap/lea"
  depends_on "davidgodefroid/tap/lockhttp"
  depends_on "davidgodefroid/tap/lockmq"
  depends_on "davidgodefroid/tap/locksql"
  depends_on "davidgodefroid/tap/lox"
  # locklog: no published release yet; added here with its first release.

  on_linux do
    depends_on "davidgodefroid/tap/lockfile"
  end

  def install
    components = %w[lox lea locksql lockmq lockhttp cosign]
    components << "lockfile" if OS.linux?
    (pkgshare/"components").write "#{components.join("\n")}\n"
  end

  def caveats
    <<~EOS
      The Lock Family runs in Docker: Docker Engine (Linux) or Docker Desktop
      (macOS) must be installed and running.
      Next step:
        lea
        lox add locksql
      Then one `lox add` per source: locksql, lockmq, lockfile or lockhttp. A
      lock added while lea runs needs `lea stop`, then `lea`.
      Without lea: `lox init`, then `lox add <lock>`, then `claude` +
      `lox approve`.
    EOS
  end

  test do
    lox = Formula["davidgodefroid/tap/lox"]
    assert_equal "lox #{lox.version}", shell_output("#{lox.opt_bin}/lox version").strip
    lea = Formula["davidgodefroid/tap/lea"]
    assert_equal "v#{lea.version}", shell_output("#{lea.opt_bin}/lea version").strip
    assert_path_exists formula_opt_bin("cosign")/"cosign"
    assert_match "lox", (pkgshare/"components").read
  end
end
