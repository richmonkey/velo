import SwiftUI

struct MeView: View {
    @StateObject private var viewModel = AppDI.shared.makeMeViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("我的")
                .task {
                    viewModel.didLoad()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
        case .loaded(let identity):
            identityView(identity)
        case .error(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    private func identityView(_ identity: XMTPIdentity) -> some View {
        VStack(spacing: 20) {
            Text("让对方扫描这个二维码即可添加你")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let qrImage = QRCodeGenerator.generate(from: identity.inboxId) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 220, height: 220)
            }

            Text(identity.inboxId)
                .font(.system(.footnote, design: .monospaced))
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    MeView()
}
