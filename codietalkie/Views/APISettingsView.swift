//
//  APISettingsView.swift
//  codietalkie
//
//  Claude API Settings Screen for iPhone App
//

import SwiftUI
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

struct APISettingsView: View {
    let onBack: () -> Void
    let onConfigured: () -> Void
    let watchConnectivityDelegate: WatchConnectivityDelegate
    
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
                githubStatusView
                
                // Claude API Configuration Section
                claudeAPIConfigView
                
                Spacer()
                
                // Back to Main Button
                backToMainButton
            }
            .padding()
            .navigationTitle("AI Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("← Back") {
                        onBack()
                    }
                }
            }
        }
        .onAppear {
            loadExistingAPIKey()
        }
    }
    
    // MARK: - GitHub Status View
    private var githubStatusView: some View {
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
    }
    
    // MARK: - Claude API Configuration View
    private var claudeAPIConfigView: some View {
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
    }
    
    // MARK: - Back to Main Button
    private var backToMainButton: some View {
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
        
        // Validate with Claude API
        Task {
            do {
                let isValid = try await validateClaudeAPIKey(cleanKey)
                
                DispatchQueue.main.async {
                    self.isValidating = false
                    
                    if isValid {
                        print("iPhone: ✅ Claude API key validated successfully")
                        
                        // Save to Keychain
                        if KeychainManager.saveClaudeAPIKey(cleanKey) {
                            print("iPhone: ✅ Claude API key saved to Keychain")
                            self.isConfigured = true
                            self.errorMessage = nil
                            
                            // Sync to Watch via WatchConnectivity
                            self.syncAPIKeyToWatch(cleanKey)
                            
                        } else {
                            self.errorMessage = "Failed to save API key securely"
                        }
                    } else {
                        self.errorMessage = "Invalid API key. Please check your key and try again."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isValidating = false
                    self.errorMessage = "Validation error: \(error.localizedDescription)"
                    print("iPhone: ❌ Claude API key validation failed: \(error)")
                }
            }
        }
    }
    
    private func validateClaudeAPIKey(_ key: String) async throws -> Bool {
        // Simple validation - try to make a minimal API call
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("codietalkie-iphone-app", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10.0
        
        // Minimal test request
        let testBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 10,
            "messages": [
                [
                    "role": "user",
                    "content": "Hi"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: testBody)
        
        print("iPhone: Making Claude API validation request...")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("iPhone: Claude API validation response status: \(httpResponse.statusCode)")
        
        // 200 = success, 401 = invalid key, 429 = rate limit (but key is valid)
        return httpResponse.statusCode == 200 || httpResponse.statusCode == 429
    }
    
    private func syncAPIKeyToWatch(_ key: String) {
        #if canImport(WatchConnectivity)
        guard WCSession.isSupported() else {
            print("iPhone: WatchConnectivity not supported")
            return
        }
        
        let session = WCSession.default
        guard session.activationState == .activated else {
            print("iPhone: WatchConnectivity session not activated")
            return
        }
        
        let message = [
            "action": "claudeAPIKeyUpdate",
            "apiKey": key
        ]
        
        print("iPhone: Syncing Claude API key to Watch...")
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: { response in
                print("iPhone: ✅ Claude API key synced to Watch successfully")
                print("iPhone: Watch response: \(response)")
            }) { error in
                print("iPhone: ❌ Failed to sync Claude API key to Watch: \(error)")
                // Fallback to application context
                self.syncAPIKeyViaApplicationContext(key)
            }
        } else {
            print("iPhone: Watch not reachable, using application context")
            syncAPIKeyViaApplicationContext(key)
        }
        #endif
    }
    
    private func syncAPIKeyViaApplicationContext(_ key: String) {
        #if canImport(WatchConnectivity)
        do {
            let context = [
                "claudeAPIKey": key,
                "timestamp": Date().timeIntervalSince1970
            ] as [String: Any]
            
            try WCSession.default.updateApplicationContext(context)
            print("iPhone: ✅ Claude API key synced via application context")
        } catch {
            print("iPhone: ❌ Failed to sync Claude API key via application context: \(error)")
        }
        #endif
    }
}

// MARK: - Help Alert
extension APISettingsView {
    private var helpAlert: Alert {
        Alert(
            title: Text("How to get Claude API Key"),
            message: Text("1. Go to console.anthropic.com\n2. Sign up for a free account\n3. Add a payment method (you get $5 free credit)\n4. Go to API Keys section\n5. Create a new key\n6. Copy and paste it here"),
            dismissButton: .default(Text("Got it!"))
        )
    }
}

// Add the alert modifier
extension APISettingsView {
    func withHelpAlert() -> some View {
        self.alert("How to get Claude API Key", isPresented: $showingHelp) {
            Button("Got it!") { }
        } message: {
            Text("1. Go to console.anthropic.com\n2. Sign up for a free account\n3. Add a payment method (you get $5 free credit)\n4. Go to API Keys section\n5. Create a new key\n6. Copy and paste it here")
        }
    }
}
