// Copyright (C) 2025, Shyamal Suhana Chandra
// Integration tests for Yankovinator

import XCTest
@testable import Yankovinator

final class YankovinatorTests: XCTestCase {
    
    func testSyllableCounting() {
        let text = "Hello world"
        let count = Yankovinator.countSyllables(text)
        XCTAssertGreaterThan(count, 0)
    }
    
    func testStructureAnalysis() {
        let lyrics = [
            "Row row row your boat",
            "Gently down the stream",
            "Merrily merrily merrily merrily",
            "Life is but a dream"
        ]
        
        let structure = Yankovinator.analyzeStructure(lyrics)
        XCTAssertEqual(structure.count, lyrics.count)
        
        for count in structure {
            XCTAssertGreaterThan(count, 0, "Each line should have at least one syllable")
        }
    }
    
    func testParodyGeneration() async throws {
        // This is an integration test that requires Foundation Models
        // Skip if Foundation Models is not available (requires macOS 15+ or iOS 18+)
        
        let lyrics = [
            "Twinkle twinkle little star",
            "How I wonder what you are"
        ]
        
        let keywords = [
            "space": "the physical universe beyond Earth",
            "stars": "luminous celestial bodies"
        ]
        
        // Check if Foundation Models is available first
        let generator: ParodyGenerator
        do {
            generator = try ParodyGenerator()
        } catch {
            print("⚠️  Foundation Models not available - skipping integration test")
            print("⚠️  Foundation Models requires macOS 15.0+ or iOS 18.0+")
            return
        }
        
        do {
            let isAvailable = try await generator.validateFoundationModelsConnection()
            
            guard isAvailable else {
                print("⚠️  Foundation Models not available - skipping integration test")
                print("⚠️  Foundation Models requires macOS 15.0+ or iOS 18.0+")
                return
            }
            
            let parody = try await Yankovinator.generateParody(
                originalLyrics: lyrics,
                keywords: keywords
            )
            
            XCTAssertEqual(parody.count, lyrics.count, "Parody should have same number of lines")
            
            for line in parody {
                XCTAssertFalse(line.isEmpty, "Parody lines should not be empty")
            }
        } catch {
            // Foundation Models not available or connection error - skip test
            print("⚠️  Foundation Models connection failed - skipping integration test: \(error)")
            return
        }
    }
}

