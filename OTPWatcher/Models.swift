import Foundation

struct EmailMessage {
    let id: String
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
