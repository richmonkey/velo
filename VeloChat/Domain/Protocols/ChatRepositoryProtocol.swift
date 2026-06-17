protocol ChatRepositoryProtocol {
    func fetchMessages(conversationId: String) async throws -> [ChatMessage]
    func sendMessage(conversationId: String, text: String) async throws -> ChatMessage
    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessage, Error>
    func streamAllMessages() -> AsyncThrowingStream<ChatMessage, Error>
}
