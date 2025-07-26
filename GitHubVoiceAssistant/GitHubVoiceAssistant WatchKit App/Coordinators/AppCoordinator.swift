import SwiftUI
import Combine

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .authentication
    @Published var selectedRepository: Repository?
    @Published var currentVoiceRequest: VoiceRequest?
    @Published var generatedCode: CodeGenerationResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let connectivity = WatchConnectivityManager.shared
    private let keychain = KeychainManager.shared
    private let speechService = SpeechRecognitionService.shared
    private let llmService = LLMService.shared
    private let githubAPI = GitHubAPIClient.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        checkAuthenticationStatus()
    }
    
    private func setupBindings() {
        // Listen for authentication token from iPhone
        connectivity.$authToken
            .compactMap { $0 }
            .sink { [weak self] token in
                self?.handleAuthenticationSuccess(token)
            }
            .store(in: &cancellables)
        
        // Listen for speech recognition results
        speechService.$transcriptionResult
            .compactMap { $0 }
            .sink { [weak self] transcription in
                self?.handleSpeechRecognition(transcription)
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationStatus() {
        do {
            if let token = try keychain.load(for: "github_token"), !token.isExpired {
                githubAPI.setAuthToken(token)
                currentView = .dashboard
            }
        } catch {
            print("Failed to load stored token: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Navigation Methods
    
    func requestAuthentication() {
        connectivity.requestAuthentication()
    }
    
    func showRepositorySelection() {
        currentView = .repositorySelection
    }
    
    func showVoiceInput() {
        guard selectedRepository != nil else {
            errorMessage = "Please select a repository first"
            return
        }
        currentView = .voiceInput
    }
    
    func showCodeReview() {
        currentView = .codeReview
    }
    
    func returnToDashboard() {
        currentView = .dashboard
        currentVoiceRequest = nil
        generatedCode = nil
        errorMessage = nil
    }
    
    // MARK: - Authentication Flow
    
    private func handleAuthenticationSuccess(_ token: GitHubToken) {
        do {
            try keychain.save(token, for: "github_token")
            githubAPI.setAuthToken(token)
            currentView = .dashboard
        } catch {
            errorMessage = "Failed to save authentication token"
        }
    }
    
    // MARK: - Voice-to-Code Flow
    
    func startVoiceRecording() {
        do {
            isLoading = true
            try speechService.startRecording()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func stopVoiceRecording() {
        let transcription = speechService.stopRecording()
        Task {
            await handleSpeechRecognition(transcription)
        }
    }
    
    private func handleSpeechRecognition(_ transcription: String) async {
        guard let repository = selectedRepository else {
            errorMessage = "No repository selected"
            isLoading = false
            return
        }
        
        currentVoiceRequest = VoiceRequest(transcription: transcription, repositoryId: repository.id)
        
        do {
            // Process with LLM
            let codeResponse = try await llmService.processVoiceRequest(
                VoiceRequest(transcription: transcription, repositoryId: repository.id)
            )
            
            generatedCode = codeResponse
            currentView = .codeReview
            isLoading = false
        } catch {
            errorMessage = "Failed to generate code: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Repository Management
    
    func selectRepository(_ repository: Repository) {
        selectedRepository = repository
        currentView = .dashboard
    }
    
    func createRepository(name: String) {
        Task {
            do {
                isLoading = true
                let newRepo = try await githubAPI.createRepository(name: name)
                selectedRepository = newRepo
                currentView = .dashboard
                isLoading = false
            } catch {
                errorMessage = "Failed to create repository: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // MARK: - Code Review and Commit
    
    func approveAndCommitCode() {
        guard let repository = selectedRepository,
              let codeResponse = generatedCode,
              let voiceRequest = currentVoiceRequest else {
            errorMessage = "Missing required data for commit"
            return
        }
        
        Task {
            do {
                isLoading = true
                
                // Commit files to repository
                for fileChange in codeResponse.files {
                    try await githubAPI.createOrUpdateFile(
                        repository: repository,
                        path: fileChange.path,
                        content: fileChange.content,
                        message: codeResponse.commitMessage
                    )
                }
                
                // Success - return to dashboard
                returnToDashboard()
                isLoading = false
                
            } catch {
                errorMessage = "Failed to commit code: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func rejectCode() {
        currentView = .voiceInput
        generatedCode = nil
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
}

enum AppView {
    case authentication
    case dashboard
    case repositorySelection
    case voiceInput
    case codeReview
}