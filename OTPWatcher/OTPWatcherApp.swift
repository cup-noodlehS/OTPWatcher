import SwiftUI

@main
struct OTPWatcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("OTPWatcher", image: "MenuBarIcon") {
            MenuBarView(appState: appState)
        }

        Window("Welcome to OTPWatcher", id: "welcome") {
            WelcomeView()
                .onDisappear {
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    NSApp.setActivationPolicy(.accessory)
                }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if !UserDefaults.standard.bool(forKey: "hasSeenWelcome") {
            // Temporarily show in dock so the window can be focused
            NSApp.setActivationPolicy(.regular)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let window = NSApp.windows.first(where: { $0.title.contains("Welcome") }) {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
