import SwiftUI

struct CreateGroupNameView: View {
    @ObservedObject var viewModel: CreateGroupViewModel
    var onGroupCreated: (ConversationSummary) -> Void

    var body: some View {
        Form {
            Section("群组名称") {
                TextField("请输入群组名称", text: $viewModel.groupName)
                    .autocorrectionDisabled()
            }

            Section("已选成员（\(viewModel.selectedIds.count) 人）") {
                ForEach(viewModel.contacts.filter { viewModel.selectedIds.contains($0.id) }) { contact in
                    Text(contact.displayName)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("群组信息")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isCreating {
                    ProgressView()
                } else {
                    Button("创建") {
                        viewModel.createGroup()
                    }
                    .disabled(!viewModel.canCreate || viewModel.isCreating)
                }
            }
        }
        .onChange(of: viewModel.createdConversation) { conversation in
            guard let conversation else { return }
            onGroupCreated(conversation)
        }
    }
}
