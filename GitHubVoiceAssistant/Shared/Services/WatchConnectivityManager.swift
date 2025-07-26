import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isReachable = false
    @Published var authToken: GitHubToken?
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendAuthToken(_ token: GitHubToken) {
        guard WCSession.default.isReachable else { return }
        
        do {
            let data = try JSONEncoder().encode(token)
            let message = ["authToken": data]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Failed to send auth token: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to encode auth token: \(error.localizedDescription)")
        }
    }
    
    func requestAuthentication() {
        guard WCSession.default.isReachable else { return }
        
        let message = ["action": "authenticate"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to request authentication: \(error.localizedDescription)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let tokenData = message["authToken"] as? Data {
            do {
                let token = try JSONDecoder().decode(GitHubToken.self, from: tokenData)
                DispatchQueue.main.async {
                    self.authToken = token
                }
            } catch {
                print("Failed to decode auth token: \(error.localizedDescription)")
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}