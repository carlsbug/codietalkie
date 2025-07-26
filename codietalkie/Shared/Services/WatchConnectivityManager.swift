import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var authToken: String?
    @Published var githubUsername: String?
    @Published var isConnected = false
    @Published var isReachable = false
    @Published var repositories: [String] = []
    
    private override init() {
        super.init()
        
        #if canImport(WatchConnectivity)
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("WatchConnectivity: Session activation started")
        } else {
            print("WatchConnectivity: Not supported on this device")
        }
        #endif
    }
    
    // MARK: - iPhone Methods
    
    func sendTokenToWatch(_ token: String, username: String) {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated else {
            print("WatchConnectivity: Session not activated, cannot send token")
            return
        }
        
        let message = [
            "action": "tokenUpdate",
            "token": token,
            "username": username
        ]
        
        print("WatchConnectivity: Sending token to Watch...")
        print("WatchConnectivity: Token prefix: \(String(token.prefix(10)))...")
        print("WatchConnectivity: Username: \(username)")
        print("WatchConnectivity: Session reachable: \(WCSession.default.isReachable)")
        
        // Try immediate message first (if Watch is reachable)
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                print("WatchConnectivity: ✅ Token sent successfully via message")
                print("WatchConnectivity: Watch response: \(response)")
            }) { error in
                print("WatchConnectivity: ❌ Failed to send token via message: \(error)")
                // Fallback to application context
                self.sendTokenViaApplicationContext(token: token, username: username)
            }
        } else {
            print("WatchConnectivity: Watch not reachable, using application context")
            sendTokenViaApplicationContext(token: token, username: username)
        }
        #endif
    }
    
    private func sendTokenViaApplicationContext(token: String, username: String) {
        #if canImport(WatchConnectivity)
        do {
            let context = [
                "token": token,
                "username": username,
                "timestamp": Date().timeIntervalSince1970
            ] as [String: Any]
            
            try WCSession.default.updateApplicationContext(context)
            print("WatchConnectivity: ✅ Token sent via application context")
        } catch {
            print("WatchConnectivity: ❌ Failed to send token via application context: \(error)")
        }
        #endif
    }
    
    func clearTokenFromWatch() {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated else {
            print("WatchConnectivity: Session not activated, cannot clear token")
            return
        }
        
        let message = ["action": "tokenClear"]
        
        print("WatchConnectivity: Clearing token from Watch...")
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { response in
                print("WatchConnectivity: ✅ Token cleared successfully")
            }) { error in
                print("WatchConnectivity: ❌ Failed to clear token: \(error)")
            }
        }
        
        // Also clear via application context
        do {
            try WCSession.default.updateApplicationContext(["token": "", "username": "", "cleared": true])
            print("WatchConnectivity: ✅ Token cleared via application context")
        } catch {
            print("WatchConnectivity: ❌ Failed to clear token via application context: \(error)")
        }
        #endif
    }
    
    // MARK: - Watch Methods
    
    func requestTokenFromiPhone() {
        #if canImport(WatchConnectivity)
        guard WCSession.default.activationState == .activated else {
            print("WatchConnectivity: Session not activated, cannot request token")
            return
        }
        
        guard WCSession.default.isReachable else {
            print("WatchConnectivity: iPhone not reachable, cannot request token")
            return
        }
        
        let message = ["action": "requestToken"]
        
        print("WatchConnectivity: Requesting token from iPhone...")
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let token = response["token"] as? String,
                   let username = response["username"] as? String,
                   !token.isEmpty {
                    print("WatchConnectivity: ✅ Received token from iPhone")
                    print("WatchConnectivity: Token prefix: \(String(token.prefix(10)))...")
                    print("WatchConnectivity: Username: \(username)")
                    
                    self.authToken = token
                    self.githubUsername = username
                    
                    // Store locally on Watch
                    UserDefaults.standard.set(token, forKey: "github_token_watch")
                    UserDefaults.standard.set(username, forKey: "github_username_watch")
                    UserDefaults.standard.synchronize()
                } else {
                    print("WatchConnectivity: ❌ No valid token received from iPhone")
                }
            }
        }) { error in
            print("WatchConnectivity: ❌ Failed to request token from iPhone: \(error)")
        }
        #endif
    }
}

