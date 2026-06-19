import SwiftUI

private struct OnboardingSlide: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let message: String
}

private let onboardingSlides: [OnboardingSlide] = [
    OnboardingSlide(
        systemImage: "lock.shield",
        title: "Decentralized & Private",
        message: "Your identity lives on the XMTP network. No phone number, no email, no password."
    ),
    OnboardingSlide(
        systemImage: "qrcode.viewfinder",
        title: "Add Contacts by QR Code",
        message: "Share your QR code or scan a friend's to start chatting instantly."
    ),
    OnboardingSlide(
        systemImage: "person.3.fill",
        title: "Group Chats",
        message: "Create groups, customize names, announcements, and nicknames."
    ),
    OnboardingSlide(
        systemImage: "photo.on.rectangle.angled",
        title: "Rich Messaging",
        message: "Send text, photos, and voice messages, all end-to-end encrypted."
    )
]

struct OnboardingView: View {
    @StateObject private var viewModel = AppDI.shared.makeOnboardingViewModel()
    @State private var pageIndex = 0
    var onFinished: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $pageIndex) {
                ForEach(Array(onboardingSlides.enumerated()), id: \.element.id) { index, slide in
                    slideView(slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)

            Button(pageIndex == onboardingSlides.count - 1 ? "Get Started" : "Next") {
                if pageIndex == onboardingSlides.count - 1 {
                    finish()
                } else {
                    withAnimation { pageIndex += 1 }
                }
            }
            .buttonStyle(.pressable)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandPrimary, in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            Button("Skip") {
                finish()
            }
            .buttonStyle(.pressable)
            .font(.system(size: 15))
            .foregroundStyle(Color.textSecondary)
            .padding(.vertical, 16)
        }
        .background(Color.cardBackground.ignoresSafeArea())
    }

    private func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: slide.systemImage)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.brandPrimary)
            Text(slide.title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            Text(slide.message)
                .font(.system(size: 15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
    }

    private func finish() {
        viewModel.completeOnboarding()
        onFinished()
    }
}

#Preview {
    OnboardingView()
}
