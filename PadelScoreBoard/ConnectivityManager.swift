import Foundation
import WatchConnectivity
import Combine

class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    static let shared = ConnectivityManager()
    
    @Published var play: Play = Play()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendTextMessage(_ data: [String: Any]) {
        if WCSession.default.activationState == .activated {
            WCSession.default.sendMessage(
                data,
                replyHandler: { reply in
                    print("Got reply: \(reply)")
                },
                errorHandler: { error in
                    print("Error: \(error.localizedDescription)")
                }
            )
        }
    }
    
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Task { @MainActor in
            if let data = message["score"] as? Data {
                let play = try? JSONDecoder().decode(Play.self, from: data)
                self.play = play ?? Play()
                
                ScoreAnnouncer.shared.announce(self.play.scoreAnnounce())
            }
        }
        
        replyHandler(["status": "received"])
    }
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?) {
            DispatchQueue.main.async {
                print("Session activated. Reachable: \(session.isReachable)")
            }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            print("Session reachability changed. Reachable: \(session.isReachable)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}

