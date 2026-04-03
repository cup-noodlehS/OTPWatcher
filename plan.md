# OTPWatcher — V1 Plan

A macOS menu bar app that detects OTP codes from Apple Mail and copies them to your clipboard.

---

## Goal

Detect incoming OTP/verification-code emails in Apple Mail, extract the code, show a notification, and let the user copy it with one click. Everything local, no cloud, no LLM.

---

## Stack

- **Swift 5.9+** / **macOS 14+**
- **SwiftUI** — menu bar UI
- **NSAppleScript** — query Apple Mail
- **UserNotifications** — native notifications with actions
- **AppKit / NSPasteboard** — clipboard

---

## V1 scope — what we're building

### In scope

1. **Menu bar app** — lives in the menu bar, no dock icon
2. **Apple Mail polling** — check for new messages every 5 seconds via AppleScript
3. **OTP detection** — keyword match on subject/body to identify OTP emails
4. **Code extraction** — regex to pull the code from the email text
5. **Notification** — native macOS notification showing the code, with a "Copy Code" action
6. **Clipboard** — copy code to clipboard on notification action or from menu bar
7. **Duplicate prevention** — track seen message IDs in memory so we never notify twice
8. **Ignore old mail on startup** — only process messages arriving after the app starts

### Out of scope (later versions)

- Settings window / preferences UI
- History view / recent codes list
- Sender allowlist / blocklist
- Confidence scoring / candidate ranking
- Launch at login
- IMAP / direct provider support
- Auto-copy without user action
- Sound / silent mode
- Persistent storage

---

## Architecture

Simple flat structure. No over-abstraction.

```
OTPWatcher/
  OTPWatcherApp.swift          — app entry point, menu bar setup
  AppState.swift               — shared observable state
  MenuBarView.swift            — menu bar popover/menu
  AppleMailBridge.swift         — AppleScript integration to read Mail
  OTPDetector.swift            — keyword matching + code extraction
  NotificationManager.swift    — send notifications, handle actions
  ClipboardManager.swift       — write to clipboard
  Models.swift                 — EmailMessage, DetectedCode structs
```

---

## Core flow

```
Timer fires (every 5s)
 → AppleMailBridge fetches recent inbox messages (last 10 unread)
 → filter out already-seen message IDs
 → for each new message:
     → OTPDetector.detect(subject, body)
       → keyword screen: does it contain OTP-related terms?
       → if yes: regex extract code from subject first, then body
       → if code found: return DetectedCode
     → if code detected:
         → save message ID to seen set
         → save as last detected code in AppState
         → send notification via NotificationManager
         → on "Copy Code" action → ClipboardManager.copy(code)
```

---

## Email access — Apple Mail via AppleScript

Query Apple Mail inbox for recent unread messages. Extract:

- message ID (for dedup)
- subject
- sender
- content (plain text body)
- date received

**AppleScript approach:**

```applescript
tell application "Mail"
  set msgs to (messages of inbox whose read status is false)
  -- for each: get id, subject, sender, content, date received
end tell
```

Called from Swift via `NSAppleScript`. Poll every 5 seconds. Only process messages with `date received` after app launch time.

**Permissions required:** user must grant Automation permission for the app to control Mail.app.

---

## OTP detection logic

### Step 1: Keyword screen

Check if subject or body (case-insensitive) contains any of:

- `verification code`
- `security code`
- `one-time`
- `otp`
- `login code`
- `sign-in code`
- `sign in code`
- `authentication code`
- `confirm your`
- `verify your`
- `use this code`
- `enter this code`
- `your code is`
- `your code:`
- `use code`
- `passcode`

If no keyword match → skip this email.

### Step 2: Code extraction

Run regex patterns against the email text. Try in order:

1. **Code near keyword phrase** — look for patterns like `code is 123456`, `code: 123456`, `OTP: 123456`
   - Regex: `(?:code|otp|password|passcode)[\s:is]+([0-9]{4,8})`
2. **Standalone prominent code** — a 4-8 digit number on its own line or visually separated
   - Regex: `\b([0-9]{4,8})\b`
3. **Alphanumeric code** (if needed) — mixed letters+digits, 4-8 chars
   - Regex: `\b([A-Z0-9]{4,8})\b` (only if it contains both letters and digits)

Take the **first match from pattern 1**. If no match, fall back to pattern 2 with basic filtering (skip numbers that look like years, phone numbers, or zip codes).

No scoring system for V1 — just ordered regex priority.

### False positive filters

Skip candidates that match:
- 4-digit numbers that look like years: `19xx`, `20xx`
- Numbers with 10+ digits (phone numbers)
- Numbers appearing in unsubscribe/footer context

---

## Notification behavior

**Title:** `Verification code received`
**Subtitle:** sender name or email
**Body:** the extracted code (e.g., `482913`)
**Actions:** `Copy Code` button

When user clicks "Copy Code" → copy to clipboard.
When user clicks the notification body → also copy to clipboard.

Category registered at app launch with `UNNotificationCategory`.

---

## Menu bar UI

**Icon:** a small key or shield icon (SF Symbol: `key.fill` or `lock.shield`)

**Menu items:**
- Last code: `482913` (click to copy)
- Separator
- Status: `Monitoring` / `No codes detected yet`
- Separator
- Quit OTPWatcher

That's it. No settings, no history list for V1.

---

## Duplicate prevention

In-memory `Set<String>` of seen message IDs. Reset when app restarts (acceptable for V1).

On startup, record current timestamp. Only process messages with `date received >= launchTime`.

---

## Permissions & onboarding

The app needs:

1. **Notification permission** — request on first launch via `UNUserNotificationCenter.requestAuthorization`
2. **Automation permission** — macOS will prompt when the app first tries to run AppleScript against Mail.app

For V1, no onboarding UI. The OS handles the permission dialogs. If Apple Mail isn't running, log a warning to console.

---

## Key implementation notes

- **No dock icon:** Set `LSUIElement = true` in Info.plist (or use `Application is agent` = YES)
- **Timer:** Use `Timer.scheduledTimer` or `Task.sleep` in an async loop for polling
- **AppleScript errors:** Wrap in do/catch. If Mail isn't open, silently skip the poll cycle
- **Thread safety:** AppleScript calls should run on a background thread; UI updates on main
- **App sandbox:** AppleScript-based Mail access may require running outside the sandbox or with a temporary exception entitlement. For V1 development, run unsigned/unsandboxed

---

## What success looks like

The app runs in the menu bar. You receive an OTP email in Apple Mail. Within ~5 seconds, a notification appears showing the code. You click "Copy Code", and it's on your clipboard. Done.
