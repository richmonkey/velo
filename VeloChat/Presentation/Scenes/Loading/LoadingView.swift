import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: LoadingViewModel

    var body: some View {
        VStack(spacing: 16) {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                Text("正在初始化 XMTP...")
                    .foregroundStyle(.secondary)
            case .ready(let identity):
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                Text("XMTP 已就绪")
                Text(identity.inboxId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case .error(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text("初始化失败")
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .task {
            viewModel.didLoad()
        }
    }
}

#Preview {
    LoadingView(viewModel: AppDI.shared.makeLoadingViewModel())
}
