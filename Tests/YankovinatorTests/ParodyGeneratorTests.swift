// Copyright (C) 2025, Shyamal Suhana Chandra
// Tests for ParodyGenerator

import XCTest
@testable import Yankovinator

final class ParodyGeneratorTests: XCTestCase {
    
    var generator: ParodyGenerator!
    
    override func setUp() {
        super.setUp()
        generator = ParodyGenerator(ollamaBaseURL: "http://localhost:11434", ollamaModel: "llama3.2")
    }
    
    func testKeywordExtraction() {
        let text = """
        science: the study of natural phenomena
        technology: application of scientific knowledge
        innovation: introduction of new ideas
        """
        
        let keywords = generator.extractKeywords(from: text)
        XCTAssertEqual(keywords.count, 3)
        XCTAssertEqual(keywords["science"], "the study of natural phenomena")
        XCTAssertEqual(keywords["technology"], "application of scientific knowledge")
        XCTAssertEqual(keywords["innovation"], "introduction of new ideas")
    }
    
    func testKeywordExtractionWithEmptyText() {
        let keywords = generator.extractKeywords(from: "")
        XCTAssertEqual(keywords.count, 0)
    }
    
    func testKeywordExtractionWithInvalidFormat() {
        let text = "This is not in the correct format"
        let keywords = generator.extractKeywords(from: text)
        XCTAssertEqual(keywords.count, 0)
    }
    
    func testKeywordExtractionWithMultipleColons() {
        let text = "time: 12:00 PM"
        let keywords = generator.extractKeywords(from: text)
        XCTAssertEqual(keywords.count, 1)
        XCTAssertEqual(keywords["time"], "12:00 PM")
    }
    
    // Note: Ollama connection tests would require a running Ollama instance
    // These are integration tests that should be run manually or in CI
    func testOllamaConnection() async throws {
        // This test will only pass if Ollama is running
        // Skip in automated tests unless Ollama is available
        let isAvailable = try await generator.validateOllamaConnection()
        
        if !isAvailable {
            print("⚠️  Ollama not available - skipping integration test")
            return
        }
        
        XCTAssertTrue(isAvailable)
    }
}

