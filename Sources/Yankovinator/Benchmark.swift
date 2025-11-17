// Copyright (C) 2025, Shyamal Suhana Chandra
// Benchmarking system for Ollama performance

import Foundation

/// Benchmark results for parody generation
public struct BenchmarkResults {
    public let totalTime: TimeInterval
    public let averageTimePerLine: TimeInterval
    public let totalLines: Int
    public let framework: String
    public let timestamp: Date
    
    public init(totalTime: TimeInterval, averageTimePerLine: TimeInterval, totalLines: Int, framework: String, timestamp: Date = Date()) {
        self.totalTime = totalTime
        self.averageTimePerLine = averageTimePerLine
        self.totalLines = totalLines
        self.framework = framework
        self.timestamp = timestamp
    }
    
    public var description: String {
        return """
        Framework: \(framework)
        Total Time: \(String(format: "%.2f", totalTime))s
        Average Time per Line: \(String(format: "%.2f", averageTimePerLine))s
        Total Lines: \(totalLines)
        Timestamp: \(timestamp)
        """
    }
}

/// Benchmark runner for Ollama
public class BenchmarkRunner {
    private let testLyrics: [String]
    private let testKeywords: [String: String]
    private let ollamaBaseURL: String
    private let ollamaModel: String
    
    public init(lyrics: [String], keywords: [String: String], ollamaBaseURL: String = "http://localhost:11434", ollamaModel: String = "llama3.2:3b") {
        self.testLyrics = lyrics
        self.testKeywords = keywords
        self.ollamaBaseURL = ollamaBaseURL
        self.ollamaModel = ollamaModel
    }
    
    /// Benchmark Ollama
    public func benchmarkOllama() async throws -> BenchmarkResults {
        let startTime = Date()
        
        let generator = ParodyGenerator(ollamaBaseURL: ollamaBaseURL, ollamaModel: ollamaModel)
        let _ = try await generator.generateParody(
            originalLyrics: testLyrics,
            keywords: testKeywords,
            verbose: false
        )
        
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        let averageTimePerLine = totalTime / Double(testLyrics.count)
        
        return BenchmarkResults(
            totalTime: totalTime,
            averageTimePerLine: averageTimePerLine,
            totalLines: testLyrics.count,
            framework: "Ollama"
        )
    }
}
