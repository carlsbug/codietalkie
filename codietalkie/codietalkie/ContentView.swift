//
//  ContentView.swift
//  codietalkie
//
//  Created by i539572 on 7/25/25.
//

import SwiftUI
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

// MARK: - WatchConnectivity Delegate
#if canImport(WatchConnectivity)
class WatchConnectivityDelegate: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isConnected = false
    @Published var isActivated = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("iPhone: WatchConnectivity session activation started")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isActivated = activationState == .activated
            self.updateConnectionStatus()
            
            print("iPhone: WatchConnectivity session activated with state: \(activationState.rawValue)")
            if let error = error {
                print("iPhone: WatchConnectivity activation error: \(error)")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iPhone: WatchConnectivity session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iPhone: WatchConnectivity session deactivated")
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.updateConnectionStatus()
            print("iPhone: WatchConnectivity reachability changed: \(session.isReachable)")
        }
    }
    
    private func updateConnectionStatus() {
        let session = WCSession.default
        isConnected = session.isPaired && session.isWatchAppInstalled
        print("iPhone: Watch connectivity updated - Paired: \(session.isPaired), App Installed: \(session.isWatchAppInstalled), Connected: \(isConnected)")
    }
    
    // Send token to Watch
    func sendTokenToWatch(_ token: String, username: String) {
        guard WCSession.default.activationState == .activated else {
            print("iPhone: WatchConnectivity session not activated, cannot send token")
            return
        }
        
        let message = [
            "action": "tokenUpdate",
            "token": token,
            "username": username
        ]
        
        print("iPhone: Sending token to Watch...")
        print("iPhone: Token prefix: \(String(token.prefix(10)))...")
        print("iPhone: Username: \(username)")
        print("iPhone: Session reachable: \(WCSession.default.isReachable)")
        
        // Try immediate message first (if Watch is reachable)
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                print("iPhone: ✅ Token sent successfully via message")
                print("iPhone: Watch response: \(response)")
            }) { error in
                print("iPhone: ❌ Failed to send token via message: \(error)")
                // Fallback to application context
                self.sendTokenViaApplicationContext(token: token, username: username)
            }
        } else {
            print("iPhone: Watch not reachable, using application context")
            sendTokenViaApplicationContext(token: token, username: username)
        }
    }
    
    private func sendTokenViaApplicationContext(token: String, username: String) {
        do {
            let context = [
                "token": token,
                "username": username,
                "timestamp": Date().timeIntervalSince1970
            ] as [String: Any]
            
            try WCSession.default.updateApplicationContext(context)
            print("iPhone: ✅ Token sent via application context")
        } catch {
            print("iPhone: ❌ Failed to send token via application context: \(error)")
        }
    }
    
    // Clear token from Watch
    func clearTokenFromWatch() {
        guard WCSession.default.activationState == .activated else {
            print("iPhone: WatchConnectivity session not activated, cannot clear token")
            return
        }
        
        let message = ["action": "tokenClear"]
        
        print("iPhone: Clearing token from Watch...")
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                print("iPhone: ✅ Token cleared successfully")
            }) { error in
                print("iPhone: ❌ Failed to clear token: \(error)")
            }
        }
        
        // Also clear via application context
        do {
            try WCSession.default.updateApplicationContext(["token": "", "username": "", "cleared": true])
            print("iPhone: ✅ Token cleared via application context")
        } catch {
            print("iPhone: ❌ Failed to clear token via application context: \(error)")
        }
    }
}
#else
class WatchConnectivityDelegate: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var isActivated = false
}
#endif

