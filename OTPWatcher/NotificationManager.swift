import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private static let categoryID = "OTP_CODE"
    private static let copyActionID = "COPY_CODE"
    private static let codeUserInfoKey = "otpCode"

    private override init() {
        super.init()
    }

    /// Call once at app launch to request permission and register actions.
    func setup() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Request permission
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[NotificationManager] Authorization error: \(error)")
            }
            if !granted {
                print("[NotificationManager] Notification permission denied")
            }
        }

        // Register category with "Copy Code" action
        let copyAction = UNNotificationAction(
            identifier: Self.copyActionID,
            title: "Copy Code",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryID,
            actions: [copyAction],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    /// Send a notification showing the detected OTP code.
    func sendNotification(code: String, sender: String) {
        let content = UNMutableNotificationContent()
        content.title = "Verification code received"
        content.subtitle = sender
        content.body = code
        content.sound = .default
        content.categoryIdentifier = Self.categoryID
        content.userInfo = [Self.codeUserInfoKey: code]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to send notification: \(error)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Called when user taps the notification body.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let code = userInfo[Self.codeUserInfoKey] as? String {
            ClipboardManager.copy(code)
            print("[NotificationManager] Copied code: \(code)")
        }
        completionHandler()
    }

    /// Show notifications even when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
