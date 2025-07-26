import Foundation

class GitHubAPIClient: ObservableObject {
    static let shared = GitHubAPIClient()
    
    private let baseURL = AppConfig.githubAPIBaseURL
    private var authToken: GitHubToken?
    
    private init() {}
    
    func setAuthToken(_ token: GitHubToken) {
        self.authToken = token
    }
    
    func fetchRepositories() async throws -> [Repository] {
        guard AppConfig.isGitHubConfigured else {
            throw GitHubError.apiError("GitHub OAuth not configured. Please update AppConfig.swift with your GitHub client credentials.")
        }
        
        guard let token = authToken else {
            throw GitHubError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/user/repos?sort=updated&per_page=50")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.apiError("Failed to fetch repositories")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Repository].self, from: data)
    }
    
    func createRepository(name: String, description: String? = nil, isPrivate: Bool = false) async throws -> Repository {
        guard let token = authToken else {
            throw GitHubError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/user/repos")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CreateRepositoryRequest(
            name: name,
            description: description,
            private: isPrivate,
            autoInit: true
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.apiError("Failed to create repository")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Repository.self, from: data)
    }
    
    func createOrUpdateFile(
        repository: Repository,
        path: String,
        content: String,
        message: String,
        branch: String? = nil
    ) async throws -> CommitResponse {
        guard let token = authToken else {
            throw GitHubError.notAuthenticated
        }
        
        let targetBranch = branch ?? repository.defaultBranch
        let url = URL(string: "\(baseURL)/repos/\(repository.fullName)/contents/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get existing file SHA if it exists
        let existingSHA = try? await getFileSHA(repository: repository, path: path, branch: targetBranch)
        
        let contentData = content.data(using: .utf8)!
        let base64Content = contentData.base64EncodedString()
        
        let body = CreateFileRequest(
            message: message,
            content: base64Content,
            branch: targetBranch,
            sha: existingSHA
        )
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...201).contains(httpResponse.statusCode) else {
            throw GitHubError.apiError("Failed to create/update file")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(CommitResponse.self, from: data)
    }
    
    func commitMultipleFiles(
        repository: Repository,
        files: [FileChange],
        message: String,
        branch: String? = nil
    ) async throws -> [CommitResponse] {
        var responses: [CommitResponse] = []
        
        for file in files {
            switch file.operation {
            case .create, .update:
                let response = try await createOrUpdateFile(
                    repository: repository,
                    path: file.path,
                    content: file.content,
                    message: message,
                    branch: branch
                )
                responses.append(response)
            case .delete:
                // Implement delete functionality if needed
                break
            }
        }
        
        return responses
    }
    
    private func getFileSHA(repository: Repository, path: String, branch: String) async throws -> String {
        guard let token = authToken else {
            throw GitHubError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/repos/\(repository.fullName)/contents/\(path)?ref=\(branch)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.fileNotFound
        }
        
        let decoder = JSONDecoder()
        let fileInfo = try decoder.decode(GitHubFileInfo.self, from: data)
        return fileInfo.sha
    }
}

// MARK: - Request/Response Models

private struct CreateRepositoryRequest: Codable {
    let name: String
    let description: String?
    let `private`: Bool
    let autoInit: Bool
}

private struct CreateFileRequest: Codable {
    let message: String
    let content: String
    let branch: String
    let sha: String?
}

struct CommitResponse: Codable {
    let content: GitHubFileInfo
    let commit: GitHubCommitInfo
}

struct GitHubFileInfo: Codable {
    let name: String
    let path: String
    let sha: String
    let size: Int
    let url: String
    let htmlUrl: String
    let gitUrl: String
    let downloadUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url
        case htmlUrl = "html_url"
        case gitUrl = "git_url"
        case downloadUrl = "download_url"
    }
}

struct GitHubCommitInfo: Codable {
    let sha: String
    let url: String
    let htmlUrl: String
    let author: GitHubAuthor
    let committer: GitHubAuthor
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case sha, url, author, committer, message
        case htmlUrl = "html_url"
    }
}

struct GitHubAuthor: Codable {
    let name: String
    let email: String
    let date: String
}

enum GitHubError: Error, LocalizedError {
    case notAuthenticated
    case apiError(String)
    case fileNotFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with GitHub"
        case .apiError(let message):
            return message
        case .fileNotFound:
            return "File not found"
        case .networkError:
            return "Network error"
        }
    }
}
