import Foundation

class LLMService: ObservableObject {
    static let shared = LLMService()
    
    private let apiKey = AppConfig.openAIAPIKey
    private let baseURL = "\(AppConfig.openAIBaseURL)/chat/completions"
    
    private init() {}
    
    func processVoiceRequest(_ request: VoiceRequest) async throws -> CodeGenerationResponse {
        return try await processVoiceRequest(request.transcription, repository: nil)
    }
    
    func processVoiceRequest(_ transcription: String, repository: Repository?) async throws -> CodeGenerationResponse {
        return try await processVoiceRequestInternal(transcription, repository: repository)
    }
    
    private func processVoiceRequestInternal(_ request: String, repository: Repository?) async throws -> CodeGenerationResponse {
        // Validate API configuration
        guard AppConfig.isOpenAIConfigured else {
            throw LLMError.apiError("OpenAI API key not configured. Please update AppConfig.swift with your API key.")
        }
        
        let prompt = buildPrompt(request: request, repository: repository)
        
        let requestBody = OpenAIRequest(
            model: "gpt-4",
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: prompt)
            ],
            temperature: 0.3,
            maxTokens: 2000
        )
        
        let url = URL(string: baseURL)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LLMError.apiError("Failed to get response from LLM API")
        }
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let content = openAIResponse.choices.first?.message.content else {
            throw LLMError.invalidResponse
        }
        
        return try parseCodeResponse(content)
    }
    
    private func buildPrompt(request: String, repository: Repository?) -> String {
        var prompt = "User request: \(request)\n\n"
        
        if let repo = repository {
            prompt += "Target repository: \(repo.fullName)\n"
            prompt += "Default branch: \(repo.defaultBranch)\n\n"
        }
        
        prompt += """
        Please generate code based on this request and provide the response in the following JSON format:
        {
            "files": [
                {
                    "path": "relative/path/to/file.ext",
                    "content": "file content here",
                    "operation": "create|update|delete"
                }
            ],
            "commitMessage": "Brief commit message",
            "summary": "Brief summary of changes made"
        }
        
        Make sure the code is production-ready and follows best practices.
        """
        
        return prompt
    }
    
    private var systemPrompt: String {
        """
        You are a helpful coding assistant that generates code based on voice requests. 
        You should create clean, well-documented code that follows best practices.
        Always respond with valid JSON in the specified format.
        Keep file paths relative to the repository root.
        Make commit messages concise but descriptive.
        """
    }
    
    private func parseCodeResponse(_ content: String) throws -> CodeGenerationResponse {
        // Extract JSON from the response (in case there's extra text)
        guard let jsonStart = content.range(of: "{"),
              let jsonEnd = content.range(of: "}", options: .backwards) else {
            throw LLMError.invalidResponse
        }
        
        let jsonString = String(content[jsonStart.lowerBound...jsonEnd.upperBound])
        let jsonData = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        return try decoder.decode(CodeGenerationResponse.self, from: jsonData)
    }
}

// MARK: - OpenAI API Models

private struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

private struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

private struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

enum LLMError: Error, LocalizedError {
    case apiError(String)
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Invalid response from LLM"
        case .networkError:
            return "Network error"
        }
    }
}
