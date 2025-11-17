// Copyright (C) 2025, Shyamal Suhana Chandra
// Command-line interface for benchmarking Yankovinator performance

import Foundation
import ArgumentParser
import Yankovinator

@main
struct BenchmarkCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "benchmark",
        abstract: "Benchmark Yankovinator performance with Foundation Models",
        discussion: """
        Benchmark tool to measure Yankovinator's performance using Foundation Models.
        
        Example usage:
          swift run benchmark --lyrics data/test_short.txt --keywords data/test_keywords.txt
        """
    )
    
    @Option(name: .shortAndLong, help: "Path to lyrics file")
    var lyrics: String
    
    @Option(name: .shortAndLong, help: "Path to keywords file")
    var keywords: String?
    
    @Option(name: .shortAndLong, help: "Number of iterations (default: 1)")
    var iterations: Int = 1
    
    @Flag(name: .shortAndLong, help: "Verbose output")
    var verbose: Bool = false
    
    func run() async throws {
        print("=== Yankovinator Benchmark ===")
        print("Framework: Foundation Models")
        print("")
        
        // Read lyrics
        guard let lyricsContent = try? String(contentsOfFile: lyrics, encoding: .utf8) else {
            throw ValidationError("Could not read lyrics file: \(lyrics)")
        }
        
        let lyricsLines = lyricsContent
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !lyricsLines.isEmpty else {
            throw ValidationError("No lyrics found in file")
        }
        
        // Read keywords
        var keywordsDict: [String: String] = [:]
        if let keywordsFile = keywords {
            guard let keywordsContent = try? String(contentsOfFile: keywordsFile, encoding: .utf8) else {
                throw ValidationError("Could not read keywords file: \(keywordsFile)")
            }
            
            if #available(macOS 15.0, iOS 18.0, *) {
                let generator = try ParodyGenerator()
                keywordsDict = generator.extractKeywords(from: keywordsContent)
            } else {
                throw ValidationError("Foundation Models requires macOS 15+ or iOS 18+")
            }
        } else {
            keywordsDict = ["parody": "humorous imitation", "creative": "original and imaginative"]
        }
        
        if verbose {
            print("Test Configuration:")
            print("  Lyrics: \(lyricsLines.count) lines")
            print("  Keywords: \(keywordsDict.count) keywords")
            print("  Iterations: \(iterations)")
            print("")
        }
        
        // Run benchmark
        let runner = BenchmarkRunner(lyrics: lyricsLines, keywords: keywordsDict)
        
        var results: [BenchmarkResults] = []
        
        for i in 1...iterations {
            if verbose {
                print("Running iteration \(i)/\(iterations)...")
            }
            
            let result = try await runner.benchmarkFoundationModels()
            results.append(result)
            
            if verbose {
                print("  Time: \(String(format: "%.2f", result.totalTime))s")
                print("  Avg per line: \(String(format: "%.2f", result.averageTimePerLine))s")
            }
        }
        
        // Calculate averages
        let avgTotalTime = results.map { $0.totalTime }.reduce(0, +) / Double(results.count)
        let avgPerLine = results.map { $0.averageTimePerLine }.reduce(0, +) / Double(results.count)
        
        print("")
        print("=== Benchmark Results ===")
        print("Framework: Foundation Models")
        print("Iterations: \(iterations)")
        print("Average Total Time: \(String(format: "%.2f", avgTotalTime))s")
        print("Average Time per Line: \(String(format: "%.2f", avgPerLine))s")
        print("Total Lines: \(lyricsLines.count)")
        print("")
        
        if iterations > 1 {
            let minTime = results.map { $0.totalTime }.min() ?? 0
            let maxTime = results.map { $0.totalTime }.max() ?? 0
            print("Min Time: \(String(format: "%.2f", minTime))s")
            print("Max Time: \(String(format: "%.2f", maxTime))s")
        }
    }
}
