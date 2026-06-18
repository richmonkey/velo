import Foundation

@MainActor
final class GroupSettingsViewModel: ObservableObject {
    let conversationId: String

    @Published private(set) var groupName: String = ""
    @Published private(set) var announcement: String = ""
    @Published private(set) var members: [GroupMember] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    var myNickname: String {
        members.first(where: \.isMe)?.nickname ?? ""
    }

    private let fetchGroupInfo: FetchGroupInfoUseCase
    private let fetchGroupMembers: FetchGroupMembersUseCase
    private let noteRepository: ConversationNoteRepositoryProtocol

    init(
        conversationId: String,
        fetchGroupInfo: FetchGroupInfoUseCase,
        fetchGroupMembers: FetchGroupMembersUseCase,
        noteRepository: ConversationNoteRepositoryProtocol
    ) {
        self.conversationId = conversationId
        self.fetchGroupInfo = fetchGroupInfo
        self.fetchGroupMembers = fetchGroupMembers
        self.noteRepository = noteRepository
    }

    func displayName(for member: GroupMember) -> String {
        if member.isMe { return "我" }
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
            members = try await fetchGroupMembers.execute(conversationId: conversationId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