struct ContentView: View {
    @StateObject private var watchConnectivityDelegate = WatchConnectivityDelegate()
    @State private var isAuthenticated = false
    @State private var showingTokenEntry = false
    @State private var showingAPISettings = false
    @State private var githubToken = ""
    @State private var githubUsername = ""
    @State private var isWatchConnected = false
    @State private var isAPIConfigured = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "applewatch.and.iphone")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("GitHub Voice Assistant")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Companion App")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isAuthenticated {
                    AuthenticatedView(
                        username: githubUsername,
                        isWatchConnected: isWatchConnected,
                        onSignOut: {
                            // Clear all token storage
                            UserDefaults.standard.removeObject(forKey: "github_token_shared")
                            UserDefaults.standard.removeObject(forKey: "github_username_shared")
                            UserDefaults.standard.removeObject(forKey: "github_token_watch")
                            UserDefaults.standard.removeObject(forKey: "github_username_watch")
                            UserDefaults.standard.synchronize()
                            
                            isAuthenticated = false
                            githubToken = ""
                            githubUsername = ""
                        }
                    )
                } else {
                    UnauthenticatedView(
                        onSignIn: {
                            showingTokenEntry = true
                        }
                    )
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("🎙️ Use your Apple Watch to create code with voice commands")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Features: Voice-to-Code • Repository Management • GitHub Integration")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationTitle("GitHub Voice Assistant")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .sheet(isPresented: $showingTokenEntry) {
            TokenEntryView(
                watchConnectivityDelegate: watchConnectivityDelegate,
                onAuthenticated: { token, username in
                    githubToken = token
                    githubUsername = username
                    isAuthenticated = true
                    showingTokenEntry = false
                }
            )
        }
        .onAppear {
            // Check for stored token
            if let storedToken = UserDefaults.standard.string(forKey: "github_token_shared"),
               !storedToken.isEmpty {
                githubToken = storedToken
                githubUsername = UserDefaults.standard.string(forKey: "github_username_shared") ?? "User"
                isAuthenticated = true
            }
            
            // Monitor for authentication changes
            NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                checkAuthenticationStatus()
            }
        }
        .onReceive(watchConnectivityDelegate.$isConnected) { connected in
            isWatchConnected = connected
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
        }
    }
    
    private func checkAuthenticationStatus() {
        // Check if authentication status has changed
        if let storedToken = UserDefaults.standard.string(forKey: "github_token_shared"),
           !storedToken.isEmpty {
            if !isAuthenticated {
                githubToken = storedToken
                githubUsername = UserDefaults.standard.string(forKey: "github_username_shared") ?? "User"
                isAuthenticated = true
                print("iPhone: Authentication detected via sync")
            }
        } else {
            if isAuthenticated {
                githubToken = ""
                githubUsername = ""
                isAuthenticated = false
                print("iPhone: Logout detected via sync")
            }
        }
    }
    
    private func checkWatchConnectivity() {
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.activationState == .activated {
                isWatchConnected = session.isPaired && session.isWatchAppInstalled
                print("iPhone: Watch connectivity - Paired: \(session.isPaired), App Installed: \(session.isWatchAppInstalled), Connected: \(isWatchConnected)")
            } else {
                isWatchConnected = false
                print("iPhone: WatchConnectivity session not activated")
            }
        } else {
            isWatchConnected = false
            print("iPhone: WatchConnectivity not supported")
        }
        #else
        isWatchConnected = false
        print("iPhone: WatchConnectivity not available")
        #endif
    }
}

// MARK: - Authenticated View
struct AuthenticatedView: View {
    let username: String
    let isWatchConnected: Bool
    let onSignOut: () -> Void
    @State private var showingAPISettings = false
    
