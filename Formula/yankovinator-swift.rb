# Homebrew formula for Yankovinator-swift
# This formula downloads pre-built binaries from GitHub Releases
# To use this formula, place it in your Homebrew tap repository:
# https://github.com/shyamalschandra/homebrew-yankovinator-swift

class YankovinatorSwift < Formula
  desc "Convert songs into parodies with theme-based constraints using Ollama"
  homepage "https://github.com/shyamalschandra/Yankovinator-swift"
  version "1.0.1"
  # Requires macOS 13.0+ for Ollama support
  depends_on :macos => :ventura
  
  # Determine architecture
  if Hardware::CPU.arm?
    arch = "arm64"
  else
    arch = "x86_64"
  end
  
  # Use universal binary if available, otherwise fall back to architecture-specific
  # Update these URLs after creating a GitHub release
  url "https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v#{version}/yankovinator-universal.tar.gz"
  # Alternative: use architecture-specific binary
  # url "https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v#{version}/yankovinator-#{arch}.tar.gz"
  
  # Calculate SHA256 after creating the release
  # Run: shasum -a 256 yankovinator-universal.tar.gz
  sha256 ""  # Update this with the actual checksum from the release
  
  def install
    # Extract and install binaries
    bin.install "yankovinator"
    bin.install "keyword-generator"
    bin.install "benchmark" if File.exist?("benchmark")
  end
  
  test do
    system "#{bin}/yankovinator", "--help"
    system "#{bin}/keyword-generator", "--help"
    system "#{bin}/benchmark", "--help" if File.exist?("#{bin}/benchmark")
  end
end
