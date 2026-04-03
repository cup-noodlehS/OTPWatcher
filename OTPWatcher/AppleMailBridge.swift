import Foundation

struct AppleMailBridge {

    private static let fieldSep = "\u{1E}"  // ASCII Record Separator
    private static let recordSep = "\u{1F}" // ASCII Unit Separator

    /// Fetches recent unread messages from Apple Mail via osascript subprocess.
    /// Returns empty array if Mail is not running or on any error.
    static func fetchUnreadMessages() -> [EmailMessage] {
        let fs = "character id 30"  // field separator in AppleScript
        let rs = "character id 31"  // record separator in AppleScript

        let scriptSource = """
        set fs to \(fs)
        set rs to \(rs)
        if application "Mail" is not running then
            return ""
        end if
        tell application "Mail"
            set output to ""
            repeat with acct in (every account)
                try
                    set acctInbox to mailbox "INBOX" of acct
                    set msgCount to count of messages of acctInbox
                    if msgCount > 10 then set msgCount to 10
                    repeat with i from 1 to msgCount
                        set m to message i of acctInbox
                        if read status of m is false then
                            try
                                set msgContent to content of m
                            on error
                                set msgContent to ""
                            end try
                            set output to output & (id of m as string) & fs & subject of m & fs & sender of m & fs & msgContent & rs
                        end if
                    end repeat
                end try
            end repeat
            return output
        end tell
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", scriptSource]

        let pipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return []
        }

        guard process.terminationStatus == 0 else { return [] }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty else {
            return []
        }

        let records = output.components(separatedBy: recordSep).filter { !$0.isEmpty }
        var messages: [EmailMessage] = []

        for record in records {
            let fields = record.components(separatedBy: fieldSep)
            guard fields.count >= 4 else { continue }

            let id = fields[0]
            guard !id.isEmpty else { continue }

            messages.append(EmailMessage(
                id: id,
                subject: fields[1],
                sender: fields[2],
                body: fields[3],
                dateReceived: Date()
            ))
        }

        return messages
    }
}
