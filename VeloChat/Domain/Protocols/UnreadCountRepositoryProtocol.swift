protocol UnreadCountRepositoryProtocol {
    func increment(conversationId: String)
    func reset(conversationId: String)
    func loadAll() -> [String: Int]
}
