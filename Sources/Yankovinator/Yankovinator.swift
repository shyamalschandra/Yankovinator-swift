// Copyright (C) 2025, Shyamal Suhana Chandra
// Main Yankovinator library entry point

import Foundation
import NaturalLanguage

/// Yankovinator: Convert songs into parodies with theme-based keyword constraints
/// Uses NaturalLanguage framework and Ollama for intelligent parody generation
public struct Yankovinator {
    
    /// Generate a parody from original lyrics
    /// - Parameters:
    ///   - originalLyrics: Array of original song lines
    ///   - keywords: Dictionary mapping keywords to their definitions/meanings
    ///   - ollamaURL: Optional Ollama API base URL (default: http://localhost:11434)
    ///   - ollamaModel: Optional Ollama model name (default: llama3.2:3b)
    /// - Returns: Array of parody lines matching syllable structure
    public static func generateParody(
        originalLyrics: [String],
        keywords: [String: String],
        ollamaURL: String = "http://localhost:11434",
        ollamaModel: String = "llama3.2:3b"
    ) async throws -> [String] {
        let generator = ParodyGenerator(ollamaBaseURL: ollamaURL, ollamaModel: ollamaModel)
        return try await generator.generateParody(originalLyrics: originalLyrics, keywords: keywords)
    }
    
    /// Count syllables in text using NaturalLanguage
    /// - Parameter text: Text to analyze
    /// - Returns: Syllable count
    public static func countSyllables(_ text: String) -> Int {
        return SyllableCounter.countSyllablesInLine(text)
    }
    
    /// Analyze song structure
    /// - Parameter lyrics: Array of lyric lines
    /// - Returns: Array of syllable counts per line
    public static func analyzeStructure(_ lyrics: [String]) -> [Int] {
        return SyllableCounter.analyzeSongStructure(lyrics)
    }
}

