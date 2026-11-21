import SwiftUI
import WatchConnectivity

@main
struct PadelScoreBoardApp: App {
    let connectivity = ConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}
