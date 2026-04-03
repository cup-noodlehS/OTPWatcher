import XCTest
@testable import OTPWatcher

final class OTPDetectorTests: XCTestCase {

    // MARK: - Helpers

    private func makeMessage(subject: String = "", body: String = "", sender: String = "test@example.com") -> EmailMessage {
        EmailMessage(id: UUID().uuidString, subject: subject, sender: sender, body: body, dateReceived: Date())
    }

    // MARK: - Synthetic positive cases

    func testVerificationCode6Digits() {
        let message = makeMessage(subject: "Your verification code is 482913", body: "Your verification code is 482913")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "482913")
    }

    func testSignInCode6Digits() {
        let message = makeMessage(subject: "Use 128004 to sign in", body: "Use 128004 to sign in")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "128004")
    }

    func testOTPColonFormat() {
        let message = makeMessage(subject: "OTP: 654321", body: "OTP: 654321")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "654321")
    }

    func testAlphanumericSecurityCode() {
        let message = makeMessage(subject: "Security code: AB12CD", body: "Security code: AB12CD")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "AB12CD")
    }

    func testYourCode4Digits() {
        let message = makeMessage(subject: "Your code: 9921", body: "Your code: 9921")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "9921")
    }

    func testEnterThisCode8Digits() {
        let message = makeMessage(subject: "Enter this code to verify: 55443322", body: "Enter this code to verify: 55443322")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "55443322")
    }

    func testOneTimePasscode() {
        let message = makeMessage(subject: "Your one-time passcode is 773312", body: "Your one-time passcode is 773312")
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "773312")
    }

    // MARK: - Real email sample (Microsoft verification)

    func testMicrosoftAccountVerification() {
        let subject = "Your Standaardmap account verification code"
        let body = """
            To access Standaardmap's apps and resources, please use the code below for account verification. The code will only work for 30 minutes.

            Account verification code:
            13606710

            If you didn't request a code, you can ignore this email.
            Privacy Statement: https://go.microsoft.com/fwlink/?LinkId=521839
            Microsoft Corporation, One Microsoft Way, Redmond, WA 98052
            """
        let message = makeMessage(
            subject: subject,
            body: body,
            sender: "account-security-noreply@accountprotection.microsoft.com"
        )
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "13606710")
    }

    // MARK: - Negative cases (should return nil)

    func testOrderShippedNoKeywords() {
        let message = makeMessage(subject: "Your order #12345 has shipped", body: "Your order #12345 has shipped")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Order shipment notification should not be detected as OTP")
    }

    func testPhoneNumberNoKeywords() {
        let message = makeMessage(subject: "Call us at 1234567890", body: "Call us at 1234567890")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Phone number should not be detected as OTP")
    }

    func testMeetingDateNoKeywords() {
        let message = makeMessage(subject: "Meeting scheduled for 2026", body: "Meeting scheduled for 2026")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Meeting year should not be detected as OTP")
    }

    func testInvoiceNoKeywords() {
        let message = makeMessage(subject: "Invoice #98765 is ready", body: "Invoice #98765 is ready")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Invoice number should not be detected as OTP")
    }

    func testGenericGreetingNoCode() {
        let message = makeMessage(subject: "Hi, how are you?", body: "Hi, how are you?")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Generic greeting should not be detected as OTP")
    }

    // MARK: - Real email: Temu verification (code in subject before keyword)

    func testTemuVerificationCodeInSubject() {
        let subject = "262383 is your verification code"
        let body = """
            Hi sheldonarthursagrado
            Please verify your email address using the following verification code:
            262383
            It is valid for the next 10 minutes. This is an automatically generated email, please do not reply.
            Thank you
            NOTE: This is an automatically generated email, please do not reply.
            Office address: 6 Raffles Quay, #14-06, Singapore (Postal 048580) Please note, returns will not be accepted at this address.
            If you want to return items, please request a return and use Temu's label.
            """
        let message = makeMessage(
            subject: subject,
            body: body,
            sender: "temu@user.temu.com"
        )
        let result = OTPDetector.detect(message: message)
        XCTAssertEqual(result?.code, "262383", "Should extract 262383, not postal code 048580")
    }

    // MARK: - False positive edge cases

    func testYearFalsePositive() {
        let message = makeMessage(subject: "Your verification code is 2024", body: "Your verification code is 2024")
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Year 2024 should be filtered as a false positive")
    }

    func testUnsubscribeFooterFalsePositive() {
        let message = makeMessage(
            subject: "Use this code",
            body: "Use this code to unsubscribe 882211"
        )
        let result = OTPDetector.detect(message: message)
        XCTAssertNil(result, "Code near 'unsubscribe' should be filtered as a false positive")
    }
}
