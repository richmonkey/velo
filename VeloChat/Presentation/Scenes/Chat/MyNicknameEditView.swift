import SwiftUI

struct MyNicknameEditView: View {
    @StateObject private var viewModel: MyNicknameEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeMyNicknameEditViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            Section("My Group Nickname") {
                TextField("Set your nickname in this group", text: $viewModel.nickname)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("My Group Nickname")
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
                .disabled(isSaving || viewModel.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
