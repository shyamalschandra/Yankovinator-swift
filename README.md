# Yankovinator

**Copyright (C) 2025, Shyamal Suhana Chandra**

**Invented by Shyamal Chandra**

Contact **ssc56@duck.com** to license code for commercial and non-commercial purposes.

Yankovinator is a Swift-based application that converts songs into parodies using Apple's NaturalLanguage framework and Foundation Models for intelligent text generation. The system maintains the original song's syllable structure while generating new lyrics that follow theme-based keyword constraints.

## Features

- ✅ Syllable-accurate parody generation (word-by-word matching)
- ✅ Automatic rhyme detection and enforcement
- ✅ Semantic coherence across lines (context-aware generation)
- ✅ Theme advancement (not just mention, but actively develop themes)
- ✅ Capitalization and punctuation matching (exact style preservation)
- ✅ Theme-based keyword integration
- ✅ Automatic keyword generation from subjects using Foundation Models
- ✅ NaturalLanguage framework integration (Swift 6.2+)
- ✅ Apple Foundation Models framework support (on-device AI)
- ✅ Command-line interface
- ✅ Comprehensive testing with XCTest
- ✅ Full documentation (LaTeX/Beamer)

## Requirements

- Swift 6.2 or later
- macOS 15.0+ (Sequoia) or iOS 18.0+
- Foundation Models framework (included with macOS 15+/iOS 18+)
- Homebrew (for Homebrew installation method)

**Note**: Foundation Models is Apple's on-device AI framework, so no external services or model downloads are required!

## Installation

### Pre-built Binaries (Recommended)

