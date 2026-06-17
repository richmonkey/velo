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

    private static func map(_ info: ConversationSummaryInfo) -> ConversationSummary {
        ConversationSummary(
            id: info.id,
            kind: info.kind == .group ? .group : .dm,
            title: info.title,
            lastMessagePreview: info.lastMessagePreview,
            lastActivityDate: info.lastActivityDate
        )
    }
}
