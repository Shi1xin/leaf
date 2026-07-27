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

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-macos-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-macos-x86_64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-linux-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/Shi1xin/leaf/releases/download/1.26.3/leaf-linux-x86_64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
