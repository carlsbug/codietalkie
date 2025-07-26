//
//  TokenManager.swift
//  codietalkie
//
//  Manages GitHub token storage, validation, and user authentication
//

import Foundation

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: GitHubUser?
    @Published var storedToken: String?
    
    private let tokenKey = "github_token"
    private let userKey = "github_user"
    
    private init() {
        loadStoredToken()
    }
    
    // MARK: - Token Storage
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        storedToken = token
        
        if APICredentials.verboseLogging {
            print("🔑 Token saved to UserDefaults")
        }
    }
    
    func loadStoredToken() {
        storedToken = UserDefaults.standard.string(forKey: tokenKey)
        
        if let token = storedToken, !token.isEmpty {
            // Auto-validate stored token on app launch
            Task {
                await validateStoredToken()
            }
        }
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        
        DispatchQueue.main.async {
            self.storedToken = nil
            self.currentUser = nil
            self.isAuthenticated = false
        }
        
        if APICredentials.verboseLogging {
            print("🗑️ Token cleared from storage")
        }
    }
    
    // MARK: - Token Validation
    func validateToken(_ token: String) async throws -> GitHubUser {
        if APICredentials.verboseLogging {
            print("🔍 Validating GitHub token...")
        }
        
        // Validate token format
        guard token.hasPrefix("ghp_") || token.hasPrefix("github_pat_") else {
            throw TokenError.invalidFormat("Token must start with 'ghp_' or 'github_pat_'")
        }
        
        guard token.count >= 20 else {
            throw TokenError.invalidFormat("Token appears to be too short")
        }
        
        // Test token with GitHub API
        let url = URL(string: APIEndpoints.githubUserURL)!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = APIEndpoints.githubHeaders(token: token)
        request.timeoutInterval = APIEndpoints.RequestConfig.timeoutInterval
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TokenError.networkError("Invalid response from GitHub")
        }
        
        if APICredentials.verboseLogging {
            print("📡 GitHub API Response: \(httpResponse.statusCode)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            // Token is valid, parse user info
            let decoder = JSONDecoder()
            let user = try decoder.decode(GitHubUser.self, from: data)
            
            if APICredentials.verboseLogging {
                print("✅ Token validated for user: @\(user.login)")
            }
            
            return user
            
        case 401:
            throw TokenError.unauthorized("Invalid or expired token")
            
        case 403:
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorData["message"] as? String,
               message.contains("rate limit") {
                throw TokenError.rateLimited("GitHub API rate limit exceeded")
            } else {
                throw TokenError.forbidden("Token lacks required permissions. Ensure 'repo' and 'user' scopes are enabled.")
            }
            
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw TokenError.apiError("GitHub API error (\(httpResponse.statusCode)): \(errorMessage)")
        }
    }
    
    private func validateStoredToken() async {
        guard let token = storedToken else { return }
        
        do {
            let user = try await validateToken(token)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            // Save user info
            saveUserInfo(user)
            
        } catch {
            if APICredentials.verboseLogging {
                print("⚠️ Stored token validation failed: \(error.localizedDescription)")
            }
            
            // Clear invalid token
            DispatchQueue.main.async {
                self.clearToken()
            }
        }
    }
    
    // MARK: - Authentication Flow
    func authenticateWithToken(_ token: String) async throws {
        let user = try await validateToken(token)
        
        // Save token and user info
        saveToken(token)
        saveUserInfo(user)
        
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        clearToken()
    }
    
    // MARK: - User Info Storage
    private func saveUserInfo(_ user: GitHubUser) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
    }
    
    private func loadUserInfo() -> GitHubUser? {
        guard let userData = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(GitHubUser.self, from: userData) else {
            return nil
        }
        return user
    }
    
    // MARK: - Token Access
    func getValidToken() -> String? {
        // Return stored token if authenticated
        if isAuthenticated, let token = storedToken {
            return token
        }
        
        // Fallback to credentials file token
        if !APICredentials.githubToken.contains("your_") {
            return APICredentials.githubToken
        }
        
        return nil
    }
}

// MARK: - Error Types
enum TokenError: LocalizedError {
    case invalidFormat(String)
    case unauthorized(String)
    case forbidden(String)
    case rateLimited(String)
    case networkError(String)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat(let message):
            return "Invalid Token Format: \(message)"
        case .unauthorized(let message):
            return "Authentication Failed: \(message)"
        case .forbidden(let message):
            return "Permission Denied: \(message)"
        case .rateLimited(let message):
            return "Rate Limited: \(message)"
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidFormat:
            return "Please check that you've copied the complete token from GitHub."
        case .unauthorized:
            return "Please generate a new token at github.com/settings/tokens"
        case .forbidden:
            return "Create a new token with 'repo' and 'user' permissions at github.com/settings/tokens"
        case .rateLimited:
            return "Please wait a few minutes before trying again."
        case .networkError:
            return "Please check your internet connection and try again."
        case .apiError:
            return "Please try again or check GitHub's status page."
        }
    }
}
