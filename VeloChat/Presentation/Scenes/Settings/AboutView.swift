import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.brandPrimary)
                    .padding(.top, 24)

                Text("VeloChat")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(versionText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textTertiary)

                Text("VeloChat is a decentralized messaging app built on the XMTP protocol. Every conversation is end-to-end encrypted, with no accounts, no servers holding your identity, and no ads.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 0) {
                    linkRow(title: "Privacy Policy", url: AppStoreConfig.privacyPolicyURL)
                    Divider()
                    linkRow(title: "Terms of Service", url: AppStoreConfig.termsOfServiceURL)
                }
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer(minLength: 24)
            }
        }
        .background(Color.cardBackground.ignoresSafeArea())
        .navigationTitle("About VeloChat")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func linkRow(title: String, url: URL) -> some View {
        Button {
            openURL(url)
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(Color.textTertiary)
            }
            .padding()
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
