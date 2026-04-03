import Foundation

struct AppleMailBridge {

    /// Fetches recent unread messages from Apple Mail via AppleScript.
    /// Must be called from the main thread (NSAppleScript requirement).
    /// Returns empty array if Mail is not running or on any error.
    static func fetchUnreadMessages() -> [EmailMessage] {
        let scriptSource = """
        if application "Mail" is not running then
            return {}
        end if
        tell application "Mail"
            set results to {}
            try
                set allMsgs to (every message of inbox whose read status is false)
                set msgCount to count of allMsgs
                if msgCount > 20 then set msgCount to 20
                repeat with i from 1 to msgCount
                    set m to item i of allMsgs
                    try
                        set msgContent to content of m
                    on error
                        set msgContent to ""
                    end try
                    set end of results to {(id of m) as string, subject of m, sender of m, msgContent}
                end repeat
            end try
            return results
        end tell
        """

        guard let script = NSAppleScript(source: scriptSource) else {
            print("[AppleMailBridge] Failed to create AppleScript")
            return []
        }

        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)

        if let error = error {
            print("[AppleMailBridge] AppleScript error: \(error)")
            return []
        }

        let count = result.numberOfItems
        guard count > 0 else { return [] }

        var messages: [EmailMessage] = []

        for i in 1...count {
            guard let record = result.atIndex(i) else { continue }
            let id = record.atIndex(1)?.stringValue ?? ""
            let subject = record.atIndex(2)?.stringValue ?? ""
            let sender = record.atIndex(3)?.stringValue ?? ""
            let body = record.atIndex(4)?.stringValue ?? ""

            guard !id.isEmpty else { continue }

            messages.append(EmailMessage(
                id: id,
                subject: subject,
                sender: sender,
                body: body,
                dateReceived: Date()
            ))
        }

        return messages
    }
}
