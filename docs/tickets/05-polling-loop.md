# Ticket 05 — Polling Loop & State Management

## Summary

Build `AppState.swift` that ties everything together: polls Apple Mail on a timer, runs detection, sends notifications, and tracks state for the menu bar UI.

## Tasks

- [ ] Create `AppState.swift` as an `@Observable` class (or `ObservableObject`)
- [ ] Store:
  - `lastDetectedCode: DetectedCode?` — most recent code (for menu bar display)
  - `isMonitoring: Bool` — whether polling is active
  - `seenMessageIDs: Set<String>` — in-memory dedup set
  - `launchTime: Date` — set on init, used to ignore old emails
- [ ] On init, start a polling timer (every 5 seconds)
- [ ] Each poll cycle:
  1. Call `AppleMailBridge.fetchUnreadMessages()`
  2. Filter out messages where `dateReceived < launchTime`
  3. Filter out messages where `id` is in `seenMessageIDs`
  4. For each remaining message:
     - Add `id` to `seenMessageIDs`
     - Call `OTPDetector.detect(message:)`
     - If a code is detected:
       - Update `lastDetectedCode`
       - Call `NotificationManager.sendNotification(code:sender:)`
- [ ] Run the AppleMailBridge call off the main thread
- [ ] Update `lastDetectedCode` on the main thread (it drives UI)

## Polling approach

```swift
// Option A: Timer
Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
    Task { await self.poll() }
}

// Option B: Async loop
Task {
    while isMonitoring {
        await poll()
        try? await Task.sleep(for: .seconds(5))
    }
}
```

Either approach works. Async loop is simpler to cancel.

## Notes

- The `seenMessageIDs` set is in-memory only — resets on app restart, which is fine for V1
- `launchTime` prevents notifying about old unread emails when the app first starts
- If `fetchUnreadMessages()` returns an error or empty array, just skip that cycle silently

## Acceptance criteria

- App polls Apple Mail every ~5 seconds while running
- New OTP emails trigger a notification
- The same email never triggers two notifications
- Emails that were unread before the app launched are ignored
- `lastDetectedCode` updates and is readable from the menu bar UI
