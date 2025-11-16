// Copyright (C) 2025, Shyamal Suhana Chandra
// Command-line interface for generating keywords with definitions using Ollama

import Foundation
import ArgumentParser
import Yankovinator

@main
struct KeywordGeneratorCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "keyword-generator",
        abstract: "Generate keyword:definition pairs from subjects using Ollama LLM",
        discussion: """
        Keyword Generator uses Ollama's LLM (llama3.2:3b by default) to generate
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
    
    @Option(name: [.long, .customShort("u")], help: "Ollama API base URL")
    var ollamaURL: String = "http://localhost:11434"
    
    @Option(name: .shortAndLong, help: "Ollama model name (default: llama3.2:3b)")
    var model: String = "llama3.2:3b"
    
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
        
        // Trim and validate Ollama URL
        ollamaURL = ollamaURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ollamaURL.isEmpty else {
            throw ValidationError("Ollama URL cannot be empty")
        }
        
        // Trim and validate model name
        model = model.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !model.isEmpty else {
            throw ValidationError("Model name cannot be empty")
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
            print("Keyword Generator - Using Ollama LLM")
            print("Copyright (C) 2025, Shyamal Suhana Chandra")
            print("")
            print("Subjects: \(subjects.joined(separator: ", "))")
            print("Count: \(count)")
            print("Model: \(model)")
            print("Ollama URL: \(ollamaURL)")
            print("")
        }
        
        // Create Ollama client
        let client = OllamaClient(baseURL: ollamaURL, model: model)
        
        // Check Ollama connection
        if verbose {
            print("Checking Ollama connection...")
        }
        
        let isAvailable = try await client.checkAvailability()
        
        if !isAvailable {
            do {
                try await client.verifyModel()
            } catch let error as OllamaError {
                throw ValidationError("""
                \(error.description)
                
                To fix this:
                1. Ensure Ollama is running: ollama serve
                2. Install the model: ollama pull \(model)
                3. Verify model exists: ollama list
                """)
            } catch {
                throw ValidationError("""
                Ollama is not available at \(ollamaURL).
                Please ensure Ollama is running and accessible.
                Error: \(error.localizedDescription)
                """)
            }
        }
        
        if verbose {
            print("Ollama connection successful!")
            print("Generating keywords...")
            print("")
        }
        
        // Generate keywords
        let keywords: [String: String]
        do {
            keywords = try await client.generateKeywords(from: subjects, count: count)
        } catch let error as OllamaError {
            var errorMsg = error.description
            
            if case .modelNotFound(let modelName) = error {
                errorMsg += "\n\n"
                errorMsg += "To fix this:\n"
                errorMsg += "1. Check available models: ollama list\n"
                errorMsg += "2. Install the model: ollama pull \(modelName)\n"
                errorMsg += "3. Or use an existing model with --model flag\n"
            } else if case .httpError(let statusCode, let message) = error {
                errorMsg += "\n\n"
                errorMsg += "HTTP Error \(statusCode)\(message)\n"
                errorMsg += "To fix this:\n"
                errorMsg += "1. Ensure Ollama is running: ollama serve\n"
                errorMsg += "2. Verify Ollama is accessible at: \(ollamaURL)\n"
            }
            
            throw ValidationError(errorMsg)
        } catch {
            throw ValidationError("""
            Unexpected error during keyword generation: \(error.localizedDescription)
            
            To fix this:
            1. Ensure Ollama is running: ollama serve
            2. Check Ollama logs for details
            3. Verify the model exists: ollama list
            """)
        }
        
        guard !keywords.isEmpty else {
            throw ValidationError("""
            No keywords were generated. This might indicate:
            1. The LLM response format was unexpected
            2. The model needs better prompting
            3. Try increasing the count or using different subjects
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
