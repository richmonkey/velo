import SwiftUI
import UIKit

struct MeView: View {
    @StateObject private var viewModel = AppDI.shared.makeMeViewModel()
    @State private var showingScan = false
    @State private var shareItem: ShareImageItem?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Me")
                .task {
                    viewModel.didLoad()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if case .loaded(let identity) = viewModel.viewState {
                            Button {
                                if let image = QRCodeGenerator.generate(from: identity.inboxId) {
                                    shareItem = ShareImageItem(image: image)
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingScan) {
                    ScanView()
                }
                .sheet(item: $shareItem) { item in
                    ActivityView(items: [item.image])
                        .presentationDetents([.medium, .large])
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
            Text("Let others scan this QR code to add you")
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

            Spacer()

            Button {
                showingScan = true
            } label: {
                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }
}

private struct ShareImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MeView()
}
