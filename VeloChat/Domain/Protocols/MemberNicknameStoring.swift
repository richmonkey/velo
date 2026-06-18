protocol MemberNicknameStoring {
    func nickname(forConversationId conversationId: String, inboxId: String) -> String?
    func nicknames(forConversationId conversationId: String) -> [String: String]
    func setNickname(_ nickname: String, forConversationId conversationId: String, inboxId: String)
}
