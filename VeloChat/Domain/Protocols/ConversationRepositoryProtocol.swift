protocol ConversationRepositoryProtocol {
    func fetchConversations() async throws -> [ConversationSummary]
    func startConversation(peerInboxId: String) async throws -> ConversationSummary
}
