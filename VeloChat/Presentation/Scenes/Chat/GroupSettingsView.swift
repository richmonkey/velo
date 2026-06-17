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
            Section("我的群昵称") {
                HStack {
                    TextField("设置你在本群的昵称", text: $viewModel.myNickname)
                        .autocorrectionDisabled()
                    Button("发送") {
                        viewModel.saveMyNickname()
                    }
                    .disabled(viewModel.myNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            Section("群成员") {
                ForEach(viewModel.members) { member in
                    HStack {
                        Text(displayName(for: member))
                        if member.isMe {
                            Spacer()
                            Text("我")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
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

    private func displayName(for member: GroupMember) -> String {
        if member.isMe { return "我" }
        if let nickname = member.nickname, !nickname.isEmpty { return nickname }
        guard member.id.count > 10 else { return member.id }
        return "\(member.id.prefix(6))…\(member.id.suffix(4))"
    }
}
