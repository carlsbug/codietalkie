import Foundation

struct VoiceRequest: Identifiable, Codable {
    let id: UUID
    let transcription: String
    let timestamp: Date
    let repositoryId: Int?
    var status: RequestStatus
    
    init(transcription: String, repositoryId: Int? = nil) {
        self.id = UUID()
        self.transcription = transcription
        self.timestamp = Date()
        self.repositoryId = repositoryId
        self.status = .transcribing
    }
}

enum RequestStatus: Codable, CaseIterable {
    case transcribing
    case processing
    case reviewing
    case committing
    case completed
    case failed(String)
    
    var displayName: String {
        switch self {
        case .transcribing:
            return "Transcribing"
        case .processing:
            return "Processing"
        case .reviewing:
            return "Reviewing"
        case .committing:
            return "Committing"
        case .completed:
            return "Completed"
        case .failed(let error):
            return "Failed: \(error)"
        }
    }
}