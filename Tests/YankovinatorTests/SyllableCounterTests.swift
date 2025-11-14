// Copyright (C) 2025, Shyamal Suhana Chandra
// Tests for SyllableCounter

import XCTest
@testable import Yankovinator

final class SyllableCounterTests: XCTestCase {
    
    func testSimpleWordSyllables() {
        XCTAssertEqual(SyllableCounter.countSyllables(in: "hello"), 2)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "world"), 1)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "cat"), 1)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "dog"), 1)
    }
    
    func testMultiSyllableWords() {
        XCTAssertEqual(SyllableCounter.countSyllables(in: "beautiful"), 3)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "wonderful"), 3)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "amazing"), 3)
    }
    
    func testEmptyString() {
        XCTAssertEqual(SyllableCounter.countSyllables(in: ""), 0)
        XCTAssertEqual(SyllableCounter.countSyllables(in: "   "), 0)
    }
    
    func testLineSyllables() {
        let line = "Hello world, how are you?"
        let count = SyllableCounter.countSyllablesInLine(line)
        XCTAssertGreaterThan(count, 0)
        XCTAssertLessThanOrEqual(count, 10) // Reasonable upper bound
    }
    
    func testSongStructureAnalysis() {
        let lyrics = [
            "Twinkle twinkle little star",
            "How I wonder what you are",
            "Up above the world so high",
            "Like a diamond in the sky"
        ]
        
        let structure = SyllableCounter.analyzeSongStructure(lyrics)
        XCTAssertEqual(structure.count, lyrics.count)
        
        // Each line should have syllables
        for count in structure {
            XCTAssertGreaterThan(count, 0)
        }
    }
    
    func testPunctuationHandling() {
        let word1 = SyllableCounter.countSyllables(in: "hello!")
        let word2 = SyllableCounter.countSyllables(in: "hello")
        XCTAssertEqual(word1, word2)
    }
    
    func testCaseInsensitivity() {
        let upper = SyllableCounter.countSyllables(in: "HELLO")
        let lower = SyllableCounter.countSyllables(in: "hello")
        let mixed = SyllableCounter.countSyllables(in: "HeLlO")
        XCTAssertEqual(upper, lower)
        XCTAssertEqual(lower, mixed)
    }
}

