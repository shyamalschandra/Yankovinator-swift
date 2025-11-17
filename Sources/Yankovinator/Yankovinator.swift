// Copyright (C) 2025, Shyamal Suhana Chandra
// Main Yankovinator library entry point

import Foundation
import NaturalLanguage

/// Yankovinator: Convert songs into parodies with theme-based keyword constraints
/// Uses NaturalLanguage framework and Apple's Foundation Models for intelligent parody generation
@available(macOS 15.0, iOS 18.0, *)
public struct Yankovinator {
    
    /// Generate a parody from original lyrics
    /// - Parameters:
    ///   - originalLyrics: Array of original song lines
    ///   - keywords: Dictionary mapping keywords to their definitions/meanings
    ///   - modelIdentifier: Optional Foundation Models model identifier (uses default if nil)
    /// - Returns: Array of parody lines matching syllable structure
    public static func generateParody(
        originalLyrics: [String],
        keywords: [String: String],
        modelIdentifier: String? = nil
    ) async throws -> [String] {
        let generator = try ParodyGenerator(modelIdentifier: modelIdentifier)
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

