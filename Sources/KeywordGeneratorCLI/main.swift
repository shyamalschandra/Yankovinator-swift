// Copyright (C) 2025, Shyamal Suhana Chandra
// Command-line interface for generating keywords with definitions using Foundation Models

import Foundation
import ArgumentParser
import Yankovinator

@main
struct KeywordGeneratorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "keyword-generator",
        abstract: "Generate keyword:definition pairs from subjects using Foundation Models",
        discussion: """
        Keyword Generator uses Apple's Foundation Models to generate
        keyword:definition pairs based on one or more subjects you provide.
        
        The output is formatted as keyword: definition (one per line), suitable for
        use with the Yankovinator parody generator.
        
        Example usage:
          swift run keyword-generator "artificial intelligence" "machine learning" --output keywords.txt
          swift run keyword-generator "space exploration" --count 15 --output space_keywords.txt
        """
    )
    
    @Argument(help: "Subject(s) to generate keywords for (can specify multiple)")
    var subjects: [String]
    
    @Option(name: .shortAndLong, help: "Number of keyword pairs to generate (default: 10)")
    var count: Int = 10
    
    @Option(name: .shortAndLong, help: "Foundation Models model identifier (uses default if not specified)")
    var modelIdentifier: String?
    
    @Option(name: .shortAndLong, help: "Output file path (default: stdout)")
    var output: String?
    
    @Flag(name: .shortAndLong, help: "Verbose output")
    var verbose: Bool = false
    
    // Validate options after parsing
    mutating func validate() throws {
        // Trim and validate subjects
        subjects = subjects.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !subjects.isEmpty else {
            throw ValidationError("""
            At least one subject must be provided.
            
            Usage: keyword-generator <subject1> [subject2] [subject3] ... [options]
            
            Example:
              swift run keyword-generator "artificial intelligence" --count 10
              swift run keyword-generator "space" "exploration" "NASA" --output keywords.txt
            """)
        }
        
        // Validate count
        guard count > 0 else {
            throw ValidationError("Count must be greater than 0")
        }
        
        guard count <= 100 else {
            throw ValidationError("Count cannot exceed 100 (to avoid excessive generation)")
        }
        
        // Trim and validate model identifier if provided
        if let identifier = modelIdentifier {
            modelIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            if modelIdentifier?.isEmpty == true {
                modelIdentifier = nil
            }
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
    
    func run() async throws {
        if verbose {
            print("Keyword Generator - Using Foundation Models")
            print("Copyright (C) 2025, Shyamal Suhana Chandra")
            print("")
            print("Subjects: \(subjects.joined(separator: ", "))")
            print("Count: \(count)")
            if let identifier = modelIdentifier {
                print("Model: \(identifier)")
            } else {
                print("Model: default")
            }
            print("")
        }
        
        // Create Foundation Models client
        let client: FoundationModelsClient
        do {
            client = try FoundationModelsClient(modelIdentifier: modelIdentifier)
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
        
        // Check Foundation Models availability
        if verbose {
            print("Checking Foundation Models availability...")
        }
        
        let isAvailable = try await client.checkAvailability()
        
        if !isAvailable {
            do {
                try await client.verifyModel()
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
            print("Generating keywords...")
            print("")
        }
        
        // Generate keywords
        let keywords: [String: String]
        do {
            keywords = try await client.generateKeywords(from: subjects, count: count)
        } catch let error as FoundationModelsError {
            var errorMsg = error.description
            
            if case .modelUnavailable = error {
                errorMsg += "\n\n"
                errorMsg += "Foundation Models requires macOS 15+ or iOS 18+.\n"
                errorMsg += "Please ensure you're running on a supported platform.\n"
            } else if case .generationError(let underlyingError) = error {
                errorMsg += "\n\n"
                errorMsg += "Generation error: \(underlyingError.localizedDescription)\n"
            }
            
            throw ValidationError(errorMsg)
        } catch {
            throw ValidationError("""
            Unexpected error during keyword generation: \(error.localizedDescription)
            
            Please ensure Foundation Models is available on your system (macOS 15+ or iOS 18+).
            """)
        }
        
        guard !keywords.isEmpty else {
            throw ValidationError("""
            No keywords were generated. This might indicate:
            1. The Foundation Models response format was unexpected
            2. Try increasing the count or using different subjects
            3. Check that Foundation Models is working correctly
            """)
        }
        
        if verbose {
            print("Generated \(keywords.count) keyword:definition pairs")
            print("")
        }
        
        // Format output as keyword: definition (one per line)
        let outputLines = keywords.map { "\($0.key): \($0.value)" }
            .sorted() // Sort alphabetically for consistency
        let outputText = outputLines.joined(separator: "\n")
        
        // Output results
        if let outputPath = output {
            try outputText.write(toFile: outputPath, atomically: true, encoding: .utf8)
            if verbose {
                print("Keywords saved to: \(outputPath)")
            } else {
                print("Generated \(keywords.count) keywords and saved to: \(outputPath)")
            }
        } else {
            if verbose {
                print("Generated Keywords:")
                print("=" * 50)
            }
            print(outputText)
            if verbose {
                print("=" * 50)
            }
        }
    }
}

// Helper extension for string repetition
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
