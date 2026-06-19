import SwiftUI

private struct GuideSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

private let guideSections: [GuideSection] = [
    GuideSection(
        title: "Decentralized Identity",
        body: "Velochat has no accounts and no login. On first launch, a unique XMTP identity (inbox ID and wallet address) is generated automatically and stored securely in your device's Keychain."
    ),
    GuideSection(
        title: "Adding Contacts",
        body: "Open Me to view your personal QR code, or tap the + menu on the Chats screen to scan a contact's QR code. Scanning a valid code starts a new direct conversation instantly."
    ),
    GuideSection(
        title: "Group Chats",
        body: "Create a group from the + menu by selecting existing contacts and naming the group. Group settings let you edit the name, announcement, and your nickname, and view all members."
    ),
    GuideSection(
        title: "Sending Messages",
        body: "Send text, photos (from your library or camera), and voice messages. Voice playback automatically switches between the earpiece and speaker based on proximity."
    ),
    GuideSection(
        title: "Push Notifications",
        body: "Allow notifications when prompted to receive alerts for new messages. You can manage this anytime from Settings > Notifications."
    ),
    GuideSection(
        title: "Privacy & Security",
        body: "All messages are end-to-end encrypted using the XMTP protocol. No personal data such as a phone number or email is ever collected."
    )
]

struct UsageGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(guideSections) { section in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                        Text(section.body)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .padding()
        }
        .background(Color.cardBackground.ignoresSafeArea())
        .navigationTitle("Usage Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { UsageGuideView() }
}
