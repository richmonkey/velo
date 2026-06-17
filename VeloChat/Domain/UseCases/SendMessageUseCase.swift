protocol SendMessageUseCase {
    func execute(conversationId: String, text: String) async throws -> ChatMessage
}

final class DefaultSendMessageUseCase: SendMessageUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, text: String) async throws -> ChatMessage {
        try await repository.sendMessage(conversationId: conversationId, text: text)
    }
}
