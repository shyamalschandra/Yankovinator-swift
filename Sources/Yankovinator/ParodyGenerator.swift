// Copyright (C) 2025, Shyamal Suhana Chandra
// Main parody generation engine

import Foundation
import NaturalLanguage

/// ParodyGenerator orchestrates the conversion of songs into parodies
public class ParodyGenerator {
    private let ollamaClient: OllamaClient
    private let syllableCounter: SyllableCounter.Type
    
    /// Initialize the parody generator
    /// - Parameters:
    ///   - ollamaBaseURL: Base URL for Ollama API
    ///   - ollamaModel: Model name to use (default: llama3.2:3b)
    public init(ollamaBaseURL: String = "http://localhost:11434", ollamaModel: String = "llama3.2:3b") {
        self.ollamaClient = OllamaClient(baseURL: ollamaBaseURL, model: ollamaModel)
        self.syllableCounter = SyllableCounter.self
    }
    
    /// Generate a parody of a song
    /// - Parameters:
    ///   - originalLyrics: Array of original song lines
    ///   - keywords: Dictionary of theme keywords and their definitions
    ///   - progressCallback: Optional callback for progress updates
    /// - Returns: Array of parody lines
    public func generateParody(
        originalLyrics: [String],
        keywords: [String: String],
        progressCallback: ((Int, Int) -> Void)? = nil
    ) async throws -> [String] {
        // Verify model is available before starting
        try await verifyModel()
        
        // Analyze original song structure
        let syllableStructure = syllableCounter.analyzeSongStructure(originalLyrics)
        
        var parodyLines: [String] = []
        let totalLines = originalLyrics.count
        
        // Generate each line
        for (index, originalLine) in originalLyrics.enumerated() {
            let syllableCount = syllableStructure[index]
            
            progressCallback?(index + 1, totalLines)
            
            // Generate parody line matching syllable count
            let parodyLine = try await ollamaClient.generateParodyLine(
                originalLine: originalLine,
                syllableCount: syllableCount,
                keywords: keywords,
                previousLines: Array(parodyLines.suffix(3)) // Last 3 lines for context
            )
            
            parodyLines.append(parodyLine)
        }
        
        return parodyLines
    }
    
    /// Extract keywords and definitions from text using NaturalLanguage
    /// - Parameter text: Text containing keywords and definitions
    /// - Returns: Dictionary of keywords and their definitions
    public func extractKeywords(from text: String) -> [String: String] {
        var keywords: [String: String] = [:]
        
        // Use NaturalLanguage for named entity recognition
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType])
        tagger.string = text
        
        // Simple pattern matching for "keyword: definition" format
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if let colonIndex = trimmed.firstIndex(of: ":") {
                let keyword = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                let definition = String(trimmed[trimmed.index(after: colonIndex)...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !keyword.isEmpty && !definition.isEmpty {
                    keywords[keyword] = definition
                }
            }
        }
        
        return keywords
    }
    
    /// Validate that Ollama is available and model exists
    /// - Returns: True if Ollama is reachable and model is available
    public func validateOllamaConnection() async throws -> Bool {
        return try await ollamaClient.checkAvailability()
    }
    
    /// Verify model is available before generation
    /// - Throws: OllamaError if model is not available
    public func verifyModel() async throws {
        try await ollamaClient.verifyModel()
    }
}

