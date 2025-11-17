#!/bin/bash
# Script to update Homebrew tap with v1.0.1 release
# This script updates the homebrew-yankovinator-swift tap repository

set -e

VERSION="1.0.1"
TAP_REPO="homebrew-yankovinator-swift"
MAIN_REPO="Yankovinator-swift"
GITHUB_USER="shyamalschandra"

echo "🚀 Updating Homebrew tap for v${VERSION}"

# Check if tap repo exists locally
if [ ! -d "../${TAP_REPO}" ]; then
    echo "📦 Cloning tap repository..."
    cd ..
    git clone "https://github.com/${GITHUB_USER}/${TAP_REPO}.git" || {
        echo "❌ Tap repository not found. Please create it first at:"
        echo "   https://github.com/${GITHUB_USER}/${TAP_REPO}"
        exit 1
    }
    cd "${TAP_REPO}"
else
    echo "📦 Using existing tap repository..."
    cd "../${TAP_REPO}"
    git pull origin main
fi

# Wait for release to be available
echo "⏳ Waiting for release v${VERSION} to be available..."
MAX_WAIT=300  # 5 minutes
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if curl -sL "https://github.com/${GITHUB_USER}/${MAIN_REPO}/releases/download/v${VERSION}/yankovinator-universal.tar.gz.sha256" > /dev/null 2>&1; then
        echo "✅ Release is available!"
        break
    fi
    echo "   Waiting... (${WAITED}s/${MAX_WAIT}s)"
    sleep 10
    WAITED=$((WAITED + 10))
done

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "❌ Release not available after waiting. Please check GitHub Actions."
    exit 1
fi

# Download checksum
echo "📥 Downloading SHA256 checksum..."
SHA256=$(curl -sL "https://github.com/${GITHUB_USER}/${MAIN_REPO}/releases/download/v${VERSION}/yankovinator-universal.tar.gz.sha256" | awk '{print $1}')

if [ -z "$SHA256" ]; then
    echo "❌ Failed to get SHA256 checksum"
    exit 1
fi

echo "✅ SHA256: ${SHA256}"

# Update formula
FORMULA_FILE="yankovinator-swift.rb"
if [ ! -f "$FORMULA_FILE" ]; then
    echo "📝 Creating formula file..."
    cp "../${MAIN_REPO}/Formula/yankovinator-swift.rb" "$FORMULA_FILE"
fi

# Update version and SHA256
echo "📝 Updating formula..."
sed -i.bak "s/version \"[^\"]*\"/version \"${VERSION}\"/" "$FORMULA_FILE"
sed -i.bak "s/sha256 \"[^\"]*\"/sha256 \"${SHA256}\"/" "$FORMULA_FILE"
rm -f "${FORMULA_FILE}.bak"

# Verify changes
echo "🔍 Verifying formula..."
if ! grep -q "version \"${VERSION}\"" "$FORMULA_FILE"; then
    echo "❌ Version update failed"
    exit 1
fi

if ! grep -q "sha256 \"${SHA256}\"" "$FORMULA_FILE"; then
    echo "❌ SHA256 update failed"
    exit 1
fi

echo "✅ Formula updated successfully!"

# Commit and push
echo "📤 Committing and pushing changes..."
git add "$FORMULA_FILE"
git commit -m "Update to v${VERSION}

- Updated version to ${VERSION}
- Updated SHA256 checksum
- Release: https://github.com/${GITHUB_USER}/${MAIN_REPO}/releases/tag/v${VERSION}" || {
    echo "⚠️  No changes to commit (formula may already be up to date)"
    exit 0
}

git push origin main

echo ""
echo "✅ Homebrew tap updated successfully!"
echo ""
echo "Users can now install with:"
echo "  brew tap ${GITHUB_USER}/yankovinator-swift"
echo "  brew install yankovinator-swift"
echo ""
