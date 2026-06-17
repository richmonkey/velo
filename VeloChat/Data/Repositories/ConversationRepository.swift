final class ConversationRepository: ConversationRepositoryProtocol {
    private let conversationManager: XMTPConversationManaging

    init(conversationManager: XMTPConversationManaging) {
        self.conversationManager = conversationManager
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

    func fetchGroupMembers(conversationId: String) async throws -> [GroupMember] {
        let infos = try await conversationManager.fetchGroupMembers(conversationId: conversationId)
        return infos.map { GroupMember(id: $0.inboxId, isMe: $0.isMe, nickname: $0.nickname) }
    }

    func updateMyNickname(conversationId: String, nickname: String) async throws {
        try await conversationManager.updateMyNickname(conversationId: conversationId, nickname: nickname)
    }

    private static func map(_ info: ConversationSummaryInfo) -> ConversationSummary {
        ConversationSummary(
            id: info.id,
            kind: info.kind == .group ? .group : .dm,
            title: info.title,
            lastMessagePreview: info.lastMessagePreview,
            lastActivityDate: info.lastActivityDate,
            peerInboxId: info.peerInboxId
        )
    }
}
