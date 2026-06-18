import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: LoadingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(Color.brandPrimary)

            Text("Velochat")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 16)

            Text("Decentralized Messaging")
                .font(.system(size: 13))
                .foregroundStyle(Color.textSecondary)
                .padding(.top, 4)

            Spacer()

            statusView
                .frame(minHeight: 80)
                .animation(.easeInOut(duration: 0.25))

            Spacer().frame(height: 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cardBackground.ignoresSafeArea())
        .task {
            viewModel.didLoad()
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch viewModel.viewState {
        case .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Color.brandPrimary)
                Text("Initializing decentralized network...")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textSecondary)
            }
            .transition(.opacity)
        case .ready(let identity):
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.green)
                Text("Ready")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(identity.inboxId)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color.textTertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.horizontal, 32)
            }
            .transition(.opacity)
        case .error(let message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.red)
                Text("Initialization Failed")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Retry") {
                    viewModel.didLoad()
                }
                .buttonStyle(.pressable)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
                .background(Color.brandPrimary, in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 4)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    LoadingView(viewModel: AppDI.shared.makeLoadingViewModel())
}
