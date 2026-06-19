import SwiftUI

struct GroupNameEditView: View {
    @StateObject private var viewModel: GroupNameEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeGroupNameEditViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            Section("Group Name") {
                TextField("Group Name", text: $viewModel.name)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("Group Name")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.didLoad()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    isSaving = true
                    Task {
                        let success = await viewModel.save()
                        isSaving = false
                        if success { dismiss() }
                    }
                }
                .disabled(isSaving || viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert("Error", isPresented: alertBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}
