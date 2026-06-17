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
    @State private var manualInboxId: String = ""
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

                Form {
                    Section("手动添加") {
                        TextField("对方的 Inbox ID", text: $manualInboxId)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Button("添加") {
                            viewModel.submit(peerInboxId: manualInboxId)
                        }
                        .disabled(manualInboxId.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if case .error(let message) = viewModel.viewState {
                        Section {
                            Text(message)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("添加联系人")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
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