#if canImport(WatchConnectivity)
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
            self.isReachable = session.isReachable
            
            print("WatchConnectivity: Session activated with state: \(activationState.rawValue)")
            if let error = error {
                print("WatchConnectivity: Activation error: \(error)")
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("WatchConnectivity: Reachability changed: \(session.isReachable)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("WatchConnectivity: Received message: \(message)")
        
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "tokenUpdate":
                    if let token = message["token"] as? String,
                       let username = message["username"] as? String {
                        print("WatchConnectivity: Received token update")
                        print("WatchConnectivity: Token prefix: \(String(token.prefix(10)))...")
                        print("WatchConnectivity: Username: \(username)")
                        
                        self.authToken = token
                        self.githubUsername = username
                        
                        // Store locally
                        UserDefaults.standard.set(token, forKey: "github_token_watch")
                        UserDefaults.standard.set(username, forKey: "github_username_watch")
                        UserDefaults.standard.synchronize()
                        
                        replyHandler(["status": "success", "message": "Token received"])
                    } else {
                        replyHandler(["status": "error", "message": "Invalid token data"])
                    }
                    
                case "tokenClear":
                    print("WatchConnectivity: Received token clear request")
                    self.authToken = nil
                    self.githubUsername = nil
                    
                    // Clear local storage
                    UserDefaults.standard.removeObject(forKey: "github_token_watch")
                    UserDefaults.standard.removeObject(forKey: "github_username_watch")
                    UserDefaults.standard.synchronize()
                    
                    replyHandler(["status": "success", "message": "Token cleared"])
                    
                case "requestToken":
                    // iPhone should respond with current token
                    let storedToken = UserDefaults.standard.string(forKey: "github_token_shared") ?? ""
                    let storedUsername = UserDefaults.standard.string(forKey: "github_username_shared") ?? ""
                    
                    replyHandler([
                        "token": storedToken,
                        "username": storedUsername,
                        "status": storedToken.isEmpty ? "no_token" : "success"
                    ])
                    
                default:
                    replyHandler(["status": "error", "message": "Unknown action"])
                }
            } else {
                // Legacy message handling
                if let token = message["token"] as? String {
                    self.authToken = token
                    replyHandler(["status": "success"])
                } else {
                    replyHandler(["status": "error", "message": "No action specified"])
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages without reply handler
        print("WatchConnectivity: Received message (no reply): \(message)")
        
        DispatchQueue.main.async {
            if let token = message["token"] as? String {
                self.authToken = token
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WatchConnectivity: Received application context: \(applicationContext)")
        
        DispatchQueue.main.async {
            if let cleared = applicationContext["cleared"] as? Bool, cleared {
                print("WatchConnectivity: Token cleared via application context")
                self.authToken = nil
                self.githubUsername = nil
                
                // Clear local storage
                UserDefaults.standard.removeObject(forKey: "github_token_watch")
                UserDefaults.standard.removeObject(forKey: "github_username_watch")
                UserDefaults.standard.synchronize()
            } else if let token = applicationContext["token"] as? String,
                      let username = applicationContext["username"] as? String,
                      !token.isEmpty {
                print("WatchConnectivity: Received token via application context")
                print("WatchConnectivity: Token prefix: \(String(token.prefix(10)))...")
                print("WatchConnectivity: Username: \(username)")
                
                self.authToken = token
                self.githubUsername = username
                
                // Store locally
                UserDefaults.standard.set(token, forKey: "github_token_watch")
                UserDefaults.standard.set(username, forKey: "github_username_watch")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WatchConnectivity: Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WatchConnectivity: Session deactivated")
        session.activate()
    }
    #endif
}
#endif
