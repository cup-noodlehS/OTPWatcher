# Ticket 01 — Project Setup & Models

## Summary

Create the Xcode project, configure it as a menu bar agent app (no dock icon), and define the core data models.

## Tasks

- [ ] Create a new macOS SwiftUI project named `OTPWatcher`
- [ ] Set deployment target to macOS 14+
- [ ] Set `LSUIElement = true` in Info.plist so the app has no dock icon
- [ ] Create `OTPWatcherApp.swift` as the entry point using `@main` and `MenuBarExtra`
- [ ] Create `Models.swift` with the following structs:

### Models

```swift
struct EmailMessage {
    let id: String           // Apple Mail message ID
    let subject: String
    let sender: String
    let body: String
    let dateReceived: Date
}

struct DetectedCode {
    let code: String
    let sender: String
    let subject: String
    let detectedAt: Date
}
```

## Acceptance criteria

- App builds and runs on macOS 14+
- App appears in the menu bar (not the dock)
- Models compile and are usable from other files