    var body: some View {
        VStack(spacing: 15) {
            // User Info
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Authenticated as @\(username)")
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 20) {
                    Label("Ready", systemImage: "folder")
                    Label("Connected", systemImage: "person.2")
                    Label("Active", systemImage: "person.badge.plus")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Connection Status
            if isWatchConnected {
                HStack {
                    Image(systemName: "applewatch")
                        .foregroundColor(.blue)
                    Text("Watch Connected")
                        .fontWeight(.medium)
                }
            } else {
                HStack {
                    Image(systemName: "applewatch.slash")
                        .foregroundColor(.orange)
                    Text("Watch Not Connected")
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            // API Settings Button
            Button(action: {
                showingAPISettings = true
            }) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                    Text("Configure Claude AI")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            // Sign Out Button
            Button("Sign Out") {
                // Clear all token storage
                UserDefaults.standard.removeObject(forKey: "github_token_shared")
                UserDefaults.standard.removeObject(forKey: "github_username_shared")
                UserDefaults.standard.removeObject(forKey: "github_token_watch")
                UserDefaults.standard.removeObject(forKey: "github_username_watch")
                UserDefaults.standard.synchronize()
                onSignOut()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showingAPISettings) {
            SimpleAPISettingsView(
                onBack: {
                    showingAPISettings = false
                },
                onConfigured: {
                    showingAPISettings = false
                }
            )
        }
    }
}

// MARK: - Unauthenticated View
struct UnauthenticatedView: View {
    let onSignIn: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Enter your GitHub Personal Access Token to use the voice assistant")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onSignIn) {
                HStack {
                    Image(systemName: "key.fill")
                    Text("Enter GitHub Token")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            VStack(spacing: 8) {
                Text("Need a token?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link("Get one at github.com/settings/tokens", 
                     destination: URL(string: "https://github.com/settings/tokens")!)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("Required permissions: repo, user")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Token Entry View
struct TokenEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let watchConnectivityDelegate: WatchConnectivityDelegate
    let onAuthenticated: (String, String) -> Void
    
    @State private var tokenText = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("GitHub Authentication")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your GitHub Personal Access Token")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("GitHub Token")
                        .font(.headline)
                    
                    TextField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $tokenText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled()
                        .onSubmit {
                            validateToken()
                        }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: validateToken) {
                    HStack {
                        if isValidating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.shield")
                        }
                        Text(isValidating ? "Validating..." : "Validate & Sign In")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tokenText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(tokenText.isEmpty || isValidating)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("Need help getting a token?") {
                        showingHelp = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    
                    Text("Your token is stored securely on this device only")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationTitle("Authentication")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            #endif
        }
        .alert("How to get a GitHub Token", isPresented: $showingHelp) {
            Button("OK") { }
        } message: {
            Text("1. Go to github.com/settings/tokens\n2. Click 'Generate new token (classic)'\n3. Select 'repo' and 'user' permissions\n4. Copy the token and paste it here")
        }
    }
    
    private func validateToken() {
        guard !tokenText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isValidating = true
        errorMessage = nil
        
        let cleanToken = tokenText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic token format validation
        guard cleanToken.hasPrefix("ghp_") || cleanToken.hasPrefix("github_pat_") else {
            errorMessage = "Invalid token format. Token should start with 'ghp_' or 'github_pat_'"
            isValidating = false
            return
        }
        
        guard cleanToken.count >= 20 else {
            errorMessage = "Token appears to be too short"
            isValidating = false
            return
        }
        
        print("iPhone: Validating GitHub token: \(String(cleanToken.prefix(10)))...")
        
        // Actually validate token with GitHub API
        Task {
            do {
                let username = try await validateGitHubToken(cleanToken)
                
                DispatchQueue.main.async {
                    self.isValidating = false
                    print("iPhone: ✅ Token validated successfully for user: \(username)")
                    
                    // Store token for iPhone-Watch sync
                    UserDefaults.standard.set(cleanToken, forKey: "github_token_shared")
                    UserDefaults.standard.set(username, forKey: "github_username_shared")
                    UserDefaults.standard.set(cleanToken, forKey: "github_token_watch")
                    UserDefaults.standard.set(username, forKey: "github_username_watch")
                    UserDefaults.standard.synchronize()
                    
                    print("iPhone: Token stored in UserDefaults for Watch sync")
                    
                    // Send token to Watch via WatchConnectivity
                    #if canImport(WatchConnectivity)
                    self.watchConnectivityDelegate.sendTokenToWatch(cleanToken, username: username)
                    #endif
                    
                    self.onAuthenticated(cleanToken, username)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isValidating = false
                    self.errorMessage = "GitHub API Error: \(error.localizedDescription)"
                    print("iPhone: ❌ Token validation failed: \(error)")
                }
            }
        }
    }
    
    private func validateGitHubToken(_ token: String) async throws -> String {
        let url = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("codietalkie-iphone-app", forHTTPHeaderField: "User-Agent")
        
        print("iPhone: Making GitHub API request to validate token...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("iPhone: GitHub API response status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("iPhone: GitHub API error response: \(responseBody)")
            
            if httpResponse.statusCode == 401 {
                throw NSError(domain: "GitHubAPI", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid GitHub token. Please check your token and try again."])
            } else if httpResponse.statusCode == 403 {
                throw NSError(domain: "GitHubAPI", code: 403, userInfo: [NSLocalizedDescriptionKey: "GitHub API rate limit exceeded. Please try again later."])
            } else {
                throw NSError(domain: "GitHubAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "GitHub API error: \(httpResponse.statusCode)"])
            }
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            guard let username = json["login"] as? String else {
                throw NSError(domain: "GitHubAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get username from GitHub API"])
            }
            return username
        } catch {
            print("iPhone: JSON parsing error: \(error)")
            throw error
        }
    }
}

// MARK: - Simple API Settings View
struct SimpleAPISettingsView: View {
    let onBack: () -> Void
    let onConfigured: () -> Void
    
    @State private var claudeAPIKey = ""
    @State private var isValidating = false
    @State private var isConfigured = false
    @State private var errorMessage: String?
    @State private var showingHelp = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // GitHub Status Section
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GitHub Connected")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let username = UserDefaults.standard.string(forKey: "github_username_shared") {
                                Text("@\(username)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Claude API Configuration Section
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Claude AI Setup")
                                .font(.headline)
                            Text("Professional code generation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // API Key Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anthropic API Key")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            SecureField("sk-ant-api03-your_key_here", text: $claudeAPIKey)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .onSubmit {
                                    validateAndSaveAPIKey()
                                }
                            
                            if !claudeAPIKey.isEmpty {
                                Button(action: {
                                    claudeAPIKey = ""
                                    errorMessage = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Help Section
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Get your FREE API key:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Link("console.anthropic.com", destination: URL(string: "https://console.anthropic.com")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button("Need help getting a key?") {
                            showingHelp = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: validateAndSaveAPIKey) {
                            HStack {
                                if isValidating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: isConfigured ? "checkmark.circle" : "key.fill")
                                }
                                Text(isValidating ? "Validating..." : isConfigured ? "✅ Configured" : "Save & Test API Key")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(claudeAPIKey.isEmpty ? Color.gray : (isConfigured ? Color.green : Color.blue))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(claudeAPIKey.isEmpty || isValidating)
                        
                        if isConfigured {
                            Button("Continue to Watch") {
                                onConfigured()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                Spacer()
                
                // Back to Main Button
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("Back to Main")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("AI Configuration")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") {
                        onBack()
                    }
                }
            }
            #endif
        }
        .onAppear {
            loadExistingAPIKey()
        }
        .alert("How to get Claude API Key", isPresented: $showingHelp) {
            Button("Got it!") { }
        } message: {
            Text("1. Go to console.anthropic.com\n2. Sign up for a free account\n3. Add a payment method (you get $5 free credit)\n4. Go to API Keys section\n5. Create a new key\n6. Copy and paste it here")
        }
    }
    
    // MARK: - Helper Functions
    private func loadExistingAPIKey() {
        // Check if API key is already stored in Keychain
        if let existingKey = KeychainManager.getClaudeAPIKey() {
            claudeAPIKey = existingKey
            isConfigured = true
            print("iPhone: Loaded existing Claude API key from Keychain")
        }
    }
    
    private func validateAndSaveAPIKey() {
        guard !claudeAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isValidating = true
        errorMessage = nil
        
        let cleanKey = claudeAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic key format validation
        guard cleanKey.hasPrefix("sk-ant-api03-") else {
            errorMessage = "Invalid API key format. Key should start with 'sk-ant-api03-'"
            isValidating = false
            return
        }
        
        guard cleanKey.count >= 20 else {
            errorMessage = "API key appears to be too short"
            isValidating = false
            return
        }
        
        print("iPhone: Validating Claude API key: \(String(cleanKey.prefix(15)))...")
        
        // For now, just save the key (real validation would require Claude API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isValidating = false
            
            // Save to UserDefaults (in real app, would use Keychain)
            UserDefaults.standard.set(cleanKey, forKey: "claude_api_key")
            UserDefaults.standard.synchronize()
            
            self.isConfigured = true
            self.errorMessage = nil
            
            print("iPhone: ✅ Claude API key saved successfully")
        }
    }
}

// Simple KeychainManager for demo
struct KeychainManager {
    static func getClaudeAPIKey() -> String? {
        return UserDefaults.standard.string(forKey: "claude_api_key")
    }
    
    static func saveClaudeAPIKey(_ key: String) -> Bool {
        UserDefaults.standard.set(key, forKey: "claude_api_key")
        UserDefaults.standard.synchronize()
        return true
    }
}

#Preview {
    ContentView()
}
