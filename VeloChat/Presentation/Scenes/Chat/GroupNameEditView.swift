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
            Section("群名称") {
                TextField("群名称", text: $viewModel.name)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("群名称")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.didLoad()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
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
        .alert("出错了", isPresented: alertBinding) {
            Button("好", role: .cancel) {}
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
