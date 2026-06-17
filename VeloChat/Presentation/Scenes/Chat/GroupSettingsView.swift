import SwiftUI

struct GroupSettingsView: View {
    @StateObject private var viewModel: GroupSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeGroupSettingsViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            Section("群名称") {
                Text(viewModel.groupName)
                    .foregroundStyle(.secondary)
            }
            Section("群公告") {
                TextEditor(text: $viewModel.announcement)
                    .frame(minHeight: 120)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("群组设置")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.didLoad()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    viewModel.save()
                    dismiss()
                }
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
