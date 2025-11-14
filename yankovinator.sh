#!/bin/bash
# Copyright (C) 2025, Shyamal Suhana Chandra
# Wrapper script for Yankovinator to handle command-line arguments properly

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build the project if needed
if [ ! -f ".build/debug/yankovinator" ] && [ ! -f ".build/release/yankovinator" ]; then
    echo "Building Yankovinator..."
    swift build > /dev/null 2>&1
fi

# Find the executable
if [ -f ".build/release/yankovinator" ]; then
    EXECUTABLE=".build/release/yankovinator"
elif [ -f ".build/debug/yankovinator" ]; then
    EXECUTABLE=".build/debug/yankovinator"
else
    echo "Error: Yankovinator executable not found. Building..."
    swift build
    if [ -f ".build/debug/yankovinator" ]; then
        EXECUTABLE=".build/debug/yankovinator"
    else
        echo "Error: Failed to build Yankovinator"
        exit 1
    fi
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

