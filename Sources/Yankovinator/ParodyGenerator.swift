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
    ///   - originalLyrics: Array of original song lines (preserves empty lines)
    ///   - keywords: Dictionary of theme keywords and their definitions
    ///   - progressCallback: Optional callback for progress updates
    ///   - refinementPasses: Number of refinement passes for punctuation correction (default: 2)
    ///   - verbose: Whether to print verbose messages
    /// - Returns: Array of parody lines with preserved empty lines
    public func generateParody(
        originalLyrics: [String],
        keywords: [String: String],
        progressCallback: ((Int, Int) -> Void)? = nil,
        refinementPasses: Int = 2,
        verbose: Bool = false
    ) async throws -> [String] {
        // Verify model is available before starting
        try await verifyModel()
        
        // Track which lines are empty to preserve structure
        let emptyLineIndices = Set(originalLyrics.enumerated().compactMap { index, line in
            line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? index : nil
        })
        
        // Filter out empty lines for processing
        let nonEmptyLyrics = originalLyrics.enumerated().compactMap { index, line -> (Int, String)? in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : (index, line)
        }
        
        // Analyze original song structure (only non-empty lines)
        let syllableStructure = syllableCounter.analyzeSongStructure(nonEmptyLyrics.map { $0.1 })
        
        var parodyLines: [String] = []
        let totalLines = originalLyrics.count
        var nonEmptyIndex = 0
        
        // Generate each line, preserving empty lines
        for (index, originalLine) in originalLyrics.enumerated() {
            if emptyLineIndices.contains(index) {
                // Preserve empty lines
                parodyLines.append("")
                continue
            }
            
            let syllableCount = syllableStructure[nonEmptyIndex]
            nonEmptyIndex += 1
            
            progressCallback?(index + 1, totalLines)
            
            // Generate parody line matching syllable count
            var parodyLine: String
            do {
                parodyLine = try await ollamaClient.generateParodyLine(
                    originalLine: originalLine,
                    syllableCount: syllableCount,
                    keywords: keywords,
                    previousLines: Array(parodyLines.suffix(3).filter { !$0.isEmpty }) // Last 3 non-empty lines for context
                )
            } catch let error as OllamaError {
                // If generation fails, provide helpful error
                if verbose {
                    print("\nError generating line \(index + 1): \(error.description)")
                }
                throw error // Re-throw to be caught by outer handler
            } catch {
                // Unexpected error
                if verbose {
                    print("\nUnexpected error generating line \(index + 1): \(error.localizedDescription)")
                }
                throw OllamaError.networkError(error)
            }
            
            // Refinement passes for punctuation correction
            for pass in 1...refinementPasses {
                do {
                    parodyLine = try await refineLinePunctuation(
                        line: parodyLine,
                        originalLine: originalLine,
                        syllableCount: syllableCount,
                        keywords: keywords,
                        pass: pass
                    )
                } catch {
                    // If refinement fails, use the original generated line
                    // Log but don't fail the entire generation
                    if verbose {
                        print("Warning: Refinement pass \(pass) failed for line \(index + 1), using original line")
                    }
                    // Continue with the line we have, don't break
                }
            }
            
            parodyLines.append(parodyLine)
        }
        
        return parodyLines
    }
    
    /// Refine line punctuation to match original style
    private func refineLinePunctuation(
        line: String,
        originalLine: String,
        syllableCount: Int,
        keywords: [String: String],
        pass: Int
    ) async throws -> String {
        // Extract punctuation from original line
        let originalPunctuation = extractPunctuation(from: originalLine)
        
        // If original has no special punctuation, return as is
        if originalPunctuation.isEmpty {
            return line
        }
        
        // Only refine if there's a significant punctuation difference
        let linePunctuation = extractPunctuation(from: line)
        if originalPunctuation == linePunctuation {
            return line // Already matches
        }
        
        // Request refinement from Ollama
        let keywordDescriptions = keywords.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        
        let prompt = """
        Refine this parody line to match the punctuation style of the original.
        Keep exactly \(syllableCount) syllables.
        Maintain the theme: \(keywordDescriptions)
        
        Original line: "\(originalLine)"
        Original punctuation pattern: \(originalPunctuation)
        
        Current parody line: "\(line)"
        
        Refine ONLY the punctuation to match the original style. Keep the same words and meaning.
        Return ONLY the refined line, nothing else:
        """
        
        let refined = try await ollamaClient.generateParodyLine(
            originalLine: originalLine,
            syllableCount: syllableCount,
            keywords: keywords,
            previousLines: [],
            customPrompt: prompt
        )
        
        // Validate the refined line has similar syllable count
        let refinedSyllables = syllableCounter.countSyllablesInLine(refined)
        if abs(refinedSyllables - syllableCount) > 2 {
            // If refinement changed syllable count too much, use original
            return line
        }
        
        return refined
    }
    
    /// Extract punctuation pattern from a line
    private func extractPunctuation(from line: String) -> String {
        let punctuation = line.filter { ".,!?;:'\"-()[]{}".contains($0) }
        return punctuation.isEmpty ? "" : "Contains: \(punctuation)"
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

