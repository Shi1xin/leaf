# Homebrew formula for the Shi1xin/leaf fork (Grok Unicode Mermaid).
# Install:
#   brew tap Shi1xin/leaf https://github.com/Shi1xin/leaf
#   brew install leaf
#
# After each GitHub Release, refresh sha256 values:
#   ./scripts/update-homebrew-formula.sh 1.26.3

class Leaf < Formula
  desc "Terminal Markdown previewer with Grok Unicode Mermaid"
  homepage "https://github.com/Shi1xin/leaf"
  version "1.26.3"
  license "MIT"

  # homebrew-core already ships unrelated `leaf` (Go reloader) and upstream
  # markdown viewer as `leaf-md`. Fully qualify this formula when installing:
  #   brew install shi1xin/leaf/leaf
  conflicts_with "leaf", because: "both install `leaf` binaries"
  conflicts_with "leaf-md", because: "both install `leaf` binaries"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-macos-arm64"
      sha256 "4f81c1fec7e4d37fab67af1a65cad5cd92690d81d5b0b2efbae81fa0625f57af"
    end
    on_intel do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-macos-x86_64"
      sha256 "99f57416202e87040953daed98a22010693e582bf7540fa84b1c2488ce6c0bd1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-linux-arm64"
      sha256 "ddb5c82540ac72fda044ecaa59acaaf4be5a0ba11b701acec83b1c46370f66ec"
    end
    on_intel do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-linux-x86_64"
      sha256 "e3c96250e86d9cecf986e7935768ee462c46cf3b4331b0f44b988809a6326f08"
    end
  end

  def install
    binary = Dir["leaf-*"].find { |f| !f.end_with?(".txt") }
    odie "leaf binary missing from download" if binary.nil?
    bin.install binary => "leaf"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/leaf --version")
  end
end
