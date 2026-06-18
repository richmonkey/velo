import SwiftUI

struct ConversationSettingsView: View {
    @StateObject private var viewModel: ConversationSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(conversationId: String, peerInboxId: String?) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeConversationSettingsViewModel(conversationId: conversationId, peerInboxId: peerInboxId)
        )
    }

    var body: some View {
        Form {
            Section("Note") {
                TextField("Add a note for this contact", text: $viewModel.note)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("Conversation Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
    }
}
