import SwiftUI

struct ConversationSettingsView: View {
    @StateObject private var viewModel: ConversationSettingsViewModel
    let conversationId: String
    let peerInboxId: String?

    init(conversationId: String, peerInboxId: String?) {
        self.conversationId = conversationId
        self.peerInboxId = peerInboxId
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeConversationSettingsViewModel(conversationId: conversationId, peerInboxId: peerInboxId)
        )
    }

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    ConversationNoteEditView(conversationId: conversationId, peerInboxId: peerInboxId)
                } label: {
                    HStack {
                        Text("Note")
                        Spacer()
                        Text(viewModel.note.isEmpty ? "Not set" : viewModel.note)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Section {
                Toggle("Mute Notifications", isOn: Binding(
                    get: { viewModel.isMuted },
                    set: { viewModel.setMuted($0) }
                ))
            }
        }
        .navigationTitle("Chat Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refresh()
        }
    }
}
