protocol ConversationRepositoryProtocol {
    func fetchConversations() async throws -> [ConversationSummary]
    func startConversation(peerInboxId: String) async throws -> ConversationSummary
    func createGroup(name: String, peerInboxIds: [String]) async throws -> ConversationSummary
    func fetchGroupInfo(conversationId: String) async throws -> GroupInfo
    func updateGroupAnnouncement(conversationId: String, announcement: String) async throws
    func fetchGroupMembers(conversationId: String) async throws -> [GroupMember]
    func updateMyNickname(conversationId: String, nickname: String) async throws
}
