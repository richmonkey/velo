import Foundation

@MainActor
final class GroupSettingsViewModel: ObservableObject {
    @Published var announcement: String = ""
    @Published private(set) var groupName: String = ""
    @Published private(set) var members: [GroupMember] = []
    @Published var myNickname: String = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let conversationId: String
    private let fetchGroupInfo: FetchGroupInfoUseCase
    private let updateGroupAnnouncement: UpdateGroupAnnouncementUseCase
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let updateMyNickname: UpdateMyNicknameUseCase

    init(
        conversationId: String,
        fetchGroupInfo: FetchGroupInfoUseCase,
        updateGroupAnnouncement: UpdateGroupAnnouncementUseCase,
        fetchGroupMembers: FetchGroupMembersUseCase,
        updateMyNickname: UpdateMyNicknameUseCase
    ) {
        self.conversationId = conversationId
        self.fetchGroupInfo = fetchGroupInfo
        self.updateGroupAnnouncement = updateGroupAnnouncement
        self.fetchGroupMembers = fetchGroupMembers
        self.updateMyNickname = updateMyNickname
    }

    func didLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await fetchGroupInfo.execute(conversationId: conversationId)
            groupName = info.name
            announcement = info.announcement
            members = try await fetchGroupMembers.execute(conversationId: conversationId)
            myNickname = members.first(where: \.isMe)?.nickname ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() {
        let conversationId = self.conversationId
        let announcement = self.announcement
        Task {
            do {
                try await updateGroupAnnouncement.execute(conversationId: conversationId, announcement: announcement)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func saveMyNickname() {
        let trimmed = myNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let conversationId = self.conversationId
        Task {
            do {
                try await updateMyNickname.execute(conversationId: conversationId, nickname: trimmed)
                myNickname = trimmed
                members = members.map { member in
                    guard member.isMe else { return member }
                    return GroupMember(id: member.id, isMe: true, nickname: trimmed)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
