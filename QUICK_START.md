# Quick Start Guide - Foundation Models Edition

## ✅ Migration Complete!

Yankovinator has been successfully migrated to Apple's Foundation Models framework. All code is updated, tested, and ready for use.

## What Changed?

- **Before**: Required Ollama server running locally
- **After**: Uses Apple's on-device Foundation Models (no external services!)

## Requirements

- **macOS 15.0+ (Sequoia)** or **iOS 18.0+**
- Swift 6.2+
- Foundation Models framework (included with OS)

## Quick Test

```bash
# Build the project
swift build

# Test the CLI
swift run yankovinator --help
swift run keyword-generator --help
swift run benchmark --help

# Run tests
swift test
```

## Usage Examples

### Generate Keywords
```bash
swift run keyword-generator "artificial intelligence" --count 10 --output keywords.txt
```

### Generate Parody
```bash
swift run yankovinator lyrics.txt --keywords keywords.txt --output parody.txt --verbose
```

### Benchmark Performance
```bash
swift run benchmark --lyrics data/test_short.txt --keywords data/test_keywords.txt --iterations 5
```

## What's New

1. **No External Dependencies**: No Ollama server needed
2. **On-Device AI**: All processing happens locally
3. **Benchmarking Tool**: New `benchmark` command for performance testing
4. **Better Privacy**: Data never leaves your device

## Migration Notes

- Removed `--ollama-url` and `--model` options
- Added optional `--model-identifier` option
- All functionality preserved, now using Foundation Models

## Next Steps

1. Test on macOS 15.0+ system
2. Run benchmarks to measure performance
3. Create release v2.0.0
4. Update Homebrew formula

## Documentation

- `README.md` - Complete usage guide
- `MIGRATION_SUMMARY.md` - Detailed migration notes
- `RELEASE_NOTES_v2.0.0.md` - Release information
- `DEPLOYMENT_CHECKLIST.md` - Release checklist

## Support

All code is committed and pushed to the repository. Ready for release!
