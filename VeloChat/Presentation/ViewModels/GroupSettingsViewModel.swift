import Foundation

@MainActor
final class GroupSettingsViewModel: ObservableObject {
    let conversationId: String

    @Published private(set) var groupName: String = ""
    @Published private(set) var announcement: String = ""
    @Published private(set) var members: [GroupMember] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isCreator = false
    @Published private(set) var disabledReason: String?
    @Published var errorMessage: String?

    var myNickname: String {
        members.first(where: \.isMe)?.nickname ?? ""
    }

    private let fetchGroupInfo: FetchGroupInfoUseCase
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let noteRepository: ConversationNoteRepositoryProtocol
    private let dissolveGroupUseCase: DissolveGroupUseCase

    init(
        conversationId: String,
        fetchGroupInfo: FetchGroupInfoUseCase,
        fetchGroupMembers: FetchGroupMembersUseCase,
        noteRepository: ConversationNoteRepositoryProtocol,
        dissolveGroup: DissolveGroupUseCase
    ) {
        self.conversationId = conversationId
        self.fetchGroupInfo = fetchGroupInfo
        self.fetchGroupMembers = fetchGroupMembers
        self.noteRepository = noteRepository
        self.dissolveGroupUseCase = dissolveGroup
    }

    func displayName(for member: GroupMember) -> String {
        if member.isMe { return "Me" }
        if let nickname = member.nickname, !nickname.isEmpty { return nickname }
        if let note = noteRepository.note(forInboxId: member.id), !note.isEmpty { return note }
        guard member.id.count > 10 else { return member.id }
        return "\(member.id.prefix(6))…\(member.id.suffix(4))"
    }

    func didLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let info = try await fetchGroupInfo.execute(conversationId: conversationId)
            groupName = info.name
            announcement = info.announcement
            isCreator = info.isCreator
            members = try await fetchGroupMembers.execute(conversationId: conversationId)
            updateDisabledReason(isActive: info.isActive)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateDisabledReason(isActive: Bool) {
        let hasOtherMembers = members.contains { !$0.isMe }
        if !isActive {
            disabledReason = "You are no longer a member of this group."
        } else if !hasOtherMembers {
            disabledReason = "This group has been dissolved."
        } else {
            disabledReason = nil
        }
    }

    func dissolveGroup() async -> Bool {
        do {
            try await dissolveGroupUseCase.execute(conversationId: conversationId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
