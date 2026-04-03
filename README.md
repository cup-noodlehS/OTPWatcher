<p align="center">
  <img src="images/otpwatcher-icon.svg" width="128" height="128" alt="OTPWatcher icon">
</p>

<h1 align="center">OTPWatcher</h1>

<p align="center">
  A lightweight macOS menu bar app that detects OTP codes from Apple Mail and copies them to your clipboard with one click.
</p>

<p align="center">
  Everything runs locally. No cloud. No LLM. No tracking.
</p>

---

## Demo



https://github.com/user-attachments/assets/7222f802-83a3-4350-b73a-f7ad55c552c1



---

## How it works

1. OTPWatcher sits in your menu bar and polls Apple Mail every few seconds
2. When a new email arrives that looks like a verification code (e.g. "Your code is 482913"), it extracts the code
3. A native macOS notification appears with the code and a **Copy Code** button
4. Click the notification or the menu bar to copy the code to your clipboard

## Requirements

- macOS 14 (Sonoma) or later
- Apple Mail configured with at least one email account
- Xcode 15+ (to build from source)

## Install

### Download

Download the latest `OTPWatcher.zip` from [Releases](https://github.com/cup-noodlehS/OTPWatcher/releases).

Unzip and drag `OTPWatcher.app` to your Applications folder. Since the app is unsigned, right-click it and select **Open** on first launch, then click **Open** in the dialog.

### Build from source

```bash
git clone https://github.com/cup-noodlehS/OTPWatcher.git
cd OTPWatcher
make build
make run
```

## Permissions

On first launch, macOS will ask for two permissions:

1. **Notifications** — to show OTP code alerts
2. **Automation (Mail)** — to read emails from Apple Mail

Both are required. Go to **System Settings > Privacy & Security > Automation** to manage.

## Detection

OTPWatcher uses keyword matching + regex to detect OTP emails. It looks for terms like:

- "verification code", "security code", "OTP", "login code", "passcode", etc.

Then extracts 4-8 digit (or alphanumeric) codes from the email subject and body.

**Supported formats:**
- `Your verification code is 482913`
- `OTP: 654321`
- `Code: AB12CD`
- `Account verification code:\n13606710`

**Filtered out:**
- Years (2024, 2025)
- Phone numbers
- Numbers near "unsubscribe" / footer text

## Privacy

- All processing happens locally on your Mac
- No data is sent anywhere
- Email bodies are read in memory and never stored
- Only the extracted code is kept (in memory, cleared on quit)

## Development

```bash
make build    # Build debug
make run      # Build and launch
make test     # Run unit tests
make release  # Build release
make zip      # Build release and create OTPWatcher.zip
make clean    # Remove build artifacts
```

### Project structure

```
OTPWatcher/
  OTPWatcherApp.swift       # App entry point, MenuBarExtra
  AppState.swift            # Polling loop, state management
  MenuBarView.swift         # Menu bar dropdown UI
  AppleMailBridge.swift     # AppleScript integration with Mail.app
  OTPDetector.swift         # Keyword screening + regex extraction
  NotificationManager.swift # Native notifications + Copy Code action
  ClipboardManager.swift    # NSPasteboard clipboard access
  Models.swift              # EmailMessage, DetectedCode
```

## License

[MIT](LICENSE)
