import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isWatchConnected = false
    
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
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Authenticated with GitHub")
                                .fontWeight(.medium)
                        }
                        
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
                        
                        Button("Sign Out") {
                            isAuthenticated = false
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Sign in to GitHub to use the voice assistant on your Apple Watch")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Simulate authentication for demo
                            isAuthenticated = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                Text("Sign In with GitHub")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Text("Note: This is a demo version. Full authentication requires GitHub OAuth setup.")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
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
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Simulate watch connection check
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isWatchConnected = Bool.random()
            }
        }
    }
}

#Preview {
    ContentView()
}