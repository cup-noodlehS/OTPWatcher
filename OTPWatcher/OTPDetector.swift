import Foundation

struct OTPDetector {

    private static let keywords = [
        "verification code", "security code", "one-time", "otp",
        "login code", "sign-in code", "sign in code", "authentication code",
        "confirm your", "verify your", "use this code", "enter this code",
        "your code is", "your code:", "use code", "passcode",
        "to sign in", "to log in"
    ]

    /// Pattern 1a: code after a keyword phrase (e.g. "code is 482913", "OTP: 654321")
    private static let codeAfterKeywordPattern = try! NSRegularExpression(
        pattern: #"(?:code|otp|password|passcode)[\s:]+(?:is\s+)?(\d{4,8})"#,
        options: .caseInsensitive
    )

    /// Pattern 1b: code before a keyword phrase (e.g. "262383 is your verification code", "Use 128004 to sign in")
    private static let codeBeforeKeywordPattern = try! NSRegularExpression(
        pattern: #"\b(\d{4,8})\b.{0,30}(?:is\s+your\s+(?:verification|security|authentication)\s+code|to\s+(?:sign|log)\s*in|to\s+verify|to\s+confirm)"#,
        options: .caseInsensitive
    )

    /// Pattern 2: standalone 4-8 digit number
    private static let standalonePattern = try! NSRegularExpression(
        pattern: #"\b(\d{4,8})\b"#,
        options: []
    )

    /// Pattern 3: alphanumeric code (must contain both letters and digits)
    private static let alphanumericPattern = try! NSRegularExpression(
        pattern: #"\b([A-Z0-9]{4,8})\b"#,
        options: .caseInsensitive
    )

    static func detect(message: EmailMessage) -> DetectedCode? {
        let text = message.subject + " " + message.body
        let lower = text.lowercased()

        // Stage 1: keyword screening
        let hasKeyword = keywords.contains { lower.contains($0) }
        guard hasKeyword else { return nil }

        // Stage 2: extract code (try patterns in priority order)
        if let code = extractCodeAfterKeyword(text) {
            return DetectedCode(code: code, sender: message.sender, subject: message.subject, detectedAt: Date())
        }
        if let code = extractCodeBeforeKeyword(text) {
            return DetectedCode(code: code, sender: message.sender, subject: message.subject, detectedAt: Date())
        }
        if let code = extractStandalone(text) {
            return DetectedCode(code: code, sender: message.sender, subject: message.subject, detectedAt: Date())
        }
        if let code = extractAlphanumeric(text) {
            return DetectedCode(code: code, sender: message.sender, subject: message.subject, detectedAt: Date())
        }

        return nil
    }

    // MARK: - Extraction

    private static func extractCodeAfterKeyword(_ text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        guard let match = codeAfterKeywordPattern.firstMatch(in: text, range: range),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        let code = String(text[codeRange])
        return isFalsePositive(code, in: text) ? nil : code
    }

    private static func extractCodeBeforeKeyword(_ text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        guard let match = codeBeforeKeywordPattern.firstMatch(in: text, range: range),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        let code = String(text[codeRange])
        return isFalsePositive(code, in: text) ? nil : code
    }

    private static func extractStandalone(_ text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        let matches = standalonePattern.matches(in: text, range: range)
        for match in matches {
            guard let codeRange = Range(match.range(at: 1), in: text) else { continue }
            let code = String(text[codeRange])
            if !isFalsePositive(code, in: text) {
                return code
            }
        }
        return nil
    }

    private static func extractAlphanumeric(_ text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        let matches = alphanumericPattern.matches(in: text, range: range)
        for match in matches {
            guard let codeRange = Range(match.range(at: 1), in: text) else { continue }
            let code = String(text[codeRange])
            let hasLetter = code.contains(where: \.isLetter)
            let hasDigit = code.contains(where: \.isNumber)
            if hasLetter && hasDigit && !isFalsePositive(code, in: text) {
                return code
            }
        }
        return nil
    }

    // MARK: - False positive filters

    private static func isFalsePositive(_ code: String, in text: String) -> Bool {
        // Skip years (19xx, 20xx)
        if code.count == 4, let num = Int(code), (1900...2099).contains(num) {
            return true
        }

        // Skip if candidate appears near footer/address phrases
        let lower = text.lowercased()
        if let codeRange = lower.range(of: code.lowercased()) {
            let start = lower.index(codeRange.lowerBound, offsetBy: -80, limitedBy: lower.startIndex) ?? lower.startIndex
            let end = lower.index(codeRange.upperBound, offsetBy: 80, limitedBy: lower.endIndex) ?? lower.endIndex
            let context = String(lower[start..<end])
            let footerTerms = ["unsubscribe", "privacy policy", "terms of service", "opt out", "copyright",
                               "postal", "zip code", "office address", "mailing address", "p.o. box"]
            if footerTerms.contains(where: { context.contains($0) }) {
                return true
            }
        }

        return false
    }
}
