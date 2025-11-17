// Copyright (C) 2025, Shyamal Suhana Chandra
// Command-line interface for Yankovinator

import Foundation
import ArgumentParser
import Yankovinator

@main
struct YankovinatorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "yankovinator",
        abstract: "Convert songs into parodies with theme-based constraints",
        discussion: """
        Yankovinator uses Apple's NaturalLanguage framework and Foundation Models to generate
        parodies that match the syllable structure of the original song while
        following theme keywords and their definitions.
        
        Example usage:
          swift run yankovinator lyrics.txt --keywords themes.txt --output parody.txt
        
        Note: If using line breaks, use backslashes:
          swift run yankovinator lyrics.txt \\
            --keywords themes.txt \\
            --output parody.txt
        """
    )
    
    @Argument(help: "Path to file containing original song lyrics (one line per verse)")
    var lyricsFile: String
    
    @Option(name: .shortAndLong, help: "Path to file containing keywords and definitions (format: keyword: definition)")
    var keywords: String?
    
    @Option(name: .shortAndLong, help: "Foundation Models model identifier (uses default if not specified)")
    var modelIdentifier: String?
    
    @Option(name: .shortAndLong, help: "Output file path (default: stdout)")
    var output: String?
    
    // Validate options after parsing
    mutating func validate() throws {
        // Trim and validate lyrics file
        let originalLyricsFile = lyricsFile
        lyricsFile = lyricsFile.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for common issues
        if originalLyricsFile != lyricsFile && originalLyricsFile.contains(where: { $0.isWhitespace && !$0.isNewline }) {
            throw ValidationError("""
            Lyrics file path contains unexpected whitespace: "\(originalLyricsFile)"
            
            This often happens when:
            1. The command is split across lines without backslashes
            2. There are trailing spaces in the command
            3. The command was copied with extra whitespace
            
            Please ensure the command is on a single line, or use backslashes for line continuation.
            """)
        }
        
        guard !lyricsFile.isEmpty else {
            throw ValidationError("""
            Lyrics file path cannot be empty.
            
            Usage: yankovinator <lyrics-file> [options]
            
            Example:
              swift run yankovinator data/example_lyrics.txt --keywords data/example_keywords.txt
            """)
        }
        
        // Trim and validate model identifier if provided
        if let identifier = modelIdentifier {
            modelIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            if modelIdentifier?.isEmpty == true {
                modelIdentifier = nil
            }
        }
        
        // Trim and validate keywords file if provided
        if let keywordsFile = keywords {
            let trimmed = keywordsFile.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                throw ValidationError("Keywords file path cannot be empty. Omit --keywords if not needed.")
            }
            keywords = trimmed
        }
        
        // Trim and validate output file if provided
        if let outputPath = output {
            let trimmed = outputPath.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                throw ValidationError("Output file path cannot be empty. Omit --output to print to stdout.")
            }
            output = trimmed
        }
    }
    
    @Flag(name: .shortAndLong, help: "Show syllable analysis")
    var analyze: Bool = false
    
    @Flag(name: .shortAndLong, help: "Verbose output")
    var verbose: Bool = false
    
    func run() async throws {
        if verbose {
            print("Yankovinator - Parody Generator")
            print("Copyright (C) 2025, Shyamal Suhana Chandra")
            print("")
        }
        
        // Read lyrics (already validated and trimmed in validate())
        guard let lyricsContent = try? String(contentsOfFile: lyricsFile, encoding: .utf8) else {
            throw ValidationError("Could not read lyrics file: \(lyricsFile)")
        }
        
        // Preserve empty lines to maintain song structure
        let originalLyrics = lyricsContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Check if there are any non-empty lines
        let nonEmptyLines = originalLyrics.filter { !$0.isEmpty }
        guard !nonEmptyLines.isEmpty else {
            throw ValidationError("No lyrics found in file")
        }
        
        if verbose {
            print("Loaded \(originalLyrics.count) lines from \(lyricsFile)")
        }
        
        // Analyze structure if requested
        if analyze {
            // Only analyze non-empty lines
            let nonEmptyLyrics = originalLyrics.filter { !$0.isEmpty }
            let structure = Yankovinator.analyzeStructure(nonEmptyLyrics)
            print("\nSyllable Analysis:")
            print("=" * 50)
            var structureIndex = 0
            for (index, line) in originalLyrics.enumerated() {
                if line.isEmpty {
                    print("Line \(index + 1): (empty line)")
                    print("  ")
                } else {
                    let count = structure[structureIndex]
                    print("Line \(index + 1): \(count) syllables")
                    print("  \(line)")
                    structureIndex += 1
                }
            }
            print("=" * 50)
            print("")
        }
        
        // Read keywords
        var keywordsDict: [String: String] = [:]
        
        if let keywordsFile = keywords {
            // Already validated and trimmed in validate()
            guard let keywordsContent = try? String(contentsOfFile: keywordsFile, encoding: .utf8) else {
                throw ValidationError("Could not read keywords file: \(keywordsFile)")
            }
            
            let generator = try ParodyGenerator(modelIdentifier: modelIdentifier)
            keywordsDict = generator.extractKeywords(from: keywordsContent)
            
            if verbose {
                print("Loaded \(keywordsDict.count) keywords:")
                for (key, value) in keywordsDict {
                    print("  \(key): \(value)")
                }
                print("")
            }
        } else {
            if verbose {
                print("No keywords file provided. Using default theme.")
            }
            keywordsDict = ["parody": "humorous imitation", "creative": "original and imaginative"]
        }
        
        // Check Foundation Models availability
        if verbose {
            print("Checking Foundation Models availability...")
        }
        
        let generator: ParodyGenerator
        do {
            generator = try ParodyGenerator(modelIdentifier: modelIdentifier)
        } catch let error as FoundationModelsError {
            throw ValidationError("""
            \(error.description)
            
            Foundation Models requires macOS 15+ or iOS 18+.
            Please ensure you're running on a supported platform.
            """)
        } catch {
            throw ValidationError("""
            Failed to initialize Foundation Models: \(error.localizedDescription)
            """)
        }
        
        let isAvailable = try await generator.validateFoundationModelsConnection()
        
        if !isAvailable {
            // Try to get more specific error
            do {
                try await generator.verifyModel()
            } catch let error as FoundationModelsError {
                throw ValidationError("""
                \(error.description)
                
                Foundation Models requires macOS 15+ or iOS 18+.
                Please ensure you're running on a supported platform.
                """)
            } catch {
                throw ValidationError("""
                Foundation Models is not available.
                Error: \(error.localizedDescription)
                """)
            }
        }
        
        if verbose {
            print("Foundation Models available!")
            print("Generating parody...")
            print("")
        }
        
        // Generate parody
        let parodyLines: [String]
        do {
            parodyLines = try await generator.generateParody(
                originalLyrics: originalLyrics,
                keywords: keywordsDict,
                progressCallback: { line, total in
                    if verbose {
                        print("Progress: \(line)/\(total)", terminator: "\r")
                        fflush(stdout)
                    }
                },
                refinementPasses: 2,
                verbose: verbose
            )
            
            if verbose {
                print("\n")
            }
        } catch let error as FoundationModelsError {
            var errorMsg = error.description
            
            // Provide helpful suggestions based on error type
            if case .modelUnavailable = error {
                errorMsg += "\n\n"
                errorMsg += "Foundation Models requires macOS 15+ or iOS 18+.\n"
                errorMsg += "Please ensure you're running on a supported platform.\n"
            } else if case .generationError(let underlyingError) = error {
                errorMsg += "\n\n"
                errorMsg += "Generation error: \(underlyingError.localizedDescription)\n"
                errorMsg += "This may indicate an issue with the Foundation Models framework.\n"
            } else {
                errorMsg += "\n\n"
                errorMsg += "Please check that Foundation Models is properly installed and available.\n"
            }
            
            throw ValidationError(errorMsg)
        } catch {
            // Catch any other errors
            throw ValidationError("""
            Unexpected error during parody generation: \(error.localizedDescription)
            
            Please ensure Foundation Models is available on your system (macOS 15+ or iOS 18+).
            """)
        }
        
        // Output results
        let outputText = parodyLines.joined(separator: "\n")
        
        if let outputPath = output {
            try outputText.write(toFile: outputPath, atomically: true, encoding: .utf8)
            if verbose {
                print("Parody saved to: \(outputPath)")
            }
        } else {
            print("\nGenerated Parody:")
            print("=" * 50)
            print(outputText)
            print("=" * 50)
        }
    }
}

// Helper extension for string repetition
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

