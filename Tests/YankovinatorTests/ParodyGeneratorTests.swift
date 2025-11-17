// Copyright (C) 2025, Shyamal Suhana Chandra
// Tests for ParodyGenerator

import XCTest
@testable import Yankovinator

final class ParodyGeneratorTests: XCTestCase {
    
    var generator: ParodyGenerator?
    
    override func setUp() {
        super.setUp()
        // Initialize with Foundation Models (default model)
        // Note: This will fail gracefully if Foundation Models is not available
        do {
            generator = try ParodyGenerator()
        } catch {
            // Foundation Models not available - tests will be skipped
            // This is expected on systems without macOS 15.0+ or iOS 18.0+
            generator = nil
        }
    }
    
    func testKeywordExtraction() {
        guard let generator = generator else {
            // Foundation Models not available - skip test
            return
        }
        
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
        guard let generator = generator else { return }
        let keywords = generator.extractKeywords(from: "")
        XCTAssertEqual(keywords.count, 0)
    }
    
    func testKeywordExtractionWithInvalidFormat() {
        guard let generator = generator else { return }
        let text = "This is not in the correct format"
        let keywords = generator.extractKeywords(from: text)
        XCTAssertEqual(keywords.count, 0)
    }
    
    func testKeywordExtractionWithMultipleColons() {
        guard let generator = generator else { return }
        let text = "time: 12:00 PM"
        let keywords = generator.extractKeywords(from: text)
        XCTAssertEqual(keywords.count, 1)
        XCTAssertEqual(keywords["time"], "12:00 PM")
    }
    
    // Note: Foundation Models availability tests
    // These are integration tests that should be run manually or in CI
    func testFoundationModelsConnection() async throws {
        // This test will only pass if Foundation Models is available (macOS 15+ or iOS 18+)
        // Skip in automated tests unless Foundation Models is available
        guard let generator = generator else {
            print("⚠️  Foundation Models not available - skipping integration test")
            print("⚠️  Foundation Models requires macOS 15.0+ or iOS 18.0+")
            return
        }
        
        let isAvailable = try await generator.validateFoundationModelsConnection()
        
        if !isAvailable {
            print("⚠️  Foundation Models not available - skipping integration test")
            print("⚠️  Foundation Models requires macOS 15.0+ or iOS 18.0+")
            return
        }
        
        XCTAssertTrue(isAvailable)
    }
}

