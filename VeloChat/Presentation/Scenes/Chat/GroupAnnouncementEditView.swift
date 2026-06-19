import SwiftUI

struct GroupAnnouncementEditView: View {
    @StateObject private var viewModel: GroupAnnouncementEditViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeGroupAnnouncementEditViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            Section("Group Announcement") {
                TextEditor(text: $viewModel.announcement)
                    .frame(minHeight: 160)
                    .autocorrectionDisabled()
            }
        }
        .navigationTitle("Group Announcement")
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
                .disabled(isSaving)
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
