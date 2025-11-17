// Copyright (C) 2025, Shyamal Suhana Chandra
// Foundation Models API client for generating parody lyrics using Apple's FoundationModels framework

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Client for interacting with Apple's Foundation Models framework
@available(macOS 15.0, iOS 18.0, *)
public class FoundationModelsClient {
    #if canImport(FoundationModels)
    @available(macOS 26.0, iOS 26.0, *)
    private var session: LanguageModelSession {
        get {
            fatalError("Session should only be accessed when FoundationModels is available")
        }
        set {
            // Storage handled in init
        }
    }
    private var _session: Any?
    #endif
    
    /// Initialize Foundation Models client
    /// - Parameter modelIdentifier: Optional model identifier (uses default if nil)
    public init(modelIdentifier: String? = nil) throws {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            // Initialize the language model session
            // FoundationModels provides on-device models that don't require external services
            // Use default model
            // Note: Framework requires macOS 26.0+ in availability, but may work on macOS 15.0+ at runtime
            self._session = LanguageModelSession(model: .default) as Any
        } else {
            throw FoundationModelsError.modelUnavailable
        }
        #else
        throw FoundationModelsError.modelUnavailable
        #endif
    }
    
    /// Generate parody line matching syllable count and theme
    /// - Parameters:
    ///   - originalLine: Original song line
    ///   - syllableCount: Target syllable count
    ///   - keywords: Theme keywords and their definitions
    ///   - previousLines: Previous lines for context
    ///   - customPrompt: Optional custom prompt (overrides default)
    ///   - rhymeGroup: Rhyme group identifier (A, B, C, etc.) for this line
    ///   - rhymingLines: Lines that should rhyme with this one
    ///   - rhymeScheme: The overall rhyme scheme pattern (e.g., "ABAB", "AABB")
    ///   - wordSyllablePattern: Pattern showing word-by-word syllable counts (e.g., "hello(2) world(1)")
    ///   - wordSyllables: Array of syllable counts per word position
    /// - Returns: Generated parody line
    public func generateParodyLine(
        originalLine: String,
        syllableCount: Int,
        keywords: [String: String],
        previousLines: [String] = [],
        customPrompt: String? = nil,
        rhymeGroup: String? = nil,
        rhymingLines: [String] = [],
        rhymeScheme: String? = nil,
        wordSyllablePattern: String? = nil,
        wordSyllables: [Int]? = nil
    ) async throws -> String {
        let keywordDescriptions = keywords.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        let context = previousLines.isEmpty ? "" : "Previous lines:\n\(previousLines.joined(separator: "\n"))\n\n"
        
        // Build word-by-word syllable matching instructions
        var wordSyllableInstructions = ""
        if let wordPattern = wordSyllablePattern, let wordSylls = wordSyllables, !wordSylls.isEmpty {
            wordSyllableInstructions = """
            
            CRITICAL: Word-by-word syllable matching required!
            Original line syllable pattern: \(wordPattern)
            You MUST substitute each word with a word that has the EXACT SAME number of syllables in the same position.
            For example, if the original has "hello(2) world(1)", your line must have a 2-syllable word followed by a 1-syllable word.
            The syllable pattern must be: \(wordSylls.map { String($0) }.joined(separator: "-"))
            """
        }
        
        // Build rhyming instructions
        var rhymingInstructions = ""
        if let rhymeGroup = rhymeGroup, let scheme = rhymeScheme {
            rhymingInstructions = "\n6. MUST RHYME with rhyme group '\(rhymeGroup)' in the \(scheme) rhyme scheme"
            if !rhymingLines.isEmpty {
                rhymingInstructions += "\n   The following lines rhyme with this one (use them as reference for the ending sound):"
                for rhymingLine in rhymingLines {
                    rhymingInstructions += "\n   - \(rhymingLine)"
                }
                rhymingInstructions += "\n   Your line must end with a word that rhymes with the ending words of these lines."
            } else {
                rhymingInstructions += "\n   This is the first line in rhyme group '\(rhymeGroup)'. Future lines in this group will need to rhyme with your line."
            }
        }
        
        // Use custom prompt if provided, otherwise use default
        let prompt: String
        if let customPrompt = customPrompt {
            prompt = customPrompt
        } else {
            // Build enhanced context with semantic coherence emphasis
            var semanticContext = ""
            if !previousLines.isEmpty {
                semanticContext = """
                
                SEMANTIC COHERENCE REQUIREMENTS:
                - The line must SEMANTICALLY CONNECT with the previous lines above
                - Build upon the narrative, theme, and emotional arc established so far
                - Use consistent imagery, metaphors, and thematic elements throughout
                - Ensure the line contributes meaningfully to the overall story/theme
                - Maintain logical flow and progression from previous lines
                - If previous lines establish a scene, emotion, or concept, continue or develop it naturally
                
                Previous lines for context:
                \(previousLines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
                """
            }
            
            prompt = """
            You are an exceptional creative parody writer crafting lyrics that amaze with artistic brilliance.
            Generate a single line of parody poetry that:
            
            1. Has exactly \(syllableCount) syllables total\(wordSyllableInstructions)
            2. STRONGLY EMBRACES and ADVANCES the theme of these keywords: \(keywordDescriptions)
               - Weave the theme keywords naturally into the line's meaning
               - Use imagery, metaphors, and concepts related to the theme
               - Make the theme central to the line's semantic content, not just mentioned
            3. Maintains the rhythm and style of the original: "\(originalLine)"
            4. Preserves punctuation style similar to the original
            5. Is creative, humorous, and appropriate\(rhymingInstructions)
            
            CRITICAL QUALITY REQUIREMENTS:
            - The line must make COGENT SENSE - it must be grammatically correct and semantically meaningful
            - The line must have ARTISTIC STYLE that AMAZES - use vivid imagery, clever wordplay, poetic devices, and evocative language
            - Each word substitution should be thoughtful and enhance the artistic quality
            - The line should flow naturally and sound like it belongs in a professional song
            - Avoid awkward phrasing or forced rhymes - prioritize natural, beautiful language
            - Use proper contractions with apostrophes (e.g., "don't", "can't", "it's", "won't") when appropriate for natural speech
            - SEMANTICALLY ADVANCE THE THEME: The line should push forward the chosen theme, not just mention it
            - THEME INTEGRATION: Make the theme keywords feel integral to the line's meaning, not forced or superficial\(semanticContext)
            
            \(context)Generate ONLY the parody line, nothing else. No explanations, no quotes, just the line:
            """
        }
        
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            // Generate completion using FoundationModels API
            // LanguageModelSession.respond(to:) returns Response<String>
            guard let session = _session as? LanguageModelSession else {
                throw FoundationModelsError.modelUnavailable
            }
            let response: LanguageModelSession.Response<String>
            do {
                response = try await session.respond(to: prompt)
            } catch {
                throw FoundationModelsError.generationError(error)
            }
            
            // Extract the generated text from Response
            let responseText = response.content
    
            // Clean up the response - remove wrapping quotes, preserve apostrophes in contractions
            var cleaned = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove wrapping double quotes only (at start/end)
            if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") && cleaned.count > 1 {
                cleaned = String(cleaned.dropFirst().dropLast())
            }
            
            // For single quotes, only remove if they're clearly wrapping quotes (not contractions)
            if cleaned.hasPrefix("'") && cleaned.hasSuffix("'") && cleaned.count > 1 {
                let middle = String(cleaned.dropFirst().dropLast())
                // Only remove if there are no apostrophes in the middle (indicating it's a wrapping quote, not contractions)
                if !middle.contains("'") {
                    cleaned = middle
                }
            }
            
            return cleaned
        } else {
            throw FoundationModelsError.modelUnavailable
        }
        #else
        throw FoundationModelsError.modelUnavailable
        #endif
    }
    
    /// Check if Foundation Models is available
    /// - Returns: True if Foundation Models is available
    public func checkAvailability() async throws -> Bool {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            // Foundation Models is available on supported platforms
            // Check if we can create a language model session
            let model = SystemLanguageModel.default
            return model.isAvailable
        } else {
            return false
        }
        #else
        return false
        #endif
    }
    
    /// Verify model is available
    /// - Throws: FoundationModelsError if model is not available
    public func verifyModel() async throws {
        let isAvailable = try await checkAvailability()
        if !isAvailable {
            throw FoundationModelsError.modelUnavailable
        }
    }
    
    /// Generate keywords with definitions from subjects
    /// - Parameters:
    ///   - subjects: Array of subjects or topics to generate keywords for
    ///   - count: Number of keyword pairs to generate (default: 10)
    /// - Returns: Dictionary mapping keywords to their definitions
    public func generateKeywords(
        from subjects: [String],
        count: Int = 10
    ) async throws -> [String: String] {
        let subjectsList = subjects.joined(separator: ", ")
        
        let prompt = """
        Generate \(count) keyword:definition pairs related to the following subject(s): \(subjectsList)
        
        Requirements:
        1. Each keyword should be a single word or short phrase (1-3 words max)
        2. Each definition should be a clear, concise explanation (one sentence)
        3. Keywords should be relevant to the given subject(s)
        4. Format your response EXACTLY as: keyword: definition (one per line)
        5. Do not include any additional text, explanations, or formatting
        6. Do not number the items
        7. Do not use quotes around keywords or definitions
        
        Example format:
        keyword1: definition of keyword1
        keyword2: definition of keyword2
        keyword3: definition of keyword3
        
        Generate \(count) keyword:definition pairs now:
        """
        
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            // Generate completion using FoundationModels API
            guard let session = _session as? LanguageModelSession else {
                throw FoundationModelsError.modelUnavailable
            }
            let response: LanguageModelSession.Response<String>
            do {
                response = try await session.respond(to: prompt)
            } catch {
                throw FoundationModelsError.generationError(error)
            }
            
            // Extract the generated text from Response
            let responseText = response.content
            
            let lines = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    
        var keywords: [String: String] = [:]
        
        for line in lines {
            // Look for the pattern "keyword: definition"
            if let colonIndex = line.firstIndex(of: ":") {
                let keyword = String(line[..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                let definition = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Remove quotes if present
                let cleanKeyword = keyword.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                let cleanDefinition = definition.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                
                if !cleanKeyword.isEmpty && !cleanDefinition.isEmpty {
                    keywords[cleanKeyword] = cleanDefinition
                }
            }
        }
        
            return keywords
        } else {
            throw FoundationModelsError.modelUnavailable
        }
        #else
        throw FoundationModelsError.modelUnavailable
        #endif
    }
}

/// Errors for Foundation Models client
public enum FoundationModelsError: Error, CustomStringConvertible {
    case modelUnavailable
    case invalidResponse
    case generationError(Error)
    
    public var description: String {
        switch self {
        case .modelUnavailable:
            return "Foundation Models framework is not available on this system. Requires macOS 15.0+ (Sequoia) or iOS 18.0+."
        case .invalidResponse:
            return "Invalid response from Foundation Models"
        case .generationError(let error):
            return "Generation error: \(error.localizedDescription)"
        }
    }
}
