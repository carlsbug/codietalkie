import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var connectivity = WatchConnectivityManager.shared
    @State private var isWaitingForAuth = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("GitHub Voice Assistant")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if isWaitingForAuth {
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("Check your iPhone to complete sign in")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 15) {
                    Text("Sign in with your iPhone to get started")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        requestAuthentication()
                    }) {
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
            }
            
            if !connectivity.isReachable {
                Text("iPhone not reachable")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .onReceive(connectivity.$authToken) { token in
            if token != nil {
                isWaitingForAuth = false
            }
        }
    }
    
    private func requestAuthentication() {
        isWaitingForAuth = true
        coordinator.requestAuthentication()
        
        // Reset waiting state after 30 seconds if no response
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if connectivity.authToken == nil {
                isWaitingForAuth = false
            }
        }
    }
}

#Preview {
    AuthenticationView()
}