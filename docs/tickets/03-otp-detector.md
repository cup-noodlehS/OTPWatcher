# Ticket 03 — OTP Detector

## Summary

Build `OTPDetector.swift` that takes an `EmailMessage` and determines if it's an OTP email, then extracts the code.

## Tasks

- [ ] Create `OTPDetector.swift`
- [ ] Implement keyword screening
- [ ] Implement code extraction via ordered regex patterns
- [ ] Implement basic false positive filters
- [ ] Expose a single entry point: `func detect(message: EmailMessage) -> DetectedCode?`

## Keyword list (case-insensitive)

Check if subject or body contains any of:

```
verification code, security code, one-time, otp, login code,
sign-in code, sign in code, authentication code, confirm your,
verify your, use this code, enter this code, your code is,
your code:, use code, passcode
```

If no keyword matches → return `nil`.

## Code extraction (try in order)

### Pattern 1 — Code near a keyword phrase

```
(?:code|otp|password|passcode)[\s:is]+([0-9]{4,8})
```

Captures: the digit sequence after a keyword like "code is", "OTP:", etc.

### Pattern 2 — Standalone digit code

```
\b([0-9]{4,8})\b
```

Fallback: grab a 4-8 digit number. Apply false positive filters before accepting.

### Pattern 3 — Alphanumeric code (optional)

```
\b([A-Z0-9]{4,8})\b
```

Only accept if it contains both letters and digits.

## False positive filters

Skip candidates that match:
- Looks like a year: `19xx` or `20xx` (where xx are digits)
- 10+ digits (phone number)
- Appears in common footer phrases like "unsubscribe", "privacy policy"

## Logic

```
func detect(message) -> DetectedCode?
  text = message.subject + " " + message.body
  if no keyword match in text → return nil
  if code = extractNearKeyword(text) → return DetectedCode
  if code = extractStandalone(text) → return DetectedCode
  return nil
```

## Acceptance criteria

- `detect("Your verification code is 482913")` → returns `"482913"`
- `detect("Use 128004 to sign in")` → returns `"128004"`
- `detect("OTP: 654321")` → returns `"654321"`
- `detect("Your order #12345 has shipped")` → returns `nil`
- `detect("Call us at 1234567890")` → returns `nil`
