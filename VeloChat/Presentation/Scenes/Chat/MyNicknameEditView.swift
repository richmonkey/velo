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
            Section("我的群昵称") {
                TextField("设置你在本群的昵称", text: $viewModel.nickname)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("我的群昵称")
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
                .disabled(isSaving || viewModel.nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
