# Ticket 07 — Unit Tests

## Summary

Add unit tests for `OTPDetector`, the core detection and extraction logic. Use sample emails (in `sample_emails/`) and synthetic test cases.

## Tasks

- [ ] Add a test target to the Xcode project
- [ ] Create `OTPDetectorTests.swift`
- [ ] Test keyword screening (positive and negative)
- [ ] Test code extraction patterns (near-keyword, standalone, alphanumeric)
- [ ] Test false positive filtering (years, phone numbers, footer content)
- [ ] Test against real email samples in `sample_emails/`

## Test cases

### Real email samples

#### Microsoft account verification (`Standaardmap account verification code.eml`)

- **Subject:** `Your Standaardmap account verification code`
- **Sender:** `account-security-noreply@accountprotection.microsoft.com`
- **Body contains:**
  ```
  Account verification code:
  13606710
  ```
- **Expected:** code = `"13606710"`
- **Note:** code is on a separate line after "Account verification code:" — regex must match across the newline

### Synthetic positive cases

| Input text | Expected code |
|---|---|
| `Your verification code is 482913` | `482913` |
| `Use 128004 to sign in` | `128004` |
| `OTP: 654321` | `654321` |
| `Security code: AB12CD` | `AB12CD` |
| `Your code: 9921` | `9921` |
| `Enter this code to verify: 55443322` | `55443322` |
| `Your one-time passcode is 773312` | `773312` |

### Synthetic negative cases (should return nil)

| Input text | Why it should be nil |
|---|---|
| `Your order #12345 has shipped` | No OTP keywords |
| `Call us at 1234567890` | No OTP keywords |
| `Meeting scheduled for 2026` | No OTP keywords |
| `Invoice #98765 is ready` | No OTP keywords |
| `Hi, how are you?` | No OTP keywords, no code |

### False positive edge cases

| Input text | Expected |
|---|---|
| `Your verification code is 2024` | `nil` (year) |
| `Use this code ... unsubscribe ... 882211` | `nil` (footer context) |

## Notes

- The sample `.eml` files are raw MIME — tests should extract just the plain text body portion to simulate what Apple Mail's `content of message` returns (plain text, not HTML)
- Add new test cases as more sample emails are collected in `sample_emails/`
- Tests should be runnable via `xcodebuild test`

## Acceptance criteria

- All test cases pass
- Tests cover keyword screening, all 3 extraction patterns, and false positive filtering
- At least one test uses a real email sample
