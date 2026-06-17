import SwiftUI

struct CreateGroupMembersView: View {
    @StateObject private var viewModel: CreateGroupViewModel
    @Environment(\.dismiss) private var dismiss

    var onGroupCreated: (ConversationSummary) -> Void

    init(onGroupCreated: @escaping (ConversationSummary) -> Void) {
        _viewModel = StateObject(wrappedValue: AppDI.shared.makeCreateGroupViewModel())
        self.onGroupCreated = onGroupCreated
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.contacts.isEmpty {
                    Text("暂无联系人")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.contacts) { contact in
                        Button {
                            viewModel.toggle(contactId: contact.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: viewModel.selectedIds.contains(contact.id)
                                    ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(viewModel.selectedIds.contains(contact.id)
                                        ? Color.accentColor : .secondary)
                                    .font(.title3)
                                Text(contact.displayName)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择成员")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink("下一步") {
                        CreateGroupNameView(viewModel: viewModel, onGroupCreated: { conversation in
                            onGroupCreated(conversation)
                            dismiss()
                        })
                    }
                    .disabled(!viewModel.canProceed)
                }
            }
            .task {
                viewModel.didLoad()
            }
        }
    }
}
