import Foundation

struct GitHubToken: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let expiresAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case expiresAt = "expires_at"
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() >= expiresAt
    }
}