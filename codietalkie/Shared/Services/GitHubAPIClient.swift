//
//  GitHubAPIClient.swift
//  codietalkie
//
//  Service for interacting with GitHub API
//  Handles repository operations, file creation, and commits
//

import Foundation
import Combine

class GitHubAPIClient: ObservableObject {
    static let shared = GitHubAPIClient()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Hello AI Feature
    func createHelloAIFile(owner: String, repo: String, token: String) async throws -> String {
        print("🤖 Creating Hello AI file in \(owner)/\(repo)")
        
        // Generate unique branch name
        let timestamp = Int(Date().timeIntervalSince1970)
        let branchName = "feature/hello-ai-world-\(timestamp)"
        
        // Create branch
        try await createBranch(owner: owner, repo: repo, branchName: branchName, token: token)
        
        // Create the hello-ai.py file content
        let helloAIContent = """
#!/usr/bin/env python3
\"\"\"
Hello, AI World! - A simple greeting from the future
Created by CodeTalkie Watch App
\"\"\"

def main():
    print("Hello, AI world!")
    print("Welcome to the age of intelligent assistants!")
    print("This file was created from an Apple Watch! 🤖⌚️")

if __name__ == "__main__":
    main()
"""
        
        // Create the file in the new branch
        try await createOrUpdateFile(
            owner: owner,
            repo: repo,
            path: "hello-ai.py",
            content: helloAIContent,
            message: "Created Hello, AI world!",
            branch: branchName,
            token: token
        )
        
        print("✅ Successfully created Hello AI file in branch: \(branchName)")
        return branchName
    }
    
    // MARK: - Branch Operations
    private func createBranch(owner: String, repo: String, branchName: String, token: String, fromBranch: String = "main") async throws {
        print("🌿 Creating branch: \(branchName) from \(fromBranch) in \(owner)/\(repo)")
        
        // First, get the SHA of the source branch
        let sourceSHA = try await getBranchSHA(owner: owner, repo: repo, branch: fromBranch, token: token)
        
        // Create the new branch
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/git/refs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("codietalkie-watch-app", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30.0
        
        let requestBody = CreateBranchRequest(
            ref: "refs/heads/\(branchName)",
            sha: sourceSHA
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            if httpResponse.statusCode == 422 {
                // Branch might already exist, that's okay for our use case
                print("⚠️ Branch \(branchName) might already exist")
                return
            }
            throw GitHubError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        print("✅ Successfully created branch: \(branchName)")
    }
    
    private func getBranchSHA(owner: String, repo: String, branch: String, token: String) async throws -> String {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/branches/\(branch)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("codietalkie-watch-app", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.apiError("Failed to get branch SHA for \(branch)")
        }
        
        let branchInfo = try decoder.decode(GitHubBranchInfo.self, from: data)
        return branchInfo.commit.sha
    }
    
    // MARK: - File Operations
    private func createOrUpdateFile(
        owner: String,
        repo: String,
        path: String,
        content: String,
        message: String,
        branch: String,
        token: String
    ) async throws {
        print("📝 Creating/updating file: \(path) in \(owner)/\(repo)")
        
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/contents/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("codietalkie-watch-app", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30.0
        
        let contentData = content.data(using: .utf8)!
        let base64Content = contentData.base64EncodedString()
        
        let requestBody = CreateFileRequest(
            message: message,
            content: base64Content,
            branch: branch,
            sha: nil
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubError.networkError("Invalid response")
        }
        
        guard [200, 201].contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GitHubError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        print("✅ Successfully created/updated file: \(path)")
    }
}

// MARK: - Request Models
struct CreateBranchRequest: Codable {
    let ref: String
    let sha: String
}

struct CreateFileRequest: Codable {
    let message: String
    let content: String
    let branch: String?
    let sha: String?
}

struct GitHubBranchInfo: Codable {
    let commit: GitHubCommit
}

struct GitHubCommit: Codable {
    let sha: String
}

// MARK: - Error Types
enum GitHubError: LocalizedError {
    case networkError(String)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(let message):
            return "GitHub API Error: \(message)"
        }
    }
}
