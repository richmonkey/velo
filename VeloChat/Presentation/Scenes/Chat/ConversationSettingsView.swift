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
            Section("备注") {
                TextField("为此联系人添加备注", text: $viewModel.note)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("会话设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    viewModel.save()
                    dismiss()
                }
            }
        }
    }
}
