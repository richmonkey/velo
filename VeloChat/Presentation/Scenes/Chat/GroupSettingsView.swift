import SwiftUI

struct GroupSettingsView: View {
    @StateObject private var viewModel: GroupSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDissolveConfirmation = false

    init(conversationId: String) {
        _viewModel = StateObject(
            wrappedValue: AppDI.shared.makeGroupSettingsViewModel(conversationId: conversationId)
        )
    }

    var body: some View {
        Form {
            if let reason = viewModel.disabledReason {
                Section {
                    Text(reason)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                if viewModel.disabledReason == nil {
                    NavigationLink {
                        GroupNameEditView(conversationId: viewModel.conversationId)
                    } label: {
                        groupNameLabel
                    }
                } else {
                    groupNameLabel.foregroundStyle(.secondary)
                }
            }
            Section {
                if viewModel.disabledReason == nil {
                    NavigationLink {
                        GroupAnnouncementEditView(conversationId: viewModel.conversationId)
                    } label: {
                        groupAnnouncementLabel
                    }
                } else {
                    groupAnnouncementLabel.foregroundStyle(.secondary)
                }
            }
            Section {
                if viewModel.disabledReason == nil {
                    NavigationLink {
                        MyNicknameEditView(conversationId: viewModel.conversationId)
                    } label: {
                        myNicknameLabel
                    }
                } else {
                    myNicknameLabel.foregroundStyle(.secondary)
                }
            }
            Section {
                Toggle("Mute Notifications", isOn: Binding(
                    get: { viewModel.isMuted },
                    set: { viewModel.setMuted($0) }
                ))
                .disabled(viewModel.disabledReason != nil)
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
            if viewModel.isCreator && viewModel.disabledReason == nil {
                Section {
                    Button("Dissolve Group", role: .destructive) {
                        showDissolveConfirmation = true
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
        .confirmationDialog(
            "Dissolve Group",
            isPresented: $showDissolveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Dissolve", role: .destructive) {
                Task {
                    if await viewModel.dissolveGroup() {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all other members. You'll keep the existing chat history, but no one will be able to send or receive messages in this group anymore.")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private var groupNameLabel: some View {
        HStack {
            Text("Group Name")
            Spacer()
            Text(viewModel.groupName)
                .foregroundStyle(.secondary)
        }
    }

    private var groupAnnouncementLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Group Announcement")
            Text(viewModel.announcement.isEmpty ? "Not set" : viewModel.announcement)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var myNicknameLabel: some View {
        HStack {
            Text("My Group Nickname")
            Spacer()
            Text(viewModel.myNickname.isEmpty ? "Not set" : viewModel.myNickname)
                .foregroundStyle(.secondary)
        }
    }
}
