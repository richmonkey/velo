import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: LoadingViewModel

    var body: some View {
        VStack(spacing: 16) {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .tint(Color.brandPrimary)
                Text("Initializing XMTP...")
                    .foregroundStyle(Color.textSecondary)
            case .ready(let identity):
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("XMTP Ready")
                    .foregroundStyle(Color.textPrimary)
                Text(identity.inboxId)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            case .error(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text("Initialization Failed")
                    .foregroundStyle(Color.textPrimary)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground.ignoresSafeArea())
        .task {
            viewModel.didLoad()
        }
    }
}

#Preview {
    LoadingView(viewModel: AppDI.shared.makeLoadingViewModel())
}
