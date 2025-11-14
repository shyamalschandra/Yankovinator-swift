// Copyright (C) 2025, Shyamal Suhana Chandra
// Ollama API client for generating parody lyrics

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOPosix

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
        
        // Configure HTTP client with proper settings
        var configuration = HTTPClient.Configuration()
        configuration.timeout = HTTPClient.Configuration.Timeout(
            connect: .seconds(10),
            read: .seconds(60)
        )
        // Create HTTP client - use createNew (deprecation warning is acceptable)
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew, configuration: configuration)
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
    ///   - customPrompt: Optional custom prompt (overrides default)
    /// - Returns: Generated parody line
    public func generateParodyLine(
        originalLine: String,
        syllableCount: Int,
        keywords: [String: String],
        previousLines: [String] = [],
        customPrompt: String? = nil
    ) async throws -> String {
        let keywordDescriptions = keywords.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        let context = previousLines.isEmpty ? "" : "Previous lines:\n\(previousLines.joined(separator: "\n"))\n\n"
        
        // Use custom prompt if provided, otherwise use default
        let prompt: String
        if let customPrompt = customPrompt {
            prompt = customPrompt
        } else {
            prompt = """
            You are a creative parody writer. Generate a single line of parody poetry that:
            1. Has exactly \(syllableCount) syllables
            2. Follows the theme of these keywords: \(keywordDescriptions)
            3. Maintains the rhythm and style of the original: "\(originalLine)"
            4. Preserves punctuation style similar to the original
            5. Is creative, humorous, and appropriate
            
            \(context)Generate ONLY the parody line, nothing else. No explanations, no quotes, just the line:
            """
        }
        
        // Ensure baseURL doesn't have trailing slash
        let cleanBaseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let apiURL = "\(cleanBaseURL)/api/generate"
        
        // Validate and construct URL properly
        guard let url = URL(string: apiURL) else {
            throw OllamaError.invalidURL
        }
        
        // Build request body - Ollama expects specific format
        var requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]
        
        // Add options - Ollama API format
        let options: [String: Any] = [
            "temperature": 0.8,
            "top_p": 0.9,
            "num_predict": 100
        ]
        requestBody["options"] = options
        
        // Serialize JSON first to validate
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Create request - use apiURL string directly (HTTPClientRequest accepts String)
        var request = HTTPClientRequest(url: apiURL)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Accept", value: "application/json")
        request.body = .bytes(ByteBuffer(data: jsonData))
        
        // Execute request with detailed logging
        let response: HTTPClientResponse
        do {
            response = try await httpClient.execute(request, timeout: .seconds(60))
        } catch {
            // Network-level error
            throw OllamaError.networkError(error)
        }
        
        // Collect response body iteratively (collect() can hang with some Ollama responses)
        var responseData = Data()
        for try await buffer in response.body {
            responseData.append(contentsOf: buffer.readableBytesView)
        }
        
        // Check response status
        let statusCode = Int(response.status.code)
        guard response.status == .ok else {
            // Parse error from response body
            var errorMessage = ""
            var isModelNotFound = false
            var responseText = ""
            
            if !responseData.isEmpty {
                responseText = String(data: responseData, encoding: .utf8) ?? ""
                
                // Try to parse as JSON
                if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                    if let error = json["error"] as? String {
                        errorMessage = ": \(error)"
                        // Check if error indicates model not found
                        let lowerError = error.lowercased()
                        if lowerError.contains("model") && (lowerError.contains("not found") || lowerError.contains("does not exist") || lowerError.contains("not available")) {
                            isModelNotFound = true
                        }
                    } else {
                        // No error field, but status is not OK
                        errorMessage = ": Unexpected response format"
                    }
                } else {
                    // If not JSON, include the raw response
                    let preview = String(responseText.prefix(200))
                    errorMessage = ": \(preview)"
                }
            } else {
                errorMessage = ": Empty response body"
            }
            
            // Check for 404 status or model not found error
            // For 404, always treat as model not found (Ollama returns 404 for missing models)
            if statusCode == 404 {
                // Parse the actual error message from Ollama
                if !responseText.isEmpty, let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                   let error = json["error"] as? String {
                    // Use the actual error message from Ollama
                    throw OllamaError.modelNotFound(model: model)
                } else {
                    // Fallback if we can't parse
                    throw OllamaError.modelNotFound(model: model)
                }
            }
            
            if isModelNotFound {
                throw OllamaError.modelNotFound(model: model)
            }
            
            // For other errors, include detailed debugging info
            throw OllamaError.httpError(statusCode: statusCode, message: "\(errorMessage) (URL: \(apiURL), Model: \(model), Status: \(statusCode))")
        }
        
        guard !responseData.isEmpty else {
            throw OllamaError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            // Log the actual response for debugging
            let responseText = String(data: responseData, encoding: .utf8) ?? "Unknown"
            throw OllamaError.invalidResponse
        }
        
        guard let responseText = json["response"] as? String else {
            // If no response field, try to get error
            if let error = json["error"] as? String {
                throw OllamaError.httpError(statusCode: 500, message: ": \(error)")
            }
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
        let checkURL = "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/api/tags"
        
        guard URL(string: checkURL) != nil else {
            return false
        }
        
        var request = HTTPClientRequest(url: checkURL)
        request.method = .GET
        
        do {
            let response = try await httpClient.execute(request, timeout: .seconds(5))
            
            guard response.status == .ok else {
                return false
            }
            
            // Check if model exists - collect body iteratively
            var responseData = Data()
            for try await buffer in response.body {
                responseData.append(contentsOf: buffer.readableBytesView)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let models = json["models"] as? [[String: Any]] {
                // Check if our model is in the list
                for modelInfo in models {
                    if let modelName = modelInfo["name"] as? String {
                        if modelName == model || modelName.hasPrefix("\(model):") {
                            return true
                        }
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