Download pre-built universal binaries from [GitHub Releases](https://github.com/shyamalschandra/Yankovinator-swift/releases). No Swift toolchain required!

```bash
# Download the universal binary (works on both Intel and Apple Silicon)
curl -L -o yankovinator-universal.tar.gz \
  https://github.com/shyamalschandra/Yankovinator-swift/releases/download/v1.0.0/yankovinator-universal.tar.gz

# Extract
tar -xzf yankovinator-universal.tar.gz

# Install to /usr/local/bin
sudo mv yankovinator keyword-generator /usr/local/bin/

# Verify installation
yankovinator --help
keyword-generator --help
```

See [RELEASES.md](docs/RELEASES.md) for detailed installation instructions and troubleshooting.

### Homebrew

Install via Homebrew using the tap:

```bash
# Add the tap
brew tap shyamalschandra/yankovinator-swift

# Install Yankovinator-swift
brew install yankovinator-swift

# Verify installation
yankovinator --help
keyword-generator --help
```

The Homebrew formula downloads pre-built binaries from GitHub Releases, so no Swift toolchain is required.

### Build from Source

For development or if you prefer building from source:

#### 1. Clone the repository

```bash
git clone https://github.com/shyamalschandra/Yankovinator-swift.git
cd Yankovinator-swift
```

#### 2. Build the project

```bash
swift build
```

#### 3. Verify Foundation Models

Foundation Models is included with macOS 15+ and iOS 18+. No additional setup is required!

## Usage

### Command Line Interface

Yankovinator provides two CLI tools:

1. **yankovinator**: Generates parodies from song lyrics
2. **keyword-generator**: Generates keyword:definition pairs from subjects using Ollama

#### Keyword Generator

Generate keyword:definition pairs for use with Yankovinator:

```bash
swift run keyword-generator <subject1> [subject2] ... [options]
```

**Options:**
- `--count, -c <number>`: Number of keyword pairs to generate (default: 10, max: 100)
- `--model-identifier, -m <id>`: Foundation Models model identifier (uses default if not specified)
- `--output, -o <file>`: Output file path (default: stdout)
- `--verbose, -v`: Verbose output

**Examples:**

```bash
# Generate 10 keywords about AI
swift run keyword-generator "artificial intelligence" --output ai_keywords.txt

# Generate 15 keywords about multiple subjects
swift run keyword-generator "space exploration" "NASA" --count 15 --output space_keywords.txt

# Generate keywords and print to stdout
swift run keyword-generator "machine learning" "deep learning" --verbose
```

#### Parody Generator

You can use Yankovinator in two ways:

#### Option 1: Direct Swift execution (recommended for development)

```bash
swift run yankovinator <lyrics-file> [options]
```

#### Option 2: Using the wrapper script (recommended for production, handles edge cases)

```bash
./yankovinator.sh <lyrics-file> [options]
```

The wrapper script automatically:
- Builds the project if needed
- Filters out empty arguments and whitespace issues
- Handles command-line parsing edge cases

**Options:**
- `--keywords, -k <file>`: Path to keywords file (format: `keyword: definition`)
- `--model-identifier, -m <id>`: Foundation Models model identifier (uses default if not specified)
- `--output, -o <file>`: Output file path (default: stdout)
- `--analyze, -a`: Show syllable analysis
- `--verbose, -v`: Verbose output

**Example (single line):**

```bash
swift run yankovinator lyrics.txt --keywords themes.txt --output parody.txt --analyze --verbose
```

**Example (multi-line with backslashes):**

```bash
swift run yankovinator lyrics.txt \
  --keywords themes.txt \
  --output parody.txt \
  --analyze \
  --verbose
```

**Example (using wrapper script):**

```bash
./yankovinator.sh lyrics.txt --keywords themes.txt --output parody.txt --analyze --verbose
```

**Note:** If you encounter "Unexpected argument ' '" errors, use the wrapper script (`./yankovinator.sh`) which handles these edge cases automatically.

### Programmatic Usage

```swift
import Yankovinator

let lyrics = [
    "Twinkle twinkle little star",
    "How I wonder what you are"
]

let keywords = [
    "space": "the physical universe beyond Earth",
    "stars": "luminous celestial bodies"
]

let parody = try await Yankovinator.generateParody(
    originalLyrics: lyrics,
    keywords: keywords
)

for line in parody {
    print(line)
}
```

## Input Format

### Lyrics File

One line per verse:

```
Twinkle twinkle little star
How I wonder what you are
Up above the world so high
Like a diamond in the sky
```

### Keywords File

Format: `keyword: definition`

```
science: the study of natural phenomena
space: the physical universe beyond Earth
exploration: the action of traveling to discover
```

## Testing

Run the test suite:

```bash
swift test
```

The tests include:
- Unit tests for syllable counting
- Integration tests for parody generation
- Keyword extraction tests

**Note:** Integration tests require Ollama to be running. They will be skipped if Ollama is not available.

## Documentation

### LaTeX Documentation

Generate PDF documentation:

```bash
cd docs
pdflatex yankovinator.tex
```

### Beamer Presentation

Generate presentation slides:

```bash
cd docs
pdflatex presentation.tex
```

### Reference Manual

Generate API reference manual:

```bash
cd docs
pdflatex reference.tex
```

The reference manual provides comprehensive API documentation including:
- Function signatures and parameters
- Return types and error handling
- Usage examples and best practices
- Configuration options
- Complete type definitions

## Architecture

### Core Components

1. **SyllableCounter**: Analyzes syllable structure using NaturalLanguage framework
2. **FoundationModelsClient**: Interfaces with Apple's Foundation Models framework for parody generation
3. **ParodyGenerator**: Orchestrates the parody creation process
4. **Yankovinator**: Main library interface

### Technology Stack

- **Swift 6.2+**: Primary programming language
- **NaturalLanguage**: Apple framework for linguistic analysis
- **Foundation Models**: Apple's on-device AI framework for text generation
- **ArgumentParser**: CLI argument parsing

### Migration from Ollama

Yankovinator has been migrated from Ollama to Apple's Foundation Models framework. This provides:
- **No external dependencies**: No need to run Ollama server
- **On-device processing**: All AI processing happens locally
- **Better integration**: Native Apple framework integration
- **Improved performance**: Optimized for Apple Silicon

## Algorithm

### Syllable Counting

The syllable counting algorithm uses:
1. NaturalLanguage tokenization for word separation
2. Vowel counting heuristics
3. Special case handling for silent 'e' and 'le' endings

### Parody Generation

1. Analyze original song's syllable structure (total and word-by-word)
2. Detect rhyming scheme automatically
3. For each line:
   - Extract syllable count requirement (total and word-by-word)
   - Determine rhyming constraints
   - Build prompt with theme keywords and semantic context
   - Request generation from Ollama with previous lines for coherence
   - Validate and clean response
   - Refine word-by-word syllable matching
   - Refine semantic coherence with previous lines
   - Correct punctuation to match original style
4. Return complete parody

### Semantic Coherence

Yankovinator employs advanced semantic coherence techniques:
- **Context Awareness**: Each line considers up to 8 previous lines for narrative continuity
- **Theme Advancement**: Lines actively advance the chosen theme, not just mention keywords
- **Semantic Refinement**: Dedicated refinement pass ensures lines work together thematically
- **Narrative Flow**: Maintains logical progression and consistent imagery throughout

## Benchmarking

Yankovinator includes a built-in benchmarking tool to measure performance:

```bash
swift run benchmark --lyrics data/test_short.txt --keywords data/test_keywords.txt --iterations 5
```

This will run multiple iterations and provide average performance metrics.

## Troubleshooting

### Foundation Models not available

Foundation Models requires macOS 15.0+ (Sequoia) or iOS 18.0+. Ensure you're running on a supported platform:

```bash
sw_vers  # Check macOS version (should be 15.0 or later)
```

### Model initialization errors

If you encounter model initialization errors, try:
1. Ensure you're running macOS 15.0+ or iOS 18.0+
2. Check that Foundation Models framework is available
3. Try using the default model (omit `--model-identifier`)

### Syllable count mismatch

The algorithm uses heuristics and may not be 100% accurate. This is expected behavior for complex words.

## License

Copyright (C) 2025, Shyamal Suhana Chandra

Invented by Shyamal Chandra

Contact **ssc56@duck.com** to license code for commercial and non-commercial purposes.

## References

- [Apple NaturalLanguage Framework](https://developer.apple.com/documentation/NaturalLanguage)
- [Ollama Documentation](https://ollama.ai/docs)
- [Swift Package Manager](https://swift.org/package-manager/)

