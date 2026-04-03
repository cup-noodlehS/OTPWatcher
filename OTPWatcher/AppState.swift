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
        pollingTask = Task.detached { [weak self] in
            while let self = self, await self.isMonitoring {
                let messages = AppleMailBridge.fetchUnreadMessages()
                await self.process(messages: messages)
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    @MainActor
    private func process(messages: [EmailMessage]) {
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
