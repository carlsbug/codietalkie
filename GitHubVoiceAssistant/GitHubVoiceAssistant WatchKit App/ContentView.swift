import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var selectedRepository: Repository?
    @State private var currentView: AppView = .authentication
    @State private var recentActivities: [ActivityItem] = []
    
    enum AppView {
        case authentication
        case dashboard
        case repositorySelection
        case voiceInput
        case codeReview
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch currentView {
                case .authentication:
                    AuthenticationView(onAuthenticated: {
                        isAuthenticated = true
                        currentView = .dashboard
                    })
                case .dashboard:
                    DashboardView(
                        selectedRepository: selectedRepository,
                        recentActivities: recentActivities,
                        onSelectRepository: { currentView = .repositorySelection },
                        onStartVoiceInput: { currentView = .voiceInput }
                    )
                case .repositorySelection:
                    RepositorySelectionView(onRepositorySelected: { repo in
                        selectedRepository = repo
                        currentView = .dashboard
                    })
                case .voiceInput:
                    VoiceInputView(onTranscriptionComplete: { transcription in
                        // Process voice request and move to code review
                        currentView = .codeReview
                    })
                case .codeReview:
                    CodeReviewView(
                        onApprove: {
                            // Add to activity log and return to dashboard
                            addActivity("Code committed successfully")
                            currentView = .dashboard
                        },
                        onReject: {
                            currentView = .voiceInput
                        }
                    )
                }
            }
        }
    }
    
    private func addActivity(_ description: String) {
        let activity = ActivityItem(
            id: UUID(),
            description: description,
            timestamp: Date(),
            status: .completed
        )
        recentActivities.insert(activity, at: 0)
        if recentActivities.count > 5 {
            recentActivities.removeLast()
        }
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    let onAuthenticated: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 35))
                .foregroundColor(.blue)
            
            Text("GitHub Voice Assistant")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Sign in with your iPhone to get started")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onAuthenticated) {
                HStack {
                    Image(systemName: "iphone")
                    Text("Sign In")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    let selectedRepository: Repository?
    let recentActivities: [ActivityItem]
    let onSelectRepository: () -> Void
    let onStartVoiceInput: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text("GitHub Voice Assistant")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            // Repository Status
            if let repository = selectedRepository {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.green)
                        Text(repository.name)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Button("Change Repo") {
                        onSelectRepository()
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
                .padding(6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button("Select Repository") {
                    onSelectRepository()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .buttonStyle(PlainButtonStyle())
            }
            
            // Main Voice Button
            Button(action: onStartVoiceInput) {
                VStack(spacing: 6) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 25))
                    
                    Text("Voice Request")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(selectedRepository != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(selectedRepository == nil)
            
            // Recent Activities
            if !recentActivities.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(recentActivities.prefix(3)) { activity in
                        HStack {
                            Circle()
                                .fill(activity.status == .completed ? Color.green : Color.orange)
                                .frame(width: 6, height: 6)
                            
                            Text(activity.description)
                                .font(.caption2)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                }
                .padding(6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
    }
}

// MARK: - Repository Selection View
struct RepositorySelectionView: View {
    let onRepositorySelected: (Repository) -> Void
    @State private var repositories: [Repository] = []
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Select Repository")
                .font(.headline)
            
            if repositories.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    
                    Text("Loading repositories...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(repositories) { repo in
                            Button(action: {
                                onRepositorySelected(repo)
                            }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(repo.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(repo.owner.login)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadSampleRepositories()
        }
    }
    
    private func loadSampleRepositories() {
        // Sample repositories for demo
        repositories = [
            Repository(
                id: 1,
                name: "my-project",
                fullName: "user/my-project",
                owner: RepositoryOwner(login: "user", id: 1, avatarUrl: ""),
                defaultBranch: "main",
                isPrivate: false,
                htmlUrl: "",
                cloneUrl: ""
            ),
            Repository(
                id: 2,
                name: "swift-app",
                fullName: "user/swift-app",
                owner: RepositoryOwner(login: "user", id: 1, avatarUrl: ""),
                defaultBranch: "main",
                isPrivate: true,
                htmlUrl: "",
                cloneUrl: ""
            )
        ]
    }
}

// MARK: - Voice Input View
struct VoiceInputView: View {
    let onTranscriptionComplete: (String) -> Void
    @State private var isRecording = false
    @State private var transcription = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Voice Input")
                .font(.headline)
            
            // Recording Indicator
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.blue)
                    .frame(width: 70, height: 70)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
            }
            
            Text(isRecording ? "Listening..." : "Tap to speak")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !transcription.isEmpty {
                Text(transcription)
                    .font(.caption)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
            }
            
            // Control Buttons
            HStack(spacing: 12) {
                Button(isRecording ? "Stop" : "Record") {
                    toggleRecording()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isRecording ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
                .buttonStyle(PlainButtonStyle())
                
                if !transcription.isEmpty {
                    Button("Send") {
                        onTranscriptionComplete(transcription)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if !isRecording && transcription.isEmpty {
            // Simulate transcription
            transcription = "Create a hello world function in Swift"
        }
    }
}

// MARK: - Code Review View
struct CodeReviewView: View {
    let onApprove: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Code Review")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Generated Code:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                        Text("main.swift")
                            .font(.caption)
                        Spacer()
                        Text("CREATE")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    Text("func helloWorld() {\n    print(\"Hello, World!\")\n}")
                        .font(.system(.caption2, design: .monospaced))
                        .padding(6)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(4)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text("Commit: Add hello world function")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Action Buttons
            HStack(spacing: 10) {
                Button("Reject") {
                    onReject()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(15)
                .buttonStyle(PlainButtonStyle())
                
                Button("Approve") {
                    onApprove()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(15)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

// MARK: - Supporting Models
struct ActivityItem: Identifiable {
    let id: UUID
    let description: String
    let timestamp: Date
    let status: ActivityStatus
}

enum ActivityStatus {
    case completed
    case processing
    case failed
}

#Preview {
    ContentView()
}