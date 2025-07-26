import SwiftUI

struct RepositorySelectionView: View {
    @StateObject private var githubClient = GitHubAPIClient.shared
    @State private var repositories: [Repository] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingCreateRepo = false
    @State private var newRepoName = ""
    
    let onRepositorySelected: (Repository) -> Void
    let onBackPressed: (() -> Void)?
    
    init(onRepositorySelected: @escaping (Repository) -> Void, onBackPressed: (() -> Void)? = nil) {
        self.onRepositorySelected = onRepositorySelected
        self.onBackPressed = onBackPressed
    }
    
    // MARK: - Back Button Component
    private var backButton: some View {
        HStack {
            if let onBackPressed = onBackPressed {
                Button(action: onBackPressed) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                        Text("Back")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Back button at top
            backButton
            
            HStack {
                Text("Select Repository")
                    .font(.headline)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if isLoading && repositories.isEmpty {
                ProgressView("Loading repositories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if repositories.isEmpty && errorMessage == nil {
                emptyStateView
            } else {
                repositoryList
            }
        }
        .padding()
        .onAppear {
            loadRepositories()
        }
        .alert("Create Repository", isPresented: $showingCreateRepo) {
            TextField("Repository name", text: $newRepoName)
            Button("Create") {
                createRepository()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("No repositories found")
                .font(.headline)
            
            Text("Create a new repository to get started")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Repository") {
                showingCreateRepo = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private var repositoryList: some View {
        VStack {
            // Create new repository button
            Button(action: {
                showingCreateRepo = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Repository")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
            // Repository list
            List(repositories) { repository in
                RepositoryRow(repository: repository) {
                    onRepositorySelected(repository)
                }
            }
            .listStyle(PlainListStyle())
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func loadRepositories() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let repos = try await githubClient.fetchRepositories()
                await MainActor.run {
                    self.repositories = repos
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func createRepository() {
        guard !newRepoName.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let newRepo = try await githubClient.createRepository(
                    name: newRepoName,
                    description: "Created via GitHub Voice Assistant"
                )
                await MainActor.run {
                    self.repositories.insert(newRepo, at: 0)
                    self.newRepoName = ""
                    self.isLoading = false
                    self.onRepositorySelected(newRepo)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct RepositoryRow: View {
    let repository: Repository
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(repository.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if repository.isPrivate {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(repository.owner.login)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RepositorySelectionView { repository in
        print("Selected: \(repository.name)")
    }
}
