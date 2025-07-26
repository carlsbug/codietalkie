import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.githubvoiceassistant.tokens"
    private let accessGroup = "group.com.githubvoiceassistant.shared"
    
    private init() {}
    
    func save(_ token: GitHubToken, for key: String) throws {
        let data = try JSONEncoder().encode(token)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave(status)
        }
    }
    
    func load(for key: String) throws -> GitHubToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unableToLoad(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return try JSONDecoder().decode(GitHubToken.self, from: data)
    }
    
    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status)
        }
    }
}

enum KeychainError: Error {
    case unableToSave(OSStatus)
    case unableToLoad(OSStatus)
    case unableToDelete(OSStatus)
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .unableToSave(let status):
            return "Unable to save to keychain. Status: \(status)"
        case .unableToLoad(let status):
            return "Unable to load from keychain. Status: \(status)"
        case .unableToDelete(let status):
            return "Unable to delete from keychain. Status: \(status)"
        case .invalidData:
            return "Invalid data in keychain"
        }
    }
}