protocol ConversationNoteRepositoryProtocol {
    func setNote(_ note: String, forConversationId id: String)
    func note(forConversationId id: String) -> String?
    func removeNote(forConversationId id: String)
    func loadAll() -> [String: String]

    func setNote(_ note: String, forInboxId inboxId: String)
    func note(forInboxId inboxId: String) -> String?
    func removeNote(forInboxId inboxId: String)
}
