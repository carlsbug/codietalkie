//
//  APIEndpoints.swift
//  codietalkie
//
//  API endpoints and configuration for external services
//

import Foundation

struct APIEndpoints {
    // MARK: - Hugging Face API
    static let huggingFaceBaseURL = "https://api-inference.huggingface.co"
    
    static func huggingFaceModelURL(model: String) -> String {
        return "\(huggingFaceBaseURL)/models/\(model)"
    }
    
    // MARK: - GitHub API
    static let githubBaseURL = "https://api.github.com"
    static let githubReposURL = "\(githubBaseURL)/user/repos"
    static let githubUserURL = "\(githubBaseURL)/user"
    
    static func githubRepoURL(owner: String, repo: String) -> String {
        return "\(githubBaseURL)/repos/\(owner)/\(repo)"
    }
    
    static func githubContentsURL(owner: String, repo: String, path: String) -> String {
        return "\(githubBaseURL)/repos/\(owner)/\(repo)/contents/\(path)"
    }
    
    static func githubRefsURL(owner: String, repo: String) -> String {
        return "\(githubBaseURL)/repos/\(owner)/\(repo)/git/refs"
    }
    
    static func githubBranchURL(owner: String, repo: String, branch: String) -> String {
        return "\(githubBaseURL)/repos/\(owner)/\(repo)/branches/\(branch)"
    }
    
    // MARK: - Request Configuration
    struct RequestConfig {
        static let timeoutInterval: TimeInterval = 30.0
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 1.0
    }
    
    // MARK: - LLM Configuration
    struct LLMConfig {
        static let maxTokens = 2000
        static let temperature = 0.7
        static let topP = 0.9
        static let stopSequences = ["</code>", "```"]
    }
}

// MARK: - HTTP Headers
extension APIEndpoints {
    static func huggingFaceHeaders(token: String) -> [String: String] {
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    static func githubHeaders(token: String) -> [String: String] {
        return [
            "Authorization": "token \(token)",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json",
            "User-Agent": "codietalkie-app"
        ]
    }
}
