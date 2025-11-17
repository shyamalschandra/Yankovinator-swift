#!/bin/bash
# Benchmark script to compare Foundation Models performance

set -e

echo "=== Yankovinator Benchmark ==="
echo ""

# Check if test data exists
if [ ! -f "data/test_short.txt" ]; then
    echo "Error: Test data not found. Please ensure data/test_short.txt exists."
    exit 1
fi

# Check if keywords file exists, create default if not
if [ ! -f "data/test_keywords.txt" ]; then
    echo "Creating default keywords file..."
    cat > data/test_keywords.txt << EOF
parody: humorous imitation
creative: original and imaginative
song: musical composition
lyrics: words of a song
EOF
fi

echo "Running Foundation Models benchmark..."
echo ""

# Build the project
echo "Building project..."
swift build -c release

# Run benchmark
echo "Running benchmark..."
swift run benchmark --lyrics data/test_short.txt --keywords data/test_keywords.txt

echo ""
echo "Benchmark complete!"
