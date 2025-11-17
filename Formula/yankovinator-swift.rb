# Homebrew formula for Yankovinator-swift
# This formula downloads pre-built binaries from GitHub Releases
# To use this formula, place it in your Homebrew tap repository:
# https://github.com/shyamalschandra/homebrew-yankovinator-swift

class YankovinatorSwift < Formula
  desc "Convert songs into parodies with theme-based constraints using AI"
  homepage "https://github.com/shyamalschandra/Yankovinator-swift"
  version "1.0.0"  # Update this when creating a new release
  
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
  end
  
  test do
    system "#{bin}/yankovinator", "--help"
    system "#{bin}/keyword-generator", "--help"
  end
end
