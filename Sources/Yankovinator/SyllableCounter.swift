// Copyright (C) 2025, Shyamal Suhana Chandra
// Syllable counting using NaturalLanguage framework

import Foundation
import NaturalLanguage

/// SyllableCounter provides syllable counting functionality using Apple's NaturalLanguage framework
public struct SyllableCounter {
    
    /// Count syllables in a word using NaturalLanguage tokenization and phonetic analysis
    /// - Parameter word: The word to count syllables in
    /// - Returns: The number of syllables in the word
    public static func countSyllables(in word: String) -> Int {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Remove punctuation
        let cleanedWord = trimmedWord.filter { $0.isLetter }
        
        guard !cleanedWord.isEmpty else { return 0 }
        
        // Use NaturalLanguage tokenizer
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = cleanedWord
        
        var syllableCount = 0
        tokenizer.enumerateTokens(in: cleanedWord.startIndex..<cleanedWord.endIndex) { tokenRange, _ in
            let token = String(cleanedWord[tokenRange])
            syllableCount += estimateSyllables(for: token)
            return true
        }
        
        // If tokenizer didn't find tokens, use fallback method
        if syllableCount == 0 {
            syllableCount = estimateSyllables(for: cleanedWord)
        }
        
        return max(1, syllableCount) // At least one syllable
    }
    
    /// Estimate syllables using vowel counting heuristic
    /// - Parameter word: The word to analyze
    /// - Returns: Estimated syllable count
    private static func estimateSyllables(for word: String) -> Int {
        let vowels = "aeiouy"
        var count = 0
        var previousWasVowel = false
        
        for char in word.lowercased() {
            let isVowel = vowels.contains(char)
            if isVowel && !previousWasVowel {
                count += 1
            }
            previousWasVowel = isVowel
        }
        
        // Handle silent 'e' at the end
        if word.lowercased().hasSuffix("e") && count > 1 {
            count -= 1
        }
        
        // Handle 'le' at the end (e.g., "table", "little")
        if word.lowercased().hasSuffix("le") && count > 1 {
            // Usually adds a syllable unless preceded by a consonant cluster
            let beforeLe = String(word.dropLast(2))
            if !beforeLe.isEmpty && !vowels.contains(beforeLe.last!) {
                count += 1
            }
        }
        
        return max(1, count)
    }
    
    /// Count syllables in a line of text
    /// - Parameter line: The line of text
    /// - Returns: Total syllable count for the line
    public static func countSyllablesInLine(_ line: String) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = line
        
        var totalSyllables = 0
        tokenizer.enumerateTokens(in: line.startIndex..<line.endIndex) { tokenRange, _ in
            let word = String(line[tokenRange])
            totalSyllables += countSyllables(in: word)
            return true
        }
        
        return totalSyllables
    }
    
    /// Analyze a song's syllable structure
    /// - Parameter lyrics: Array of lyric lines
    /// - Returns: Array of syllable counts per line
    public static func analyzeSongStructure(_ lyrics: [String]) -> [Int] {
        return lyrics.map { countSyllablesInLine($0) }
    }
}

