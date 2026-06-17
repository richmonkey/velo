import SwiftUI

struct GroupSettingsView: View {
    @StateObject private var viewModel: GroupSettingsViewModel

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeGroupSettingsViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    GroupNameEditView(conversationId: viewModel.conversationId)
                } label: {
                    HStack {
                        Text("群名称")
                        Spacer()
                        Text(viewModel.groupName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section {
                NavigationLink {
                    GroupAnnouncementEditView(conversationId: viewModel.conversationId)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("群公告")
                        Text(viewModel.announcement.isEmpty ? "未设置" : viewModel.announcement)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Section {
                NavigationLink {
                    MyNicknameEditView(conversationId: viewModel.conversationId)
                } label: {
                    HStack {
                        Text("我的群昵称")
                        Spacer()
                        Text(viewModel.myNickname.isEmpty ? "未设置" : viewModel.myNickname)
                            .foregroundStyle(.secondary)
                    }
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
        .onAppear {
            Task { await viewModel.didLoad() }
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
