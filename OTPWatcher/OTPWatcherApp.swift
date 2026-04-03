import SwiftUI

@main
struct OTPWatcherApp: App {
    var body: some Scene {
        MenuBarExtra("OTPWatcher", systemImage: "lock.shield") {
            Text("No codes detected yet")
                .foregroundStyle(.secondary)
            Divider()
            Button("Quit OTPWatcher") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
