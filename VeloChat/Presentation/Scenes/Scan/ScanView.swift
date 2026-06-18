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
    var onConversationCreated: () -> Void = {}

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                QRScannerRepresentable { code in
                    viewModel.submit(peerInboxId: code)
                }
                .frame(height: 320)
                .overlay {
                    if case .submitting = viewModel.viewState {
                        ProgressView()
                            .tint(.white)
                    }
                }

                if case .error(let message) = viewModel.viewState {
                    Text(message)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding()
                }
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.viewState) { newValue in
                if case .success = newValue {
                    onConversationCreated()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ScanView()
}
