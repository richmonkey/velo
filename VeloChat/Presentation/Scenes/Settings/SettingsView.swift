import SwiftUI
import UIKit

struct SettingsView: View {
    @StateObject private var viewModel = AppDI.shared.makeSettingsViewModel()
    @ObservedObject private var themeManager = AppDI.shared.themeManager
    @State private var showingOnboarding = false
    @State private var confirmResetOnboarding = false
    @State private var shareItem: ShareTextItem?

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $themeManager.mode) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Notifications") {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Notification Settings")
                }
                .buttonStyle(.pressable)
            }

            Section("Help") {
                NavigationLink("Usage Instructions") {
                    UsageGuideView()
                }
                Button("Replay Welcome Guide") {
                    confirmResetOnboarding = true
                }
                .buttonStyle(.pressable)
            }

            Section("About") {
                NavigationLink("About VeloChat") {
                    AboutView()
                }
                Button("Share This App") {
                    shareItem = ShareTextItem(
                        text: "Check out VeloChat — decentralized, private messaging with no accounts. \(AppStoreConfig.appStoreURL.absoluteString)"
                    )
                }
                .buttonStyle(.pressable)
                Button("Rate VeloChat") {
                    UIApplication.shared.open(AppStoreConfig.writeReviewURL)
                }
                .buttonStyle(.pressable)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView {
                showingOnboarding = false
            }
        }
        .sheet(item: $shareItem) { item in
            ActivityView(items: [item.text])
                .presentationDetents([.medium])
        }
        .alert("Replay Welcome Guide?", isPresented: $confirmResetOnboarding) {
            Button("Cancel", role: .cancel) {}
            Button("Replay") {
                viewModel.resetOnboarding()
                showingOnboarding = true
            }
        } message: {
            Text("This will show the welcome guide again the next time you see it.")
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

private struct ShareTextItem: Identifiable {
    let id = UUID()
    let text: String
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack { SettingsView() }
}
