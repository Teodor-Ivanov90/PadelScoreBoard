import SwiftUI
import WatchConnectivity

@main
struct PadelScoreBoardWatch_Watch_AppApp: App {
    let connectivity = ConnectivityManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivity)
        }
    }
}
