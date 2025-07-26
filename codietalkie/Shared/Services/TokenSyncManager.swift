import Foundation

class TokenSyncManager {
    static let shared = TokenSyncManager()
    
    private let tokenKey = "github_token_shared"
    private let usernameKey = "github_username_shared"
    
    private init() {}
    
    // Store token (called from iPhone)
    func storeToken(_ token: String, username: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
        UserDefaults.standard.synchronize()
        
        // Also store in Watch-specific key for compatibility
        UserDefaults.standard.set(token, forKey: "github_token_watch")
        UserDefaults.standard.set(username, forKey: "github_username_watch")
        UserDefaults.standard.synchronize()
        
        print("TokenSyncManager: Stored token for user: \(username)")
    }
    
    // Retrieve token (called from Watch)
    func getStoredToken() -> (token: String?, username: String?) {
        let token = UserDefaults.standard.string(forKey: tokenKey) ?? 
                   UserDefaults.standard.string(forKey: "github_token_watch")
        let username = UserDefaults.standard.string(forKey: usernameKey) ?? 
                      UserDefaults.standard.string(forKey: "github_username_watch")
        
        print("TokenSyncManager: Retrieved token exists: \(token != nil), username: \(username ?? "none")")
        return (token, username)
    }
    
    // Clear token (called from iPhone when signing out)
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.removeObject(forKey: "github_token_watch")
        UserDefaults.standard.removeObject(forKey: "github_username_watch")
        UserDefaults.standard.synchronize()
        
        print("TokenSyncManager: Cleared all tokens")
    }
    
    // Check if authenticated
    func isAuthenticated() -> Bool {
        let (token, _) = getStoredToken()
        return token != nil && !token!.isEmpty
    }
}
