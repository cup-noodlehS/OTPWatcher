import SwiftUI

struct MenuBarView: View {
    let appState: AppState
    @State private var copiedFeedback = false
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if let detected = appState.lastDetectedCode {
            Button {
                ClipboardManager.copy(detected.code)
                copiedFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    copiedFeedback = false
                }
            } label: {
                Text(copiedFeedback ? "Copied!" : detected.code)
                    .font(.system(.title2, design: .monospaced, weight: .bold))
            }

            Text(detected.sender)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        } else {
            Text("No codes detected yet")
                .foregroundStyle(.secondary)
        }

        Divider()

        HStack {
            Circle()
                .fill(appState.isMonitoring ? .green : .gray)
                .frame(width: 8, height: 8)
            Text(appState.isMonitoring ? "Monitoring" : "Paused")
                .foregroundStyle(.secondary)
        }

        Divider()

        Button("How It Works...") {
            openWindow(id: "welcome")
            NSApp.activate(ignoringOtherApps: true)
        }

        Button("Quit OTPWatcher") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
