import SwiftUI

private struct QRScannerRepresentable: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onCodeScanned = onCodeScanned
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

struct ScanView: View {
    @StateObject private var viewModel = AppDI.shared.makeScanViewModel()
    @Environment(\.dismiss) private var dismiss

    /// Called once a conversation has been created, so the presenting
    /// Home screen can refresh its list before this sheet is dismissed.
    var onConversationCreated: (String) -> Void = { _ in }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                QRScannerRepresentable { code in
                    viewModel.submit(peerInboxId: code)
                }
                .ignoresSafeArea()

                viewfinder

                VStack {
                    Spacer()
                    statusMessage
                    Spacer().frame(height: 72)
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .onChange(of: viewModel.viewState) { newValue in
                if case .success(let conversation) = newValue {
                    onConversationCreated(conversation.id)
                    dismiss()
                }
            }
        }
    }

    private var viewfinder: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height) * 0.65
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(Color.accentHighlight, lineWidth: 3)
                .frame(width: side, height: side)
                .overlay {
                    if case .submitting = viewModel.viewState {
                        ZStack {
                            Color.black.opacity(0.55)
                            ProgressView()
                                .tint(.white)
                        }
                        .frame(width: side, height: side)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                    }
                }
                .position(x: proxy.size.width / 2, y: proxy.size.height * 0.4)
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        if case .error(let message) = viewModel.viewState {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
        } else {
            Text("Point your camera at a Velochat QR code")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ScanView()
}
