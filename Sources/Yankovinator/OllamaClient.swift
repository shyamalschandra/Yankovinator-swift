// Copyright (C) 2025, Shyamal Suhana Chandra
// Ollama API client for generating parody lyrics

import Foundation
import AsyncHTTPClient
import NIOCore

/// Client for interacting with Ollama API
public class OllamaClient {
    private let baseURL: String
    private let model: String
    private let httpClient: HTTPClient
    
    /// Initialize Ollama client
    /// - Parameters:
    ///   - baseURL: Base URL for Ollama API (default: http://localhost:11434)
    ///   - model: Model name to use (default: llama3.2:3b)
    public init(baseURL: String = "http://localhost:11434", model: String = "llama3.2:3b") {
        self.baseURL = baseURL
        self.model = model
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    }
    
    deinit {
        try? httpClient.syncShutdown()
    }
    
    /// Generate parody line matching syllable count and theme
    /// - Parameters:
    ///   - originalLine: Original song line
    ///   - syllableCount: Target syllable count
    ///   - keywords: Theme keywords and their definitions
    ///   - previousLines: Previous lines for context
    /// - Returns: Generated parody line
    public func generateParodyLine(
        originalLine: String,
        syllableCount: Int,
        keywords: [String: String],
        previousLines: [String] = []
    ) async throws -> String {
        let keywordDescriptions = keywords.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        let context = previousLines.isEmpty ? "" : "Previous lines:\n\(previousLines.joined(separator: "\n"))\n\n"
        
        let prompt = """
        You are a creative parody writer. Generate a single line of parody poetry that:
        1. Has exactly \(syllableCount) syllables
        2. Follows the theme of these keywords: \(keywordDescriptions)
        3. Maintains the rhythm and style of the original: "\(originalLine)"
        4. Is creative, humorous, and appropriate
        
        \(context)Generate ONLY the parody line, nothing else. No explanations, no quotes, just the line:
        """
        
        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false,
            "options": [
                "temperature": 0.8,
                "top_p": 0.9,
                "max_tokens": 100
            ]
        ]
        
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            throw OllamaError.invalidURL
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.body = .bytes(ByteBuffer(data: jsonData))
        
        let response = try await httpClient.execute(request, timeout: .seconds(60))
        
        guard response.status == .ok else {
            // Try to get error message from response body
            let body = try await response.body.collect(upTo: 1024 * 1024)
            var errorMessage = ""
            var isModelNotFound = false
            
            if body.readableBytes > 0 {
                let responseData = Data(buffer: body)
                if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                    if let error = json["error"] as? String {
                        errorMessage = ": \(error)"
                        // Check if error indicates model not found
                        if error.lowercased().contains("model") && error.lowercased().contains("not found") {
                            isModelNotFound = true
                        }
                    }
                }
            }
            
            // Check for 404 status or model not found error
            if response.status.code == 404 || isModelNotFound {
                throw OllamaError.modelNotFound(model: model)
            }
            
            throw OllamaError.httpError(statusCode: Int(response.status.code), message: errorMessage)
        }
        
        let body = try await response.body.collect(upTo: 10 * 1024 * 1024) // 10MB limit
        var responseData = Data()
        if body.readableBytes > 0 {
            responseData = Data(buffer: body)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OllamaError.invalidResponse
        }
        
        // Clean up the response - remove quotes, extra whitespace
        let cleaned = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "'", with: "")
        
        return cleaned
    }
    
    /// Check if Ollama is available and model exists
    /// - Returns: True if Ollama is reachable and model is available
    public func checkAvailability() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tags") else {
            return false
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .GET
        
        do {
            let response = try await httpClient.execute(request, timeout: .seconds(5))
            
            guard response.status == .ok else {
                return false
            }
            
            // Check if model exists
            let body = try await response.body.collect(upTo: 1024 * 1024) // 1MB limit
            var responseData = Data()
            if body.readableBytes > 0 {
                responseData = Data(buffer: body)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let models = json["models"] as? [[String: Any]] {
                // Check if our model is in the list
                for modelInfo in models {
                    if let modelName = modelInfo["name"] as? String,
                       modelName == model || modelName.hasPrefix("\(model):") {
                        return true
                    }
                }
            }
            
            // If we can't parse, assume it's available (backward compatibility)
            return true
        } catch {
            return false
        }
    }
    
    /// Verify model exists and is available
    /// - Throws: OllamaError if model is not available
    public func verifyModel() async throws {
        let isAvailable = try await checkAvailability()
        if !isAvailable {
            throw OllamaError.modelNotFound(model: model)
        }
    }
}

/// Errors for Ollama client
public enum OllamaError: Error, CustomStringConvertible {
    case invalidURL
    case httpError(statusCode: Int, message: String = "")
    case invalidResponse
    case networkError(Error)
    case modelNotFound(model: String)
    
    public var description: String {
        switch self {
        case .invalidURL:
            return "Invalid Ollama URL"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode)\(message)"
        case .invalidResponse:
            return "Invalid response from Ollama API"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .modelNotFound(let model):
            return "Model '\(model)' not found. Please ensure the model is installed: ollama pull \(model)"
        }
    }
}

