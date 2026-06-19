import SwiftUI

struct CreateGroupNameView: View {
    @ObservedObject var viewModel: CreateGroupViewModel
    var onGroupCreated: (ConversationSummary) -> Void

    var body: some View {
        Form {
            Section("Group Name") {
                TextField("Enter a group name", text: $viewModel.groupName)
                    .autocorrectionDisabled()
            }

            Section("Selected Members (\(viewModel.selectedIds.count))") {
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
        .navigationTitle("Group Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isCreating {
                    ProgressView()
                } else {
                    Button("Create") {
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
