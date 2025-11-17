# Homebrew Tap Update Instructions for v1.0.1

## Prerequisites

1. The GitHub release v1.0.1 must be complete (check: https://github.com/shyamalschandra/Yankovinator-swift/releases)
2. Access to the tap repository: https://github.com/shyamalschandra/homebrew-yankovinator-swift

## Quick Update (Automated)

Run the update script:

```bash
cd /Users/shyamalchandra/Yankovinator-swift
./update-homebrew-tap.sh
```

## Manual Update Steps

### 1. Wait for Release to Complete

Check that the release is available:
```bash
curl -sL https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v1.0.1/yankovinator-universal.tar.gz.sha256
```

### 2. Get SHA256 Checksum

```bash
SHA256=$(curl -sL https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v1.0.1/yankovinator-universal.tar.gz.sha256 | awk '{print $1}')
echo "SHA256: $SHA256"
```

### 3. Clone/Update Tap Repository

```bash
# If you don't have it locally:
git clone https://github.com/shyamalschandra/homebrew-yankovinator-swift.git
cd homebrew-yankovinator-swift

# Or if you already have it:
cd homebrew-yankovinator-swift
git pull origin main
```

### 4. Update Formula

Copy the formula from this repo:
```bash
cp ../Yankovinator-swift/Formula/yankovinator-swift.rb yankovinator-swift.rb
```

Or edit `yankovinator-swift.rb` directly:
- Update `version "1.0.1"`
- Update `sha256 "YOUR_SHA256_HERE"` with the checksum from step 2

### 5. Commit and Push

```bash
git add yankovinator-swift.rb
git commit -m "Update to v1.0.1

- Updated version to 1.0.1
- Updated SHA256 checksum
- Release: https://github.com/shyamalschandra/Yankovinator-swift/releases/tag/v1.0.1"
git push origin main
```

### 6. Test Installation

```bash
# Untap and retap to get latest
brew untap shyamalschandra/yankovinator-swift
brew tap shyamalschandra/yankovinator-swift

# Install
brew install yankovinator-swift

# Verify
yankovinator --help
keyword-generator --help
benchmark --help
```

## Current Formula (v1.0.1)

The formula file is located at: `Formula/yankovinator-swift.rb`

Key values:
- Version: `1.0.1`
- SHA256: (will be filled from release)
- URL: `https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v1.0.1/yankovinator-universal.tar.gz`

## Troubleshooting

### Release Not Found
- Wait for GitHub Actions workflow to complete (check: https://github.com/shyamalschandra/Yankovinator-swift/actions)
- Usually takes 5-10 minutes after tag push

### SHA256 Mismatch
- Re-download the checksum file from the release
- Verify the release asset exists

### Tap Repository Not Found
- Create it at: https://github.com/shyamalschandra/homebrew-yankovinator-swift
- Must be named exactly: `homebrew-yankovinator-swift`
- Must contain the formula file: `yankovinator-swift.rb`
