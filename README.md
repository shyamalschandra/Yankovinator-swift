# Yankovinator

**Copyright (C) 2025, Shyamal Suhana Chandra**

**Invented by Shyamal Chandra**

Contact **ssc56@duck.com** to license code for commercial and non-commercial purposes.

Yankovinator is a Swift-based application that converts songs into parodies using Apple's NaturalLanguage framework and Ollama for intelligent text generation. The system maintains the original song's syllable structure while generating new lyrics that follow theme-based keyword constraints.

## Features

- ✅ Syllable-accurate parody generation
- ✅ Theme-based keyword integration
- ✅ Automatic keyword generation from subjects using Ollama
- ✅ NaturalLanguage framework integration (Swift 6.3+)
- ✅ Ollama LLM support
- ✅ Command-line interface
- ✅ Comprehensive testing with XCTest
- ✅ Full documentation (LaTeX/Beamer)

## Requirements

- Swift 6.2 or later
- macOS 13+ or iOS 16+
- Ollama installed and running
- Model: llama3.2 (or compatible)

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd Yankovinator-swift
```

### 2. Build the project

```bash
swift build
```

### 3. Set up Ollama

```bash
# Start Ollama (if not already running)
ollama serve

# Pull the required model
ollama pull llama3.2
```

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
- `--ollama-url, -u <url>`: Ollama API base URL (default: http://localhost:11434)
- `--model, -m <name>`: Ollama model name (default: llama3.2:3b)
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
- `--ollama-url, -u <url>`: Ollama API base URL (default: http://localhost:11434)
- `--model, -m <name>`: Ollama model name (default: llama3.2)
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

## Architecture

### Core Components

1. **SyllableCounter**: Analyzes syllable structure using NaturalLanguage framework
2. **OllamaClient**: Interfaces with Ollama API for parody generation
3. **ParodyGenerator**: Orchestrates the parody creation process
4. **Yankovinator**: Main library interface

### Technology Stack

- **Swift 6.2+**: Primary programming language
- **NaturalLanguage**: Apple framework for linguistic analysis
- **Ollama**: Local LLM for text generation
- **AsyncHTTPClient**: Asynchronous HTTP client for API communication
- **ArgumentParser**: CLI argument parsing

## Algorithm

### Syllable Counting

The syllable counting algorithm uses:
1. NaturalLanguage tokenization for word separation
2. Vowel counting heuristics
3. Special case handling for silent 'e' and 'le' endings

### Parody Generation

1. Analyze original song's syllable structure
2. For each line:
   - Extract syllable count requirement
   - Build prompt with theme keywords
   - Request generation from Ollama
   - Validate and clean response
3. Return complete parody

## Troubleshooting

### Ollama not found

Ensure Ollama is running at the specified URL:

```bash
ollama serve
```

### Model not available

Pull the required model:

```bash
ollama pull llama3.2
```

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

