# Ticket 02 — Apple Mail Bridge

## Summary

Build `AppleMailBridge.swift` that uses AppleScript via `NSAppleScript` to fetch recent unread messages from Apple Mail's inbox.

## Tasks

- [ ] Create `AppleMailBridge.swift`
- [ ] Write an AppleScript that queries Apple Mail inbox for unread messages (limit to last 10-20)
- [ ] For each message, extract: message ID, subject, sender, plain text content, date received
- [ ] Execute the AppleScript from Swift using `NSAppleScript`
- [ ] Parse the AppleScript result into `[EmailMessage]`
- [ ] Run the AppleScript call on a background thread (not main)
- [ ] Handle errors gracefully: if Mail isn't running or permission denied, return empty array and log to console

## AppleScript reference

```applescript
tell application "Mail"
    set msgs to (messages 1 through 20 of inbox whose read status is false)
    repeat with m in msgs
        set msgId to id of m
        set msgSubject to subject of m
        set msgSender to sender of m
        set msgContent to content of m
        set msgDate to date received of m
    end repeat
end tell
```

## Notes

- macOS will prompt the user for Automation permission on first run — this is expected
- If Mail.app is not open, the AppleScript will fail — catch this and skip silently
- The app may need to run outside the sandbox for V1 (or with `com.apple.security.scripting-targets` entitlement)
- Date parsing: AppleScript returns dates in the system locale format; parse carefully

## Acceptance criteria

- Calling `AppleMailBridge.fetchUnreadMessages()` returns `[EmailMessage]` from Apple Mail
- Works when Mail is open with unread messages
- Returns empty array (no crash) when Mail is closed
