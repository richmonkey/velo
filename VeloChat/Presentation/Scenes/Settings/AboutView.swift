import SwiftUI

struct AboutView: View {
    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    private var copyrightText: String {
        let year = Calendar.current.component(.year, from: Date())
        return "\u{00A9} \(year) Daibou007 Team. All rights reserved."
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.brandPrimary)
                    .padding(.top, 24)

                Text("Velochat")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(versionText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTertiary)

                Text("Developed by Daibou007 Team")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textSecondary)

                Text("Velochat is a decentralized messaging app built on the XMTP protocol. Every conversation is end-to-end encrypted, with no accounts, no servers holding your identity, and no ads.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("Velochat is powered by the open-source XMTP protocol (xmtp.org) for decentralized, end-to-end encrypted messaging.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)

                Text(copyrightText)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textTertiary)
                    .padding(.top, 8)

                Spacer(minLength: 24)
            }
        }
        .background(Color.cardBackground.ignoresSafeArea())
        .navigationTitle("About Velochat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
