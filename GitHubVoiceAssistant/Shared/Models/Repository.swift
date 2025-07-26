import Foundation

struct Repository: Codable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let owner: RepositoryOwner
    let defaultBranch: String
    let isPrivate: Bool
    let htmlUrl: String
    let cloneUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case fullName = "full_name"
        case owner
        case defaultBranch = "default_branch"
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case cloneUrl = "clone_url"
    }
}

struct RepositoryOwner: Codable {
    let login: String
    let id: Int
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarUrl = "avatar_url"
    }
}