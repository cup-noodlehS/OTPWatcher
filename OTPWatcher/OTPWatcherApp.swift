import SwiftUI

@main
struct OTPWatcherApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("OTPWatcher", image: "MenuBarIcon") {
            MenuBarView(appState: appState)
        }
    }
}
