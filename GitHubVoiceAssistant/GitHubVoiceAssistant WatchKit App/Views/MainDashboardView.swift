import SwiftUI

struct MainDashboardView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @StateObject private var githubClient = GitHubAPIClient.shared
    @StateObject private var llmService = LLMService.shared
    
    @State private var selectedRepository: Repository?
    @State private var currentView: AppView = .dashboard
    @State private var currentRequest: VoiceRequest?
    @State private var codeResponse: CodeGenerationResponse?
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var showConfigurationAlert = false
    
    enum AppView {
        case dashboard
        case repositorySelection
        case voiceInput
        case codeReview
        case processing
    }
    
    var body: some View {
        Group {
            switch currentView {
            case .dashboard:
                dashboardView
            case .repositorySelection:
                RepositorySelectionView { repository in
                    selectedRepository = repository
                    currentView = .dashboard
                }
            case .voiceInput:
                VoiceInputView { transcription in
                    processVoiceRequest(transcription)
                }
            case .codeReview:
                if let response = codeResponse, let repo = selectedRepository {
                    CodeReviewView(
                        codeResponse: response,
                        repository: repo,
                        onApprove: { approveChanges() },
                        onReject: { rejectChanges() }
                    )
                }
            case .processing:
                processingView
            }
        }
        .onAppear {
            setupServices()
        }
        .onReceive(connectivity.$authToken) { token in
            if let token = token {
                githubClient.setAuthToken(token)
            }
        }
    }
    
    private var dashboardView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("GitHub Voice Assistant")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            
            // Repository status
            if let repository = selectedRepository {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                        Text(repository.name)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Button("Change Repository") {
                        currentView = .repositorySelection
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button("Select Repository") {
                    currentView = .repositorySelection
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
            
            // Main voice button
            Button(action: {
                if selectedRepository != nil {
                    currentView = .voiceInput
                } else {
                    currentView = .repositorySelection
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 30))
                    
                    Text(selectedRepository != nil ? "Start Voice Request" : "Select Repository First")
                        .font(.caption)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(selectedRepository != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(selectedRepository == nil)
            
            Spacer()
            
            // Status message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                Text("Tap the microphone to create code with your voice")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Processing your request...")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let request = currentRequest {
                Text(request.transcription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func setupServices() {
        if let token = connectivity.authToken {
            githubClient.setAuthToken(token)
        }
    }
    
    private func processVoiceRequest(_ transcription: String) {
        guard let repository = selectedRepository else {
            errorMessage = "No repository selected"
            return
        }
        
        currentRequest = VoiceRequest(transcription: transcription, repositoryId: repository.id)
        currentView = .processing
        errorMessage = nil
        
        Task {
            do {
                let response = try await llmService.processVoiceRequest(transcription, repository: repository)
                await MainActor.run {
                    self.codeResponse = response
                    self.currentView = .codeReview
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.currentView = .dashboard
                }
            }
        }
    }
    
    private func approveChanges() {
        guard let response = codeResponse,
              let repository = selectedRepository else {
            return
        }
        
        currentView = .processing
        
        Task {
            do {
                _ = try await githubClient.commitMultipleFiles(
                    repository: repository,
                    files: response.files,
                    message: response.commitMessage
                )
                
                await MainActor.run {
                    self.codeResponse = nil
                    self.currentRequest = nil
                    self.currentView = .dashboard
                    // Could show success message here
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.currentView = .dashboard
                }
            }
        }
    }
    
    private func rejectChanges() {
        codeResponse = nil
        currentRequest = nil
        currentView = .dashboard
    }
}

#Preview {
    MainDashboardView()
}
