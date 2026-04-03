# Ticket 04 — Notifications & Clipboard

## Summary

Build `NotificationManager.swift` and `ClipboardManager.swift`. Handle requesting notification permission, sending notifications with a "Copy Code" action, and copying codes to the clipboard.

## Tasks

### NotificationManager

- [ ] Create `NotificationManager.swift`
- [ ] On app launch, request notification authorization (alert + sound + badge)
- [ ] Register a `UNNotificationCategory` with a "Copy Code" action (`copyCode` identifier)
- [ ] Implement `sendNotification(code:sender:)` that posts a local notification:
  - Title: `Verification code received`
  - Subtitle: sender name/email
  - Body: the code string
  - Category: the registered category with "Copy Code" action
  - `userInfo`: include the code string so it can be read back in the action handler
- [ ] Set up `UNUserNotificationCenterDelegate` to handle:
  - User taps "Copy Code" → copy code to clipboard
  - User taps the notification body → also copy code to clipboard

### ClipboardManager

- [ ] Create `ClipboardManager.swift`
- [ ] Implement `static func copy(_ string: String)` using `NSPasteboard.general`
  - Clear contents, set string

## Notification format

```
┌─────────────────────────────┐
│ Verification code received  │
│ noreply@github.com          │
│ 482913                      │
│                [Copy Code]  │
└─────────────────────────────┘
```

## Notes

- The delegate must be set early (in app init or `applicationDidFinishLaunching`) to catch actions
- `UNUserNotificationCenter.current().delegate = self` must be on the main thread
- For the notification body, just show the raw code — no extra text

## Acceptance criteria

- App requests notification permission on first launch
- When `sendNotification(code: "482913", sender: "noreply@github.com")` is called, a notification appears
- Clicking "Copy Code" copies `482913` to the system clipboard
- Clicking the notification body also copies the code
