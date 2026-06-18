final class ConversationRepository: ConversationRepositoryProtocol {
    private let conversationManager: XMTPConversationManaging
    private let memberNicknameStore: MemberNicknameStoring

    init(conversationManager: XMTPConversationManaging, memberNicknameStore: MemberNicknameStoring) {
        self.conversationManager = conversationManager
        self.memberNicknameStore = memberNicknameStore
    }

    func fetchConversations() async throws -> [ConversationSummary] {
        let infos = try await conversationManager.fetchConversations()
        return infos.map(Self.map)
    }

    func startConversation(peerInboxId: String) async throws -> ConversationSummary {
        let info = try await conversationManager.startConversation(peerInboxId: peerInboxId)
        return Self.map(info)
    }

    func createGroup(name: String, peerInboxIds: [String]) async throws -> ConversationSummary {
        let info = try await conversationManager.createGroup(name: name, peerInboxIds: peerInboxIds)
        return Self.map(info)
    }

    func fetchGroupInfo(conversationId: String) async throws -> GroupInfo {
        let info = try await conversationManager.fetchGroupInfo(conversationId: conversationId)
        return GroupInfo(name: info.name, announcement: info.announcement)
    }

    func updateGroupAnnouncement(conversationId: String, announcement: String) async throws {
        try await conversationManager.updateGroupAnnouncement(conversationId: conversationId, announcement: announcement)
    }

    func updateGroupName(conversationId: String, name: String) async throws {
        try await conversationManager.updateGroupName(conversationId: conversationId, name: name)
    }

    func fetchGroupMembers(conversationId: String) async throws -> [GroupMember] {
        let infos = try await conversationManager.fetchGroupMembers(conversationId: conversationId)
        let nicknames = memberNicknameStore.nicknames(forConversationId: conversationId)
        return infos.map { GroupMember(id: $0.inboxId, isMe: $0.isMe, nickname: nicknames[$0.inboxId]) }
    }

    func updateMyNickname(conversationId: String, nickname: String) async throws {
        let update = try await conversationManager.updateMyNickname(conversationId: conversationId, nickname: nickname)
        memberNicknameStore.setNickname(update.nickname, forConversationId: conversationId, inboxId: update.inboxId)
    }

    private static func map(_ info: ConversationSummaryInfo) -> ConversationSummary {
        ConversationSummary(
            id: info.id,
            kind: info.kind == .group ? .group : .dm,
            title: info.title,
            lastMessagePreview: info.lastMessagePreview,
            lastActivityDate: info.lastActivityDate,
            peerInboxId: info.peerInboxId,
            lastMessageSenderInboxId: info.lastMessageSenderInboxId,
            lastMessageIsFromMe: info.lastMessageIsFromMe
        )
    }
}
