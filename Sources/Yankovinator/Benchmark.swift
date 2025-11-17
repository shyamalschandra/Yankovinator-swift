// Copyright (C) 2025, Shyamal Suhana Chandra
// Benchmarking system to compare Foundation Models vs Ollama performance

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

/// Benchmark comparison results
public struct BenchmarkComparison {
    public let foundationModelsResults: BenchmarkResults
    public let ollamaResults: BenchmarkResults?
    public let speedup: Double?
    public let improvement: String
    
    public init(foundationModelsResults: BenchmarkResults, ollamaResults: BenchmarkResults?) {
        self.foundationModelsResults = foundationModelsResults
        self.ollamaResults = ollamaResults
        
        if let ollama = ollamaResults {
            self.speedup = ollama.totalTime / foundationModelsResults.totalTime
            if let speedup = self.speedup {
                if speedup > 1.0 {
                    self.improvement = "Foundation Models is \(String(format: "%.2f", speedup))x faster"
                } else {
                    self.improvement = "Ollama is \(String(format: "%.2f", 1.0/speedup))x faster"
                }
            } else {
                self.improvement = "Cannot compare"
            }
        } else {
            self.speedup = nil
            self.improvement = "No Ollama comparison available"
        }
    }
    
    public var description: String {
        var result = "=== Benchmark Comparison ===\n\n"
        result += "Foundation Models:\n\(foundationModelsResults.description)\n\n"
        if let ollama = ollamaResults {
            result += "Ollama:\n\(ollama.description)\n\n"
            result += "Comparison: \(improvement)\n"
        } else {
            result += "Ollama: Not available for comparison\n"
        }
        return result
    }
}

/// Benchmark runner for comparing Foundation Models and Ollama
@available(macOS 15.0, iOS 18.0, *)
public class BenchmarkRunner {
    private let testLyrics: [String]
    private let testKeywords: [String: String]
    
    public init(lyrics: [String], keywords: [String: String]) {
        self.testLyrics = lyrics
        self.testKeywords = keywords
    }
    
    /// Benchmark Foundation Models
    public func benchmarkFoundationModels() async throws -> BenchmarkResults {
        let startTime = Date()
        
        let generator = try ParodyGenerator()
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
            framework: "Foundation Models"
        )
    }
    
    /// Benchmark Ollama (for comparison - requires Ollama to be running)
    /// Note: This is kept for historical comparison but Ollama support has been removed
    public func benchmarkOllama() async throws -> BenchmarkResults? {
        // Ollama benchmarking removed - Foundation Models is now the only option
        return nil
    }
    
    /// Run full benchmark comparison
    public func runComparison() async throws -> BenchmarkComparison {
        let foundationResults = try await benchmarkFoundationModels()
        let ollamaResults = try? await benchmarkOllama()
        
        return BenchmarkComparison(
            foundationModelsResults: foundationResults,
            ollamaResults: ollamaResults
        )
    }
}
