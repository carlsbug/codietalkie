import Foundation
import AuthenticationServices
import Combine

class GitHubAuthService: ObservableObject {
    static let shared = GitHubAuthService()
    
    @Published var isAuthenticated = false
    @Published var currentToken: GitHubToken?
    @Published var isLoading = false
    
    private let keychain = KeychainManager.shared
    private let connectivity = WatchConnectivityManager.shared
    private let tokenKey = "github_token"
    
    // GitHub OAuth Configuration
    private let clientId = AppConfig.githubClientId
    private let clientSecret = AppConfig.githubClientSecret
    private let redirectUri = AppConfig.githubRedirectUri
    private let scope = AppConfig.githubScope
    
    private init() {
        loadStoredToken()
    }
    
    private func loadStoredToken() {
        do {
            if let token = try keychain.load(for: tokenKey) {
                if !token.isExpired {
                    currentToken = token
                    isAuthenticated = true
                    // Share token with watch
                    connectivity.sendAuthToken(token)
                } else {
                    // Token expired, clear it
                    try keychain.delete(for: tokenKey)
                }
            }
        } catch {
            print("Failed to load stored token: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func authenticate() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let authURL = buildAuthURL()
        
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "githubvoiceassistant"
            ) { [weak self] callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let callbackURL = callbackURL,
                      let code = self?.extractCode(from: callbackURL) else {
                    continuation.resume(throwing: AuthError.invalidCallback)
                    return
                }
                
                Task {
                    do {
                        let token = try await self?.exchangeCodeForToken(code)
                        if let token = token {
                            try self?.keychain.save(token, for: self?.tokenKey ?? "")
                            await MainActor.run {
                                self?.currentToken = token
                                self?.isAuthenticated = true
                            }
                            // Share token with watch
                            self?.connectivity.sendAuthToken(token)
                        }
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            session.presentationContextProvider = self
            session.start()
        }
    }
    
    func logout() {
        do {
            try keychain.delete(for: tokenKey)
            currentToken = nil
            isAuthenticated = false
        } catch {
            print("Failed to delete token: \(error.localizedDescription)")
        }
    }
    
    private func buildAuthURL() -> URL {
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        return components.url!
    }
    
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        return queryItems.first { $0.name == "code" }?.value
    }
    
    private func exchangeCodeForToken(_ code: String) async throws -> GitHubToken {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectUri
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        return GitHubToken(
            accessToken: tokenResponse.accessToken,
            tokenType: tokenResponse.tokenType,
            scope: tokenResponse.scope,
            expiresAt: nil // GitHub tokens don't expire by default
        )
    }
}

extension GitHubAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

enum AuthError: Error, LocalizedError {
    case invalidCallback
    case tokenExchangeFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCallback:
            return "Invalid OAuth callback"
        case .tokenExchangeFailed:
            return "Failed to exchange code for token"
        }
    }
}

private struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}