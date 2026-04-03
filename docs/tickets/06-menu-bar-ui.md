# Ticket 06 — Menu Bar UI

## Summary

Build `MenuBarView.swift` — the menu that appears when the user clicks the menu bar icon. Minimal: show last code, copy it, show status, quit.

## Tasks

- [ ] Create `MenuBarView.swift`
- [ ] Wire it into `OTPWatcherApp.swift` using `MenuBarExtra`
- [ ] Use an SF Symbol for the icon: `lock.shield` or `key.fill`
- [ ] Display menu items:

### Menu structure

```
┌──────────────────────────┐
│ 482913            [Copy] │   ← last detected code (or "No codes yet")
│──────────────────────────│
│ ● Monitoring             │   ← status indicator
│──────────────────────────│
│ Quit OTPWatcher          │
└──────────────────────────┘
```

- [ ] **Last code row:** Show `lastDetectedCode.code` if available, otherwise "No codes detected yet". Clicking copies the code to clipboard.
- [ ] **Status row:** Show "Monitoring" when `isMonitoring` is true. Non-interactive.
- [ ] **Quit:** Calls `NSApplication.shared.terminate(nil)`

## Notes

- `MenuBarExtra` with `isInserted` binding keeps the icon in the menu bar
- Use `MenuBarExtra("OTPWatcher", systemImage: "lock.shield")` for the icon
- The menu reads from `AppState.lastDetectedCode` — this is an `@Observable`/`@ObservedObject` binding
- When the user copies from the menu, show the code briefly changing to "Copied!" for feedback (optional, nice-to-have)

## Acceptance criteria

- Menu bar icon is visible when app is running
- Clicking icon shows the dropdown menu
- If a code has been detected, it's shown and clickable to copy
- If no code yet, shows "No codes detected yet" (disabled)
- "Quit OTPWatcher" terminates the app
