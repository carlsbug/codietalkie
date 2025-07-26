import Foundation

struct FileChange: Codable, Identifiable {
    let id = UUID()
    let path: String
    let content: String
    let operation: FileOperation
    let diff: String?
    
    enum CodingKeys: String, CodingKey {
        case path, content, operation, diff
    }
}

enum FileOperation: String, Codable {
    case create = "create"
    case update = "update"
    case delete = "delete"
    
    var displayName: String {
        switch self {
        case .create:
            return "Create"
        case .update:
            return "Update"
        case .delete:
            return "Delete"
        }
    }
}

struct CodeGenerationResponse: Codable {
    let files: [FileChange]
    let commitMessage: String
    let summary: String
    let branchName: String?
}
