import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image("MenuBarIcon")
                    .resizable()
                    .frame(width: 48, height: 48)
                Text("OTPWatcher")
                    .font(.title.bold())
                Text("Automatic OTP code detection from Apple Mail")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider()

            // Setup steps
            VStack(alignment: .leading, spacing: 16) {
                Text("Setup")
                    .font(.headline)

                SetupRow(
                    icon: "envelope.fill",
                    color: .blue,
                    title: "Open Apple Mail",
                    description: "OTPWatcher reads emails from Apple Mail. Keep it running in the background."
                )

                SetupRow(
                    icon: "bell.badge.fill",
                    color: .orange,
                    title: "Allow Notifications",
                    description: "You'll get a notification with your code when an OTP email arrives."
                )

                SetupRow(
                    icon: "lock.shield.fill",
                    color: .green,
                    title: "Allow Automation",
                    description: "Grant permission for OTPWatcher to read Mail when prompted by macOS."
                )
            }
            .padding(20)

            Divider()

            // How it works
            VStack(alignment: .leading, spacing: 16) {
                Text("How It Works")
                    .font(.headline)

                SetupRow(
                    icon: "magnifyingglass",
                    color: .purple,
                    title: "Detects OTP Emails",
                    description: "Scans new emails for verification codes using keyword matching."
                )

                SetupRow(
                    icon: "doc.on.clipboard",
                    color: .indigo,
                    title: "Copy with One Click",
                    description: "Click the notification or the menu bar to copy the code to your clipboard."
                )

                SetupRow(
                    icon: "desktopcomputer",
                    color: .gray,
                    title: "100% Local",
                    description: "Everything runs on your Mac. No data is sent anywhere."
                )
            }
            .padding(20)

            Spacer()

            Button("Get Started") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 24)
        }
        .frame(width: 400, height: 580)
    }
}

struct SetupRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
