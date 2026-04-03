import Foundation
import SwiftUI

@Observable
final class AppState {

    var lastDetectedCode: DetectedCode?
    var isMonitoring = true

    private var seenMessageIDs = Set<String>()
    private var pollingTask: Task<Void, Never>?
    private var hasRunInitialScan = false

    init() {
        NotificationManager.shared.setup()
        startPolling()
    }

    private func startPolling() {
        pollingTask = Task { @MainActor [weak self] in
            while let self = self, self.isMonitoring {
                self.poll()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    /// Runs on main thread (NSAppleScript requirement).
    @MainActor
    private func poll() {
        let messages = AppleMailBridge.fetchUnreadMessages()

        // First poll: seed seen IDs silently to ignore pre-existing unread mail
        if !hasRunInitialScan {
            for message in messages {
                seenMessageIDs.insert(message.id)
            }
            hasRunInitialScan = true
            return
        }

        for message in messages {
            guard !seenMessageIDs.contains(message.id) else { continue }
            seenMessageIDs.insert(message.id)

            if let detected = OTPDetector.detect(message: message) {
                lastDetectedCode = detected
                NotificationManager.shared.sendNotification(
                    code: detected.code,
                    sender: detected.sender
                )
            }
        }
    }
}
