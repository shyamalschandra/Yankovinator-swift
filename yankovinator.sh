#!/bin/bash
# Copyright (C) 2025, Shyamal Suhana Chandra
# Wrapper script for Yankovinator to handle command-line arguments properly

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Always build to ensure we have the latest code
echo "Building Yankovinator..."
swift build > /dev/null 2>&1 || {
    echo "Build failed!"
    swift build
    exit 1
}

# Find the executable using swift's bin path
BIN_PATH=$(swift build --show-bin-path)
EXECUTABLE="$BIN_PATH/yankovinator"

if [ ! -f "$EXECUTABLE" ]; then
    echo "Error: Yankovinator executable not found at $EXECUTABLE"
    exit 1
fi

# Filter out any empty arguments or spaces
ARGS=()
for arg in "$@"; do
    # Trim whitespace
    trimmed=$(echo "$arg" | xargs)
    # Only add non-empty arguments
    if [ -n "$trimmed" ]; then
        ARGS+=("$trimmed")
    fi
done

# Execute with cleaned arguments
exec "$EXECUTABLE" "${ARGS[@]}"

