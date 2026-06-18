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
                        Text("Group Name")
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
                        Text("Group Announcement")
                        Text(viewModel.announcement.isEmpty ? "Not set" : viewModel.announcement)
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
                        Text("My Group Nickname")
                        Spacer()
                        Text(viewModel.myNickname.isEmpty ? "Not set" : viewModel.myNickname)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section("Members") {
                ForEach(viewModel.members) { member in
                    HStack {
                        Text(viewModel.displayName(for: member))
                        if member.isMe {
                            Spacer()
                            Text("Me")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Group Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await viewModel.didLoad() }
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
